alias vpt-azbridge-remote-start='vpt::azbridge::remote::start'
alias vpt-azbridge-local-start='vpt::azbridge::local::start'
alias vpt-azbridge-remote-start-async='vpt::azbridge::remote::start::async'
alias vpt-azbridge-local-start-async='vpt::azbridge::local::start::async'

vpt::azbridge() {
    local RELAY_CONNECTION_STRING=$(vpt::azure::relay::connection_string)

    if "${VPT_AZBRIDGE_ASYNC-false}"; then
        azbridge "$@" -x "${RELAY_CONNECTION_STRING}" &
        return
    fi

    azbridge "$@" -x "${RELAY_CONNECTION_STRING}"
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
    VPT_AZBRIDGE_ASYNC=true \
        vpt::azbridge::local::start
}

vpt::azbridge::remote::start::async() {
    VPT_AZBRIDGE_ASYNC=true \
        vpt::azbridge::remote::start
}
