alias vpt-reload=". \$VPT_DIR_REPO/shim.sh"
alias re='vpt-reload'

# identity
if [[ "${GITHUB_USER}" ]]; then
    declare VPT_AZURE_USER="${GITHUB_USER}"
    declare VPT_AZURE_SUBSCRIPTION="${VPT_CODESPACE_SECRET_AZURE_SUBSCRIPTION}"
    declare VPT_AZURE_TENANT="${VPT_CODESPACE_SECRET_AZURE_TENANT}"
else
    declare VPT_AZURE_USER="${USER}"
fi

# source everyting in src/...
declare VPT_DIR_REPO=$(cd "$(dirname ${BASH_SOURCE})"; pwd)
while read; do source "${REPLY}"; done \
    < <(find "${VPT_DIR_REPO}/src" -type f -name "*.sh")
