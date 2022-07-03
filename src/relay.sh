alias vpt-azure-relay-create='vpt::azure::relay::create'
alias vpt-azure-relay-delete='vpt::azure::relay::delete'
alias vpt-azure-relay-show='vpt::azure::relay::show'
alias vpt-azure-relay-test='vpt::azure::relay::test'
alias vpt-azure-relay-connection-string='vpt::azure::relay::connection_string'
alias vpt-azure-relay-www='vpt::azure::relay::www'

vpt::azure::relay::show() {
    vpt::az relay hyco show \
        --name "${VPT_AZURE_RELAY_NAME}" \
        --namespace-name "${VPT_AZURE_RELAY_NAMESPACE}"
}

vpt::azure::relay::test() {
    vpt::azure::relay::show \
        >/dev/null 2>&1
}

vpt::azure::relay::create() {
    if vpt::azure::relay::test; then
        return
    fi

    vpt::az relay namespace create \
        --name "${VPT_AZURE_RELAY_NAMESPACE}"

    vpt::az relay hyco create \
        --name "${VPT_AZURE_RELAY_NAME}" \
        --namespace-name "${VPT_AZURE_RELAY_NAMESPACE}" \
        --requires-client-authorization true
}

vpt::azure::relay::delete() {
    if ! vpt::azure::relay::test; then
        return
    fi

    vpt::az relay namespace delete \
        --name "${VPT_AZURE_RELAY_NAMESPACE}"
}

vpt::azure::relay::connection_string() {
    vpt::azure::relay::create \
        >/dev/null

    vpt::az relay namespace authorization-rule keys list \
        --name 'RootManageSharedAccessKey' \
        --namespace-name "${VPT_AZURE_RELAY_NAMESPACE}" \
        --query primaryConnectionString \
        --output tsv
}

vpt::azure::relay::www() {
    vpt::azure::relay::create

    local URL=(
        'https://ms.portal.azure.com/'
        '#@microsoft.onmicrosoft.com/resource'
        "/subscriptions/${VPT_AZURE_SUBSCRIPTION}"
        "/resourceGroups/${VPT_AZURE_GROUP}"
        "/providers/Microsoft.Relay/namespaces/${VPT_AZURE_RELAY_NAMESPACE}/hybridConnections"
        "/${VPT_AZURE_RELAY_NAME}/overview"
    )
    (
        IFS=
        echo "${URL[*]}"
    )
}
