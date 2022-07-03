alias vpt-azure-group-create='vpt::azure::group::create'
alias vpt-azure-group-delete='vpt::azure::group::delete'
alias vpt-azure-group-show='vpt::azure::group::show'
alias vpt-azure-group-test='vpt::azure::group::test'

vpt::azure::group::show() {
    vpt::az group show \
        --name "${AZURE_DEFAULTS_GROUP}"
}

vpt::azure::group::test() {
    vpt::azure::group::show \
        >/dev/null 2>&1
}

vpt::azure::group::create() {
    if vpt::azure::group::test; then
        return
    fi

    vpt::az group create \
        --name "${AZURE_DEFAULTS_GROUP}"
}

vpt::azure::group::delete() {
    if ! vpt::azure::group::test; then
        return
    fi

    vpt::az group delete \
        --name "${AZURE_DEFAULTS_GROUP}"
}