vpt::timeout() {
    local TIMEOUT="$1"
    shift

    local TICKS
    for (( TICKS=0; TICKS<"${TIMEOUT}"; TICKS++ )); do
        if "$@"; then
            return;
        fi
          
        sleep 1
    done

    echo "ERROR: Timeout waiting for port '$@'." 1>&2
    return 1
}
