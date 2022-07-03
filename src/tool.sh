alias vpt-tool-nc-install='vpt::tool::nc::install'
alias vpt-tool-az-install='vpt::tool::az::install'
alias vpt-tool-azbridge-install='vpt::tool::azbridge::install'

vpt::tool::azbridge::download() {
    if [[ -d "${VPT_TOOL_AZBRIDGE_REPO_DIR}" ]]; then
        return
    fi

    # download azbridge
    git clone \
        "${VPT_TOOL_AZBRIDGE_REPO}" \
        "${VPT_TOOL_AZBRIDGE_REPO_DIR}" 
}

vpt::tool::azbridge::install() {
    vpt::tool::azbridge::download

    # install azbridge
    if (azbridge >/dev/null); then
        return
    fi

    sudo apt install \
        "${VPT_TOOL_AZBRIDGE_REPO_DIR}/${VPT_TOOL_AZBRIDGE_DEB}"
}

vpt::tool::az::install() {
    if (which az >/dev/null); then
        return
    fi

    curl -sL "${VPT_TOOL_AZ_INSTALL_SCRIPT}" \
        | sudo bash 
}

vpt::tool::nc::install() {
    if (which nc >/dev/null); then
        return
    fi

    apt install -y netcat 
}
