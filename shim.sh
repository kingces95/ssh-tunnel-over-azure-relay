alias vpt-reload=". \$VPT_DIR_REPO/shim.sh"
alias re='vpt-reload'

# codespace
if [[ "${GITHUB_USER}" ]]; then
    USER="${GITHUB_USER}"
    VPT_AZURE_SUBSCRIPTION="${VPT_CODESPACE_SECRET_AZURE_SUBSCRIPTION}"
    VPT_AZURE_TENANT="${VPT_CODESPACE_SECRET_AZURE_TENANT}"
fi

# source everyting in src/...
VPT_DIR_REPO=$(cd "$(dirname ${BASH_SOURCE})"; pwd)
while read; do source "${REPLY}"; done \
    < <(find "${VPT_DIR_REPO}/src" -type f -name "*.sh")
