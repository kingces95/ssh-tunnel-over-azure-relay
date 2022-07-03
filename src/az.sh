alias vpt-az-proxy-enable='vpt::az::proxy::enable'
alias vpt-az-proxy-disable='vpt::az::proxy::disable'
alias vpt-az-login='vpt::az::login'

vpt::az() (
    vpt::tool::az::install

    export AZURE_DISABLE_CONFIRM_PROMPT=yes
    export AZURE_DEFAULTS_GROUP="${VPT_AZURE_GROUP}"
    export AZURE_DEFAULTS_LOCATION="${VPT_AZURE_LOCATION}"
    
    az "$@"
)

vpt::az::env::tenant::set() {
    if [[ ! "${VPT_AZURE_TENANT}" ]]; then
        read -p 'Tenant id: ' VPT_AZURE_TENANT
    fi
}

vpt::az::env::subscription::set() {
    if [[ ! "${VPT_AZURE_SUBSCRIPTION}" ]]; then
        read -p 'Subscription id: ' VPT_AZURE_SUBSCRIPTION
    fi
}

vpt::az::login() {
    # login
    if vpt::az account show >/dev/null 2>/dev/null; then
        return
    fi

    vpt::az::env::tenant::set
    vpt::az::env::subscription::set

    # get token
    vpt::az login \
        --use-device-code \
        --tenant "${VPT_AZURE_TENANT}" \
        >/dev/null

    # set default subscription
    vpt::az account set \
        --subscription "${VPT_AZURE_SUBSCRIPTION}"
}

vpt::az::proxy() (
    vpt::az::proxy::enable
    vpt::az "$@"
)

vpt::az::proxy::enable() {
    # https://docs.microsoft.com/en-us/azure/developer/python/sdk/azure-sdk-configure-proxy?tabs=bash
    export HTTPS_PROXY="${VPT_SOCKS5H_HTTPS_PROXY}"
}

vpt::az::proxy::disable() {
    unset HTTPS_PROXY
}
