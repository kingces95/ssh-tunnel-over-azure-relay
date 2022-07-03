alias vpt-demo='vpt::demo'


vpt::demo() {
    vpt::az::proxy group show \
        --name "${VPT_AZURE_GROUP}"
}
