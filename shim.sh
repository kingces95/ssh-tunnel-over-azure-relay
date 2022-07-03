alias vpt-reload=". \$VPT_DIR_REPO/shim.sh"
alias re='vpt-reload'

VPT_DIR_REPO=$(cd "$(dirname ${BASH_SOURCE})"; pwd)

if [[ "${GITHUB_USER}" ]]; then
    USER="${GITHUB_USER}"
fi

while read; do source "${REPLY}"; done \
    < <(find "${VPT_DIR_REPO}/src" -type f -name "*.sh")
