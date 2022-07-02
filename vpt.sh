alias vpt-reload=". \$VPT_REPO_DIR/vpt.sh"
alias vpt-myip='vpt::myip'
alias vpt-tool-azinstall='vpt::tool::az::install'
alias vpt-tool-azbridge-install='vpt::tool::azbridge::install'
alias vpt-ssh-keys-install='vpt::ssh::keys::install'
alias vpt-ssh-start='vpt::ssh::start'
alias vpt-ssh-stop='vpt::ssh::stop'
alias vpt-ssh-connect='vpt::ssh::connect'
alias vpt-proxy-start='vpt::proxy::start'
alias vpt-proxy-curl='vpt::proxy::curl'
alias vpt-azure-login='vpt::azure::login'
alias vpt-azure-relay-create='vpt::azure::relay::create'
alias vpt-azure-relay-delete='vpt::azure::relay::delete'
alias vpt-azure-relay-connection-string='vpt::azure::relay::connection_string'
alias vpt-azure-relay-www='vpt::azure::relay::www'
alias vpt-azure-relay-remote-start='vpt::azure::relay::remote::start'
alias vpt-azure-relay-local-start='vpt::azure::relay::local::start'
alias vpt-azure-relay-connect='vpt::azure::relay::connect'
alias vpt-azure-relay-proxy-start='vpt::azure::relay::proxy::start'
alias vpt-azure-proxy-enable='vpt::azure::proxy::enable'
alias vpt-azure-proxy-disable='vpt::azure::proxy::disable'
alias vpt-azure-group-show='vpt::azure::group::show'

alias re='vpt-reload'

# constants
VPT_REPO_DIR=$(cd "$(dirname ${BASH_SOURCE})"; pwd)
VPT_MONKIER=vpb
VPT_PREFIX="${GITHUB_USER}-${VPT_MONKIER}"

# keys
VPT_REPO_SSH_DIR="${VPT_REPO_DIR}/.ssh"
VPT_REPO_SSH_PRIVATE_KEY="${VPT_REPO_SSH_DIR}/id_rsa"
VPT_REPO_SSH_PUBLIC_KEY="${VPT_REPO_SSH_DIR}/id_rsa.pub"
VPT_SSH_DIR="${HOME}/.ssh"
VPT_SSH_PRIVATE_KEY="${VPT_SSH_DIR}/id_rsa"
VPT_SSH_PUBLIC_KEY="${VPT_SSH_DIR}/id_rsa.pub"
VPT_SSH_AUTHORIZED_KEYS="${VPT_SSH_DIR}/authorized_keys"

# relay
VPT_RELAY_NAMESPACE="${VPT_PREFIX}-relay"
VPT_RELAY_NAME='bridge'

# service
VPT_SSH_PORT=$( # 2222
    cat /etc/ssh/sshd_config \
        | egrep ^Port \
        | egrep -o '[0-9]*'
)

# service <- relay remote
VPT_RELAY_REMOTE_IP=localhost
VPT_RELAY_REMOTE_PORT="${VPT_SSH_PORT}"

# service <- relay remote <- relay local
VPT_RELAY_LOCAL_IP=localhost
VPT_RELAY_LOCAL_PORT=$(( VPT_SSH_PORT + 1 )) # 2223

# service <- relay remote <- relay local <- socks5 proxy
VPT_SOCKS5_PORT=$(( VPT_RELAY_LOCAL_PORT + 1 )) # 2224

# default Azure variables
export AZURE_DISABLE_CONFIRM_PROMPT=yes
export AZURE_DEFAULTS_GROUP="${VPT_PREFIX}-rg"
export AZURE_DEFAULTS_LOCATION="westus"

vpt::myip() {
    curl https://api.ipify.org
    echo
}

vpt::ssh::key::install() {
    if [[ ! -f "{VPT_SSH_PRIVATE_KEY}" ]]; then
        # authenticate clients by private key
        install -m u=rw,go= "${VPT_REPO_SSH_PRIVATE_KEY}" "${VPT_SSH_PRIVATE_KEY}"
    fi
}

vpt::ssh::key::authorize() {
    if ! cat ${VPT_SSH_AUTHORIZED_KEYS} \
        | grep "$(cat "${VPT_REPO_SSH_PUBLIC_KEY}")" \
        >/dev/null 2>&1
    then
        # grant access to clients who own key
        cat "${VPT_REPO_SSH_PUBLIC_KEY}" >> "${VPT_SSH_AUTHORIZED_KEYS}"
    fi
}

vpt::ssh::keys::install() {
    
    # disable ssh password prompts; securty provided by Azure Relay
    if [[ ! -f "{VPT_SSH_PRIVATE_KEY}" ]]; then
    
        #  assign everyone the same private key
        install -m u=rw,go= "${VPT_REPO_SSH_PRIVATE_KEY}" "${VPT_SSH_PRIVATE_KEY}"
        
        # grant access to anyone with the private key
        cat "${VPT_REPO_SSH_PUBLIC_KEY}" >> "${VPT_SSH_AUTHORIZED_KEYS}"
    fi
}

vpt::tool::azbridge::install() {
    # download azbridge
    if [[ ! -d ~/azure-relay-bridge-binaries ]]; then
        git clone \
            https://github.com/kingces95/azure-relay-bridge-binaries \
            ~/azure-relay-bridge-binaries 
    fi

    # install azbridge
    if ! (azbridge >/dev/null); then
        sudo apt install \
            ~/azure-relay-bridge-binaries/azbridge.0.3.0-rtm.ubuntu.20.04-x64.deb
    fi
}

vpt::tool::az::install() {
    if ! (which az >/dev/null); then
        curl -sL https://aka.ms/InstallAzureCLIDeb \
            | sudo bash 
    fi
}

