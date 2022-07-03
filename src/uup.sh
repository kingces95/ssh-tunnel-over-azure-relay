vpt::uup() {
    local PORT="$1"
    shift

    local TIMEOUT="${1-10}"
    shift

    local TICKS
    for ((TICKS=0; TICKS<"${TIMEOUT}"; TICKS++)); do
        if nc -z localhost "${PORT}"; then
            return;
        fi
          
        sleep 1
    done

    echo "ERROR: Timeout waiting for port ${PORT}." 1>&2
    return 1
}
