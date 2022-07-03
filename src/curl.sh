alias vpt-myip-curl='vpt::myip::curl'
alias vpt-myip-proxy-curl='vpt::myip::proxy::curl'

vpt::myip::curl() {
    curl "${VPT_MYIP}"
    echo
}

vpt::myip::proxy::curl() {
    vpt::ssh::proxy::curl "${VPT_MYIP}"
    echo
}
