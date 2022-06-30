CONNECTION="$1"

if [[ "${CONNECTION}" == 'ssh' ]]; then
    echo "Connecting over ssh... (password is asdf1234)"

    echo "codespace:asdf1234" | sudo chpasswd
    ssh \
        -p 2223 \
        -o StrictHostKeyChecking=no \
        -o UserKnownHostsFile=/dev/null \
        codespace@127.1.2.4
    return
fi

# install az command line tool
if ! (which az >/dev/null); then
    curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash
fi

# constants
MONKIER=vpb
PREFIX="${GITHUB_USER}-${MONKIER}"
RELAY_NAMESPACE="${PREFIX}-relay"
RELAY_NAME='bridge'
CONNECTION_STRING=

# default Azure variables
export AZURE_DISABLE_CONFIRM_PROMPT=yes
export AZURE_DEFAULTS_GROUP="${PREFIX}-rg"
export AZURE_DEFAULTS_LOCATION="westus"

# scratch location for secrets
touch .secrets

# tenant/subscription
if [[ ! "${AZURE_DEFAULTS_TENANT}" ]]; then
    read -p 'Tenant id: ' AZURE_DEFAULTS_TENANT
fi
if [[ ! "${AZURE_DEFAULTS_SUBSCRIPTION}" ]]; then
    read -p 'Subscription id: ' AZURE_DEFAULTS_SUBSCRIPTION
fi

# login
if ! (az account show >/dev/null 2>/dev/null); then
    az login --use-device-code --tenant "${AZURE_DEFAULTS_TENANT}"
fi

# activate azure resource; get relay connection string
CONNECTION_STRING=$(
    az relay namespace authorization-rule keys list \
        --name 'RootManageSharedAccessKey' \
        --namespace-name "${RELAY_NAMESPACE}" \
        --query primaryConnectionString \
        --output tsv \
        2>/dev/null
)

if [[ ! "${CONNECTION_STRING}" ]]; then
    az account set \
        --subscription "${AZURE_DEFAULTS_SUBSCRIPTION}"

    az group create \
        --name "${AZURE_DEFAULTS_GROUP}"

    az relay namespace create \
        --name "${RELAY_NAMESPACE}"

    az relay hyco create \
        --name "${RELAY_NAME}" \
        --namespace-name "${RELAY_NAMESPACE}" \
        --requires-client-authorization true

    CONNECTION_STRING=$(
        az relay namespace authorization-rule keys list \
            --name 'RootManageSharedAccessKey' \
            --namespace-name "${RELAY_NAMESPACE}" \
            --query primaryConnectionString \
            --output tsv
    )
fi

# install azbridge
if [[ ! -d ~/azure-relay-bridge-binaries ]]; then
    git clone https://github.com/kingces95/azure-relay-bridge-binaries ~/azure-relay-bridge-binaries
fi
if ! (azbridge >/dev/null); then
    sudo apt install ~/azure-relay-bridge-binaries/azbridge.0.3.0-rtm.ubuntu.20.04-x64.deb
fi

# relay local
RELAY_LOCAL_IP=127.1.2.4
RELAY_LOCAL_PORT=2223

# relay remote
RELAY_REMOTE_IP=localhost
RELAY_REMOTE_PORT=$( # 2222
    cat /etc/ssh/sshd_config \
        | egrep ^Port \
        | egrep -o '[0-9]*'
)

if [[ "${CONNECTION}" == 'client' ]]; then
    echo 'Starting azbridge client...'
    
    # user -> 127.0.0.4:2223 -> test
    azbridge \
        -L "${RELAY_LOCAL_IP}:${RELAY_LOCAL_PORT}:${RELAY_NAME}" \
        -x "${CONNECTION_STRING}"
        
else
    echo 'Starting ssh server ...'
    /usr/local/share/ssh-init.sh

    echo 'Starting azbridge server...'
    
    # test -> localhost -> 2222 -> ssh
    # ssh:localhost:2223/2222
    azbridge \
        -R "${RELAY_NAME}:${RELAY_REMOTE_IP}:${RELAY_LOCAL_PORT}/${RELAY_REMOTE_PORT}" \
        -x "${CONNECTION_STRING}"
fi
