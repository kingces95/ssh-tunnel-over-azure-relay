# dirs
VPT_DIR_SRC=$(cd "$(dirname ${BASH_SOURCE})"; pwd)
VPT_DIR_SRC_SSH="${VPT_DIR_SRC}/.ssh"
VPT_DIR_HOME_SSH="${HOME}/.ssh"

# tools
VPT_TOOL_AZ_INSTALL_SCRIPT='https://aka.ms/InstallAzureCLIDeb'
VPT_TOOL_AZBRIDGE_REPO='https://github.com/kingces95/azure-relay-bridge-binaries'
VPT_TOOL_AZBRIDGE_REPO_DIR="${HOME}/azure-relay-bridge-binaries"
VPT_TOOL_AZBRIDGE_DEB='azbridge.0.3.0-rtm.ubuntu.20.04-x64.deb'

# keys
VPT_SSH_PRIVATE_KEY="${VPT_DIR_SRC_SSH}/id_rsa"
VPT_SSH_PUBLIC_KEY="${VPT_DIR_SRC_SSH}/id_rsa.pub"
VPT_OS_SSH_PRIVATE_KEY="${VPT_DIR_HOME_SSH}/id_rsa"
VPT_OS_SSH_AUTHORIZED_KEYS="${VPT_DIR_HOME_SSH}/authorized_keys"

# azure
VPT_AZURE_PREFIX="vpt-${USER}"
VPT_AZURE_LOCATION='westus'
VPT_AZURE_GROUP="${VPT_AZURE_PREFIX}-rg"

# azure login
VPT_AZURE_TENANT=
VPT_AZURE_SUBSCRIPTION=

# azure relay
VPT_AZURE_RELAY_NAMESPACE="${VPT_AZURE_PREFIX}-relay"
VPT_AZURE_RELAY_NAME='bridge'

# service
VPT_SSH_PORT=$( # 2222
    cat /etc/ssh/sshd_config \
        | egrep ^Port \
        | egrep -o '[0-9]*'
)

# service <- relay remote
VPT_AZURE_RELAY_REMOTE_IP=localhost
VPT_AZURE_RELAY_REMOTE_PORT="${VPT_SSH_PORT}"

# service <- relay remote <- relay local
VPT_AZURE_RELAY_LOCAL_IP=localhost
VPT_AZURE_RELAY_LOCAL_PORT=$(( VPT_SSH_PORT + 1 )) # 2223

# service <- relay remote <- relay local <- socks5 proxy
VPT_SOCKS5H_PORT=$(( VPT_AZURE_RELAY_LOCAL_PORT + 1 )) # 2224
VPT_SOCKS5H_SCHEME='socks5h://'
VPT_SOCKS5H_CURL_X="${VPT_SOCKS5H_SCHEME}localhost:${VPT_SOCKS5H_PORT}"
VPT_SOCKS5H_HTTPS_PROXY="${VPT_SOCKS5H_SCHEME}${USER}:${PASSWORD}@localhost:${VPT_SOCKS5H_PORT}"

# testing
VPT_MYIP='https://api.ipify.org'
