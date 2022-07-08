alias vpt-tool-nc-install='vpt::tool::nc::install'
alias vpt-tool-az-install='vpt::tool::az::install'
alias vpt-tool-azbridge-install='vpt::tool::azbridge::install'
alias vpt-tool-azbridge-uninstall='vpt::tool::azbridge::uninstall'

vpt::tool::test() (
    which "$1" >/dev/null
)

vpt::tool::azbridge::download() {
    if [[ -d "${VPT_TOOL_AZBRIDGE_REPO_DIR}" ]]; then
        return
    fi

    # download azbridge
    git clone -q \
        "${VPT_TOOL_AZBRIDGE_REPO}" \
        "${VPT_TOOL_AZBRIDGE_REPO_DIR}"
}

vpt::tool::azbridge::uninstall() (
    vpt::log::exec
    if ! vpt::tool::test azbridge; then
        return
    fi

    sudo apt-get remove -qq \
        "${VPT_TOOL_AZBRIDGE_REPO_DIR}/${VPT_TOOL_AZBRIDGE_DEB}"
)

vpt::tool::azbridge::install() (
    vpt::log::exec
    vpt::tool::azbridge::download

    # install azbridge
    if vpt::tool::test azbridge; then
        return
    fi

    sudo apt-get install -qq \
        "${VPT_TOOL_AZBRIDGE_REPO_DIR}/${VPT_TOOL_AZBRIDGE_DEB}"
)

vpt::tool::az::install() (
    vpt::log::exec
    if vpt::tool::test az; then
        return
    fi

    curl -sL "${VPT_TOOL_AZ_INSTALL_SCRIPT}" \
        | sudo bash
)

vpt::tool::nc::install() (
    vpt::log::exec
    if vpt::tool::test nc; then
        return
    fi

    sudo apt-get install -qq netcat
)
