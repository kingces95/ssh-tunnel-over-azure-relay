alias vpt-demo='vpt::demo'


vpt::demo() {
    vpt::az::proxy group show \
        --name "${AZURE_DEFAULTS_GROUP}"
}
