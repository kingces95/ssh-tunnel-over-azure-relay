vpt::uup() {
    # https://www.golinuxcloud.com/test-ssh-connection/

    local PORT="$1"
    shift

    local TIMEOUT="${1-${VPT_UUP_TIMEOUT}}"
    shift

    vpt::timeout "${TIMEOUT}" nc -z localhost "${PORT}"
}

