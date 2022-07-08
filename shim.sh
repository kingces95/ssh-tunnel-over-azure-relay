alias vpt-shim-reload="vpt::shim::reload"
alias vpt-shim-test="vpt::shim::test"
alias re='vpt::shim::reload'

vpt::shim::reload() {
    # vpt::log::clear
    
    . "${VPT_DIR_REPO}/shim.sh"
}

vpt::shim::test::admin() {
    echo 'vpt-azure-group-create'
    vpt-azure-group-create

    vpt::shim::test
}

vpt::shim::test() {
    echo 'create-bridge'
    vpt-create-bridge

    vpt::test

    echo 'vpt-delete-bridge'
    vpt-delete-bridge
}

# identity
if [[ "${GITHUB_USER}" ]]; then
    declare -g VPT_AZURE_USER="${GITHUB_USER}"
    declare -g VPT_AZURE_SUBSCRIPTION="${VPT_CODESPACE_SECRET_AZURE_SUBSCRIPTION}"
    declare -g VPT_AZURE_TENANT="${VPT_CODESPACE_SECRET_AZURE_TENANT}"
    declare -g VPT_AZURE_PASSWORD="${VPT_CODESPACE_SECRET_AZURE_TEST_PASSWORD}"
    declare -g VPT_AZURE_UPN="${VPT_CODESPACE_SECRET_AZURE_TEST_UPN}"
else
    declare -g VPT_AZURE_USER="${USER}"
fi

# source everyting in src/...
declare -g VPT_DIR_REPO=$(cd "$(dirname ${BASH_SOURCE})"; pwd)
while read; do source "${REPLY}"; done \
    < <(find "${VPT_DIR_REPO}/src" -type f -name "*.sh")
