alias vpt-azbridge-remote-start='vpt::azbridge::remote::start'
alias vpt-azbridge-local-start='vpt::azbridge::local::start'

vpt::azbridge() {
    vpt::tool::azbridge::install

    local RELAY_CONNECTION_STRING=$(vpt::azure::relay::connection_string)

    azbridge \
        "$@" \
        -x "${RELAY_CONNECTION_STRING}" &
}

vpt::azbridge::local::start() {
    # azbridge localhost:2223:bridge
    vpt::azbridge \
        -L "${VPT_AZURE_RELAY_LOCAL_IP}:${VPT_AZURE_RELAY_LOCAL_PORT}:${VPT_AZURE_RELAY_NAME}"
}

vpt::azbridge::remote::start() {
    # azbridge bridge:localhost:2223/2222
    vpt::azbridge \
        -R "${VPT_AZURE_RELAY_NAME}:${VPT_AZURE_RELAY_REMOTE_IP}:${VPT_AZURE_RELAY_LOCAL_PORT}/${VPT_AZURE_RELAY_REMOTE_PORT}"
}
