# shim
declare VPT_DIR_REPO

# log
declare VPT_LOG="/tmp/vpt.log"

# azure login
declare VPT_AZURE_TENANT
declare VPT_AZURE_SUBSCRIPTION

# anonymous
declare VPT_ANONYMOUS=anon
declare VPT_ANONYMOUS_UPN="${VPT_ANONYMOUS}@localhost"
declare VPT_ANONYMOUS_DIR="/home/${VPT_ANONYMOUS}"
declare VPT_ANONYMOUS_AUTHORIZED_KEYS="${VPT_ANONYMOUS_DIR}/.ssh/authorized_keys"

# user
declare VPT_USER_PRIVATE_KEY="${HOME}/.ssh/id_rsa"

# dirs
declare VPT_DIR_SRC=$(cd "$(dirname ${BASH_SOURCE})"; pwd)
declare VPT_DIR_SSH="${VPT_DIR_REPO}/.ssh"

# tools
declare VPT_TOOL_AZ_INSTALL_SCRIPT='https://aka.ms/InstallAzureCLIDeb'
declare VPT_TOOL_AZBRIDGE_REPO='https://github.com/kingces95/azure-relay-bridge-binaries'
declare VPT_TOOL_AZBRIDGE_REPO_DIR="${HOME}/azure-relay-bridge-binaries"
declare VPT_TOOL_AZBRIDGE_DEB='azbridge.0.3.0-rtm.ubuntu.20.04-x64.deb'

# keys
declare VPT_SSH_PRIVATE_KEY="${VPT_DIR_SSH}/id_rsa"
declare VPT_SSH_PUBLIC_KEY="${VPT_DIR_SSH}/id_rsa.pub"

# azure
declare VPT_AZURE_PREFIX="vpt-${VPT_AZURE_USER}"
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
declare VPT_SOCKS5H_URL="${VPT_SOCKS5H_SCHEME}localhost:${VPT_SOCKS5H_PORT}"

# testing
declare VPT_MYIP='https://api.ipify.org'
