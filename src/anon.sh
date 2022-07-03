alias vpt-anonymous-test='vpt::anonymous::test'
alias vpt-anonymous-adduser='vpt::anonymous::adduser'
alias vpt-anonymous-deluser='vpt::anonymous::deluser'
alias vpt-anonymous-key-install='vpt::anonymous::key::install'

vpt::anonymous::test() {
    cat /etc/passwd \
        | egrep "^${VPT_ANONYMOUS}:" \
        >/dev/null 2>&1
}

vpt::anonymous::adduser() {
    if vpt::anonymous::test; then
        return
    fi

    sudo adduser "${VPT_ANONYMOUS}" \
        --gecos "" \
        --disabled-password \
        --quiet
}

vpt::anonymous::deluser() {
    if ! vpt::anonymous::test; then
        return
    fi

    sudo deluser "${VPT_ANONYMOUS}" \
        --remove-home \
        --quiet
}

vpt::anonymous::key::install() {
    if [[ -f "${VPT_ANONYMOUS_AUTHORIZED_KEYS}" ]]; then
        return
    fi

    sudo mkdir -p $(dirname "${VPT_ANONYMOUS_AUTHORIZED_KEYS}")
    sudo cp "${VPT_SSH_PUBLIC_KEY}" "${VPT_ANONYMOUS_AUTHORIZED_KEYS}"
}
