alias vpt-reload=". \$REPO_DIR/launch.sh"
alias vpt-install='vpt::install'
alias vpt-azure-login='vpt::azure::login'
alias vpt-azure-relay-create='vpt::azure::relay::create'
alias vpt-azure-relay-delete='vpt::azure::relay::delete'
alias vpt-azure-relay-connection-string='vpt::azure::relay::connection_string'
alias vpt-azure-relay-www='vpt::azure::relay::www'
alias vpt-myip='vpt::myip'
alias vpt-ssh-start='vpt::ssh::start'
alias vpt-proxy-start='vpt::proxy::start'
alias vpt-ssh-connect='vpt::ssh::connect'
alias vpt-azure-relay-remote-start='vpt::azure::relay::remote::start'
alias vpt-azure-relay-local-start='vpt::azure::relay::local::start'
alias vpt-azure-relay-connect='vpt::azure::relay::connect'
alias vpt-azure-relay-proxy-start='vpt::azure::relay::proxy::start'
alias vpt-proxy-curl='vpt::proxy::curl'
alias vpt-azure-proxy-enable='vpt::azure::proxy::enable'
alias vpt-azure-proxy-disable='vpt::azure::proxy::disable'
alias vpt-azure-group-show='vpt::azure::group::show'

alias re='vpt-reload'

# constants
REPO_DIR=$(cd "$(dirname ${BASH_SOURCE})"; pwd)
PASSWORD=asdf1234
MONKIER=vpb
PREFIX="${GITHUB_USER}-${MONKIER}"

# keys
REPO_SSH_DIR="${REPO_DIR}/.ssh"
REPO_SSH_PRIVATE_KEY="${REPO_SSH_DIR}/id_rsa"
REPO_SSH_PUBLIC_KEY="${REPO_SSH_DIR}/id_rsa.pub"
SSH_DIR="${HOME}/.ssh"
SSH_PRIVATE_KEY="${SSH_DIR}/id_rsa"
SSH_PUBLIC_KEY="${SSH_DIR}/id_rsa.pub"
SSH_AUTHORIZED_KEYS="${SSH_DIR}/authorized_keys"

# relay
RELAY_NAMESPACE="${PREFIX}-relay"
RELAY_NAME='bridge'
RELAY_CONNECTION_STRING=

# service
SSH_PORT=$( # 2222
    cat /etc/ssh/sshd_config \
        | egrep ^Port \
        | egrep -o '[0-9]*'
)

# service <- relay remote
RELAY_REMOTE_IP=localhost
RELAY_REMOTE_PORT="${SSH_PORT}"

# service <- relay remote <- relay local
RELAY_LOCAL_IP=localhost
RELAY_LOCAL_PORT=$(( SSH_PORT + 1 )) # 2223

# service <- relay remote <- relay local <- socks5 proxy
SOCKS5_PORT=$(( RELAY_LOCAL_PORT + 1 )) # 2224

# default Azure variables
export AZURE_DISABLE_CONFIRM_PROMPT=yes
export AZURE_DEFAULTS_GROUP="${PREFIX}-rg"
export AZURE_DEFAULTS_LOCATION="westus"

vpt::keys::install() {
    
    # disable ssh password prompts; securty provided by Azure Relay
    if [[ ! -f "{SSH_PRIVATE_KEY}" ]]; then
    
        #  assign everyone the same private key
        install -m u=rw,go= "${REPO_SSH_PRIVATE_KEY}" "${SSH_PRIVATE_KEY}"
        
        # grant access to anyone with the private key
        cat "${REPO_SSH_PUBLIC_KEY}" >> "${SSH_AUTHORIZED_KEYS}"
    fi
}

