alias vpt-azbridge-remote-start='vpt::azbridge::remote::start'
alias vpt-azbridge-local-start='vpt::azbridge::local::start'
alias vpt-azbridge-remote-start-async='vpt::azbridge::remote::start::async'
alias vpt-azbridge-local-start-async='vpt::azbridge::local::start::async'

vpt::azbridge() {
    local RELAY_CONNECTION_STRING=$(vpt::azure::relay::connection_string)

    azbridge \
        "$@" \
        -x "${RELAY_CONNECTION_STRING}"
}

vpt::azbridge::local::start() {
    # azbridge localhost:2223:bridge
    vpt::azbridge \
        -L "${VPT_AZURE_RELAY_LOCAL_IP}:${VPT_AZURE_RELAY_LOCAL_PORT}:${VPT_AZURE_RELAY_NAME}"
}

vpt::azbridge::remote::start() {
    vpt::uup "${VPT_SSH_PORT}" 
    # azbridge bridge:localhost:2223/2222
    vpt::azbridge \
        -R "${VPT_AZURE_RELAY_NAME}:${VPT_AZURE_RELAY_REMOTE_IP}:${VPT_AZURE_RELAY_LOCAL_PORT}/${VPT_AZURE_RELAY_REMOTE_PORT}"
}

vpt::azbridge::local::start::async() {
    # TODO: wait for bridge to have a listener
    vpt::azbridge::local::start >/dev/null 2>&1 &
}

vpt::azbridge::remote::start::async() {
    vpt::azbridge::remote::start >/dev/null 2>&1 &
}