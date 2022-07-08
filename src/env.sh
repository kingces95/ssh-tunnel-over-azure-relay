# shim
declare -g VPT_DIR_REPO

# log
declare -g VPT_LOG="/tmp/vpt.log"

# you-up
declare -g VPT_UUP_TIMEOUT=32
declare -g VPT_SSH_TIMEOUT=32

# azure login
declare -g VPT_AZURE_TENANT
declare -g VPT_AZURE_SUBSCRIPTION

# user
declare -g VPT_USER_PRIVATE_KEY="${HOME}/.ssh/id_rsa"

# dirs
declare -g VPT_DIR_SRC=$(cd "$(dirname ${BASH_SOURCE})"; pwd)
declare -g VPT_DIR_SSH="${VPT_DIR_REPO}/.ssh"

# tools
declare -g VPT_TOOL_AZ_INSTALL_SCRIPT='https://aka.ms/InstallAzureCLIDeb'
declare -g VPT_TOOL_AZBRIDGE_REPO='https://github.com/kingces95/azure-relay-bridge-binaries'
declare -g VPT_TOOL_AZBRIDGE_REPO_DIR="${HOME}/azure-relay-bridge-binaries"
declare -g VPT_TOOL_AZBRIDGE_DEB='azbridge.0.3.0-rtm.ubuntu.20.04-x64.deb'

# keys
declare -g VPT_SSH_PRIVATE_KEY="${VPT_DIR_SSH}/id_rsa"
declare -g VPT_SSH_PUBLIC_KEY="${VPT_DIR_SSH}/id_rsa.pub"

# azure
declare -g VPT_AZURE_TAG="${VPT_AZURE_TAG:-test}"
declare -g VPT_AZURE_PREFIX="vpt-${VPT_AZURE_TAG}"
declare -g VPT_AZURE_LOCATION='westus'
declare -g VPT_AZURE_GROUP="${VPT_AZURE_PREFIX}-rg"

# azure relay
declare -g VPT_AZURE_RELAY_NAMESPACE="${VPT_AZURE_PREFIX}-relay"
declare -g VPT_AZURE_RELAY_NAME='bridge'

# ssh
declare -g VPT_SSH_DEFAULTS=(
    -o StrictHostKeyChecking=no
    -o UserKnownHostsFile=/dev/null
    -o LogLevel=ERROR
)

# service
declare -g VPT_SSH_IP=127.0.0.1
declare -g VPT_SSH_PORT=$( # 2222
    cat /etc/ssh/sshd_config \
        | egrep ^Port \
        | egrep -o '[0-9]*'
)

# service <- relay remote
declare -g VPT_AZURE_RELAY_REMOTE_IP=127.0.0.1
declare -g VPT_AZURE_RELAY_REMOTE_PORT="${VPT_SSH_PORT}"

# service <- relay remote <- relay local
declare -g VPT_AZURE_RELAY_LOCAL_IP=127.0.0.2
declare -g VPT_AZURE_RELAY_LOCAL_PORT=$(( VPT_SSH_PORT + 1 )) # 2223

# service <- relay remote <- relay local <- socks5 proxy
declare -g VPT_SOCKS5H_IP=127.0.0.1
declare -g VPT_SOCKS5H_PORT=$(( VPT_AZURE_RELAY_LOCAL_PORT + 1 )) # 2224
declare -g VPT_SOCKS5H_URL="socks5h://${VPT_SOCKS5H_IP}:${VPT_SOCKS5H_PORT}"

# anonymous
declare -g VPT_ANONYMOUS=anon
declare -g VPT_ANONYMOUS_UPN="${VPT_ANONYMOUS}@127.0.0.2"
declare -g VPT_ANONYMOUS_DIR="/home/${VPT_ANONYMOUS}"
declare -g VPT_ANONYMOUS_AUTHORIZED_KEYS="${VPT_ANONYMOUS_DIR}/.ssh/authorized_keys"

# testing
declare -g VPT_MYIP='https://api.ipify.org'
