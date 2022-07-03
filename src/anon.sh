alias vpt-anonymous-test='vpt::anonymous::test'
alias vpt-anonymous-create='vpt::anonymous::create'

vpt::anonymous::test() {
    cat /etc/passwd \
        | grep "^${VPT_ANONYMOUS}:" \
        >/dev/null 2>&1
}

vpt::anonymous::create() {
    if vpt::anonymous::test; then
        return
    fi

    sudo adduser "${VPT_ANONYMOUS}" \
        --disabled-password \
        --gecos "" \
        --quiet
        user2

    sudo mkdir -p $(dirname "${VPT_ANONYMOUS_AUTHORIZED_KEYS}")
    sudo cp "${VPT_SSH_PUBLIC_KEY}" "${VPT_ANONYMOUS_AUTHORIZED_KEYS}"
}
