alias vpt-ssh-start='vpt::ssh::start'
alias vpt-ssh-stop='vpt::ssh::stop'
alias vpt-ssh-connect='vpt::ssh::connect'
alias vpt-ssh-proxy-start='vpt::ssh::proxy::start'
alias vpt-ssh-azure-relay-connect='vpt::ssh::azure::relay::connect'
alias vpt-ssh-azure-relay-proxy-start='vpt::ssh::azure::relay::proxy::start'
alias vpt-ssh-azure-relay-proxy-start-async='vpt::ssh::azure::relay::proxy::start::async'
alias vpt-ssh-proxy-curl='vpt::ssh::proxy::curl'
alias vpt-ssh-key-install='vpt::ssh::key::install'

vpt::ssh::key::install() {
    if [[ ! -f "{VPT_USER_PRIVATE_KEY}" ]]; then
        # authenticate clients by private key
        install -m u=rw,go= "${VPT_SSH_PRIVATE_KEY}" "${VPT_USER_PRIVATE_KEY}"
    fi
}

vpt::ssh::uup() {
    local PORT="$1"
    shift

    local TIMEOUT="${1-${VPT_SSH_TIMEOUT}}"
    shift

    vpt::timeout "${TIMEOUT}" \
        ssh \
            "${VPT_SSH_DEFAULTS[@]}" \
            -q \
            -p "${PORT}" \
            "${VPT_ANONYMOUS_UPN}" \
            'exit 0'
}

vpt::ssh() {
    ssh \
        "${VPT_SSH_DEFAULTS[@]}" \
        "$@" \
        "${VPT_ANONYMOUS_UPN}"
}

vpt::ssh::stop() (
    vpt::log::exec
    sudo /etc/init.d/ssh stop
)

vpt::ssh::start() (
    vpt::log::exec
    # codespaces launches an sshd server at startup
    # /usr/local/share/ssh-init.sh
    sudo /etc/init.d/ssh start
)

vpt::ssh::connect() {
    vpt::uup "${VPT_SSH_PORT}"
    vpt::ssh \
        -p "${VPT_SSH_PORT}"
}

vpt::ssh::proxy::start() (
    vpt::log::exec

    vpt::ssh::uup "${VPT_SSH_PORT}"
    vpt::ssh \
        -D "${VPT_SOCKS5H_PORT}" \
        -p "${VPT_SSH_PORT}"
)

vpt::ssh::azure::relay::connect() {
    vpt::ssh::uup "${VPT_AZURE_RELAY_LOCAL_PORT}"
    vpt::ssh \
        -p "${VPT_AZURE_RELAY_LOCAL_PORT}"
}

vpt::ssh::azure::relay::proxy::start() (
    vpt::log::exec
    # https://www.metahackers.pro/ssh-tunnel-as-socks5-proxy/

    vpt::ssh::uup "${VPT_AZURE_RELAY_LOCAL_PORT}"
    vpt::ssh \
        -D "${VPT_SOCKS5H_PORT}" \
        -p "${VPT_AZURE_RELAY_LOCAL_PORT}" \
        -N
)

vpt::ssh::azure::relay::proxy6::start::async() (
    vpt::ssh::uup "${VPT_AZURE_RELAY_LOCAL_PORT}"
    vpt::ssh \
        -6 \
        -D "${VPT_SOCKS5H_PORT}" \
        -p "${VPT_AZURE_RELAY_LOCAL_PORT}" \
        -N \
        &
)

vpt::ssh::azure::relay::proxy::start::async() {
    vpt::ssh::uup "${VPT_AZURE_RELAY_LOCAL_PORT}"
    vpt::ssh \
        -D "${VPT_SOCKS5H_PORT}" \
        -p "${VPT_AZURE_RELAY_LOCAL_PORT}" \
        -N \
        &
}

vpt::ssh::proxy::curl() {
    vpt::ssh::uup "${VPT_SOCKS5H_PORT}"
    curl \
        -x "${VPT_SOCKS5H_URL}" \
        "$1"
}
