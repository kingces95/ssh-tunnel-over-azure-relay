# shim
declare VPT_DIR_REPO

# azure login
declare VPT_AZURE_TENANT
declare VPT_AZURE_SUBSCRIPTION

# dirs
declare VPT_DIR_SRC=$(cd "$(dirname ${BASH_SOURCE})"; pwd)
declare VPT_DIR_SRC_SSH="${VPT_DIR_REPO}/.ssh"
declare VPT_DIR_HOME_SSH="${HOME}/.ssh"

# tools
declare VPT_TOOL_AZ_INSTALL_SCRIPT='https://aka.ms/InstallAzureCLIDeb'
declare VPT_TOOL_AZBRIDGE_REPO='https://github.com/kingces95/azure-relay-bridge-binaries'
declare VPT_TOOL_AZBRIDGE_REPO_DIR="${HOME}/azure-relay-bridge-binaries"
declare VPT_TOOL_AZBRIDGE_DEB='azbridge.0.3.0-rtm.ubuntu.20.04-x64.deb'

# keys
declare VPT_SSH_PRIVATE_KEY="${VPT_DIR_SRC_SSH}/id_rsa"
declare VPT_SSH_PUBLIC_KEY="${VPT_DIR_SRC_SSH}/id_rsa.pub"
declare VPT_OS_SSH_PRIVATE_KEY="${VPT_DIR_HOME_SSH}/id_rsa"
declare VPT_OS_SSH_AUTHORIZED_KEYS="${VPT_DIR_HOME_SSH}/authorized_keys"

# azure
declare VPT_AZURE_PREFIX="vpt-${USER}"
declare VPT_AZURE_LOCATION='westus'
declare VPT_AZURE_GROUP="${VPT_AZURE_PREFIX}-rg"


# azure relay
declare VPT_AZURE_RELAY_NAMESPACE="${VPT_AZURE_PREFIX}-relay"
declare VPT_AZURE_RELAY_NAME='bridge'

# service
declare VPT_SSH_PORT=$( # 2222
    cat /etc/ssh/sshd_config \
        | egrep ^Port \
        | egrep -o '[0-9]*'
)

# service <- relay remote
declare VPT_AZURE_RELAY_REMOTE_IP=localhost
declare VPT_AZURE_RELAY_REMOTE_PORT="${VPT_SSH_PORT}"

# service <- relay remote <- relay local
declare VPT_AZURE_RELAY_LOCAL_IP=localhost
declare VPT_AZURE_RELAY_LOCAL_PORT=$(( VPT_SSH_PORT + 1 )) # 2223

# service <- relay remote <- relay local <- socks5 proxy
declare VPT_SOCKS5H_PORT=$(( VPT_AZURE_RELAY_LOCAL_PORT + 1 )) # 2224
declare VPT_SOCKS5H_SCHEME='socks5h://'
declare VPT_SOCKS5H_CURL_X="${VPT_SOCKS5H_SCHEME}localhost:${VPT_SOCKS5H_PORT}"
declare VPT_SOCKS5H_HTTPS_PROXY="${VPT_SOCKS5H_SCHEME}${USER}:${PASSWORD}@localhost:${VPT_SOCKS5H_PORT}"

# testing
declare VPT_MYIP='https://api.ipify.org'