vpt::ssh::stop() {
    sudo /etc/init.d/ssh stop
}

vpt::ssh::start() {
    vpt::ssh::key::authorize

    # /usr/local/share/ssh-init.sh
    sudo /etc/init.d/ssh start
}

vpt::ssh::exec() {
    vpt::ssh::key::install

    local ARGS=( "$@" )
    local DESTINATION="${ARGS[-1]}"

    unset ARGS[-1]

    ssh \
        "${ARGS[@]}" \
        -o StrictHostKeyChecking=no \
        -o UserKnownHostsFile=/dev/null \
        "${DESTINATION}"
}

vpt::ssh::connect() {
    vpt::ssh::exec \
        -p "${VPT_SSH_PORT}" \
        "${USER}@localhost"
}

vpt::proxy::start() {
    vpt::ssh::exec \
        -D "${VPT_SOCKS5_PORT}" \
        -p "${VPT_SSH_PORT}" \
        "${USER}@localhost"
}

vpt::proxy::curl() {
    curl \
        -x "socks5h://localhost:${VPT_SOCKS5_PORT}" \
        "${1-https://api.ipify.org}"
    echo
}

vpt::azure::env::tenant::set() {
    if [[ ! "${AZURE_DEFAULTS_TENANT}" ]]; then
        read -p 'Tenant id: ' AZURE_DEFAULTS_TENANT
    fi
}

vpt::azure::env::subscription::set() {
    if [[ ! "${AZURE_DEFAULTS_SUBSCRIPTION}" ]]; then
        read -p 'Subscription id: ' AZURE_DEFAULTS_SUBSCRIPTION
    fi
}

vpt::azure::login() {
    vpt::tool::az::install

    # login
    if az account show >/dev/null 2>/dev/null; then
        return
    fi

    vpt::azure::env::tenant::set
    vpt::azure::env::subscription::set

    # get token
    az login \
        --use-device-code \
        --tenant "${AZURE_DEFAULTS_TENANT}" \
        >/dev/null

    # set default subscription
    az account set \
        --subscription "${AZURE_DEFAULTS_SUBSCRIPTION}"
}

vpt::azure::relay::delete() {
    vpt::azure::login

    az group delete \
        --name "${AZURE_DEFAULTS_GROUP}"
}

vpt::azure::relay::show() {
    az relay hyco show \
        --name "${VPT_RELAY_NAME}" \
        --namespace-name "${VPT_RELAY_NAMESPACE}"
}

vpt::azure::relay::test() {
    vpt::azure::relay::show \
        >/dev/null 2>&1
}

vpt::azure::relay::create() {
    vpt::azure::login

    if vpt::azure::relay::test; then
        return
    fi

    az group create \
        --name "${AZURE_DEFAULTS_GROUP}"

    az relay namespace create \
        --name "${VPT_RELAY_NAMESPACE}"

    az relay hyco create \
        --name "${VPT_RELAY_NAME}" \
        --namespace-name "${VPT_RELAY_NAMESPACE}" \
        --requires-client-authorization true
}

vpt::azure::relay::connection_string() {
    vpt::azure::relay::create \
        >/dev/null

    az relay namespace authorization-rule keys list \
        --name 'RootManageSharedAccessKey' \
        --namespace-name "${VPT_RELAY_NAMESPACE}" \
        --query primaryConnectionString \
        --output tsv
}

vpt::azure::relay::www() {
    vpt::azure::relay::create

    local URL=(
        'https://ms.portal.azure.com/'
        '#@microsoft.onmicrosoft.com/resource'
        "/subscriptions/${AZURE_DEFAULTS_SUBSCRIPTION}"
        "/resourceGroups/${AZURE_DEFAULTS_GROUP}"
        "/providers/Microsoft.Relay/namespaces/${VPT_RELAY_NAMESPACE}/hybridConnections"
        "/${VPT_RELAY_NAME}/overview"
    )
    (
        IFS=
        echo "${URL[*]}"
    )
}

vpt::azure::relay::remote::start() {
    vpt::ssh::start

    vpt::tool::azbridge::install

    local RELAY_CONNECTION_STRING=$(vpt::azure::relay::connection_string)
    azbridge \
        -R "${VPT_RELAY_NAME}:${VPT_RELAY_REMOTE_IP}:${VPT_RELAY_LOCAL_PORT}/${VPT_RELAY_REMOTE_PORT}" \
        -x "${RELAY_CONNECTION_STRING}"
}

vpt::azure::relay::local::start() {
    vpt::tool::azbridge::install

    local RELAY_CONNECTION_STRING=$(vpt::azure::relay::connection_string)
    azbridge \
        -L "${VPT_RELAY_LOCAL_IP}:${VPT_RELAY_LOCAL_PORT}:${VPT_RELAY_NAME}" \
        -x "${RELAY_CONNECTION_STRING}"
}

vpt::azure::relay::connect() {
    vpt::ssh::exec \
        -p "${VPT_RELAY_LOCAL_PORT}" \
        "${USER}@localhost"
}

vpt::azure::relay::proxy::start() {
    vpt::ssh::exec \
        -D "${VPT_SOCKS5_PORT}" \
        -p "${VPT_RELAY_LOCAL_PORT}" \
        "${USER}@localhost"
}

vpt::azure::group::show() {
    az group show \
        --name "${AZURE_DEFAULTS_GROUP}"
}

vpt::azure::proxy::enable() {
    # https://docs.microsoft.com/en-us/azure/developer/python/sdk/azure-sdk-configure-proxy?tabs=bash
    export HTTPS_PROXY="socks5h://${USER}:${PASSWORD}@localhost:${VPT_SOCKS5_PORT}"      
}

vpt::azure::proxy::disable() {
    unset HTTPS_PROXY
}
