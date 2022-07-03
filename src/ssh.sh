alias vpt-ssh-start='vpt::ssh::start'
alias vpt-ssh-stop='vpt::ssh::stop'
alias vpt-ssh-connect='vpt::ssh::connect'
alias vpt-ssh-proxy-start='vpt::ssh::proxy::start'
alias vpt-ssh-azure-relay-connect='vpt::ssh::azure::relay::connect'
alias vpt-ssh-azure-relay-proxy-start='vpt::ssh::azure::relay::proxy::start'
alias vpt-ssh-proxy-curl='vpt::ssh::proxy::curl'
alias vpt-ssh-key-install='vpt::ssh::key::install'

vpt::ssh::key::install() {
    if [[ ! -f "{VPT_USER_PRIVATE_KEY}" ]]; then
        # authenticate clients by private key
        install -m u=rw,go= "${VPT_SSH_PRIVATE_KEY}" "${VPT_USER_PRIVATE_KEY}"
    fi
}

vpt::ssh() {
    vpt::ssh::key::install

    echo ssh \
        "$@" \
        -o StrictHostKeyChecking=no \
        -o UserKnownHostsFile=/dev/null \
        "${VPT_ANONYMOUS_UPN}"
}

vpt::ssh::stop() {
    sudo /etc/init.d/ssh stop
}

vpt::ssh::start() {
    vpt::ssh::key::authorize

    # codespaces launches an sshd server at startup
    # /usr/local/share/ssh-init.sh
    sudo /etc/init.d/ssh start
}

vpt::ssh::connect() {
    vpt::ssh \
        -p "${VPT_SSH_PORT}"
}

vpt::ssh::proxy::start() {
    vpt::ssh \
        -D "${VPT_SOCKS5H_PORT}" \
        -p "${VPT_SSH_PORT}"
}

vpt::ssh::azure::relay::connect() {
    vpt::ssh \
        -p "${VPT_AZURE_RELAY_LOCAL_PORT}"
}

vpt::ssh::azure::relay::proxy::start() {
    # https://www.metahackers.pro/ssh-tunnel-as-socks5-proxy/

    vpt::ssh \
        -D "${VPT_SOCKS5H_PORT}" \
        -p "${VPT_AZURE_RELAY_LOCAL_PORT}" \
        -N &
}

vpt::ssh::proxy::curl() {
    curl \
        -x "${VPT_SOCKS5H_CURL_X}" \
        "$1"
}