vpt::install() {
    vpt::keys::install

    # tenant
    if [[ ! "${AZURE_DEFAULTS_TENANT}" ]]; then
        read -p 'Tenant id: ' AZURE_DEFAULTS_TENANT
    fi

    # subscription
    if [[ ! "${AZURE_DEFAULTS_SUBSCRIPTION}" ]]; then
        read -p 'Subscription id: ' AZURE_DEFAULTS_SUBSCRIPTION
    fi

    # install az command line tool
    if ! (which az >/dev/null); then
        curl -sL https://aka.ms/InstallAzureCLIDeb \
            | sudo bash 
    fi
        
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

vpt::azure::login() {
    vpt::install

    # login
    if ! az account show >/dev/null 2>/dev/null; then
        az login \
            --use-device-code \
            --tenant "${AZURE_DEFAULTS_TENANT}" \
            >/dev/null

        az account set \
            --subscription "${AZURE_DEFAULTS_SUBSCRIPTION}"
    fi
}

vpt::azure::relay::delete() {
    vpt::azure::login

    az group delete \
        --name "${AZURE_DEFAULTS_GROUP}"
}

vpt::azure::relay::show() {
    az relay hyco show \
        --name "${RELAY_NAME}" \
        --namespace-name "${RELAY_NAMESPACE}"
}

vpt::azure::relay::test() {
    vpt::azure::relay::show >/dev/null 2>&1
}

vpt::azure::relay::create() (
    vpt::azure::login

    if vpt::azure::relay::test; then
        return
    fi

    az group create \
        --name "${AZURE_DEFAULTS_GROUP}"

    az relay namespace create \
        --name "${RELAY_NAMESPACE}"

    az relay hyco create \
        --name "${RELAY_NAME}" \
        --namespace-name "${RELAY_NAMESPACE}" \
        --requires-client-authorization true
)

vpt::azure::relay::connection_string() {
    vpt::azure::relay::create

    az relay namespace authorization-rule keys list \
        --name 'RootManageSharedAccessKey' \
        --namespace-name "${RELAY_NAMESPACE}" \
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
        "/providers/Microsoft.Relay/namespaces/${RELAY_NAMESPACE}/hybridConnections"
        "/${RELAY_NAME}/overview"
    )
    (
        IFS=
        echo "${URL[*]}"
    )
}

vpt::ssh::start() {
    /usr/local/share/ssh-init.sh
}

vpt::proxy::start() {
    ssh \
        -D "${SOCKS5_PORT}" \
        -p "${SSH_PORT}" \
        -o StrictHostKeyChecking=no \
        -o UserKnownHostsFile=/dev/null \
        "${USER}@localhost"
}

vpt::ssh::connect() {
    ssh \
        -p "${SSH_PORT}" \
        -o StrictHostKeyChecking=no \
        -o UserKnownHostsFile=/dev/null \
        "${USER}@localhost"
}

vpt::azure::relay::remote::start() {
    vpt::ssh::start

    local RELAY_CONNECTION_STRING=$(vpt::azure::relay::connection_string)
    azbridge \
        -R "${RELAY_NAME}:${RELAY_REMOTE_IP}:${RELAY_LOCAL_PORT}/${RELAY_REMOTE_PORT}" \
        -x "${RELAY_CONNECTION_STRING}"
}

vpt::azure::relay::local::start() {
    local RELAY_CONNECTION_STRING=$(vpt::azure::relay::connection_string)
    azbridge \
        -L "${RELAY_LOCAL_IP}:${RELAY_LOCAL_PORT}:${RELAY_NAME}" \
        -x "${RELAY_CONNECTION_STRING}"
}

vpt::azure::relay::connect() {
    ssh \
        -p "${RELAY_LOCAL_PORT}" \
        -o StrictHostKeyChecking=no \
        -o UserKnownHostsFile=/dev/null \
        "${USER}@localhost"
}

vpt::azure::relay::proxy::start() {
    ssh \
        -D "${SOCKS5_PORT}" \
        -p "${RELAY_LOCAL_PORT}" \
        -o StrictHostKeyChecking=no \
        -o UserKnownHostsFile=/dev/null \
        "${USER}@localhost"
}

vpt::proxy::curl() {
    curl \
        -x "socks5h://localhost:${SOCKS5_PORT}" \
        "${1-https://api.ipify.org}"
    echo
}

vpt::myip() {
    curl https://api.ipify.org
    echo
}

vpt::azure::proxy::enable() {
    # https://docs.microsoft.com/en-us/azure/developer/python/sdk/azure-sdk-configure-proxy?tabs=bash
    export HTTPS_PROXY="socks5h://${USER}:${PASSWORD}@localhost:${SOCKS5_PORT}"      
}

vpt::azure::proxy::disable() {
    unset HTTPS_PROXY
}

vpt::azure::group::show() {
    az group show \
        --name "${AZURE_DEFAULTS_GROUP}"
}