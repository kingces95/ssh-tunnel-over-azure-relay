alias vpt-tool-az-install='vpt::tool::az::install'
alias vpt-tool-azbridge-install='vpt::tool::azbridge::install'

vpt::tool::azbridge::install() {

    # download azbridge
    if [[ ! -d "${VPT_TOOL_AZBRIDGE_REPO_DIR}" ]]; then
        git clone \
            "${VPT_TOOL_AZBRIDGE_REPO}" \
            "${VPT_TOOL_AZBRIDGE_REPO_DIR}" 
    fi

    # install azbridge
    if ! (azbridge >/dev/null); then
        sudo apt install \
            "${VPT_TOOL_AZBRIDGE_REPO_DIR}/${VPT_TOOL_AZBRIDGE_DEB}"
    fi
}

vpt::tool::az::install() {
    if ! (which az >/dev/null); then
        curl -sL "${VPT_TOOL_AZ_INSTALL_SCRIPT}" \
            | sudo bash 
    fi
}
