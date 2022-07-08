alias vpt-test='vpt::test'
alias vpt-test-full='vpt::test::full'
alias vpt-create-bridge='vpt::create_bridge'
alias vpt-start-remote='vpt::start_remote'
alias vpt-start-local='vpt::start_local'
alias vpt-start-proxy='vpt::start_proxy'
alias vpt-demo='vpt::demo'
alias vpt-stop-jobs='vpt::stop_jobs'
alias vpt-delete-bridge='vpt::delete_bridge'

vpt::create_bridge() {
    vpt::tool::az::install

    # create bridge
    vpt::azure::group::create
    vpt::azure::relay::create
}

vpt::start_remote() {
    vpt::tool::nc::install
    vpt::tool::azbridge::install
    
    # add anonymous user
    vpt::anonymous::adduser
    vpt::anonymous::key::install
        
    # start server
    # vpt::ssh::start

    # start remote bridge
    vpt::azbridge::remote::start::async
}

vpt::start_local() {
    vpt::tool::nc::install

    # start local bridge
    vpt::azbridge::local::start::async
}

vpt::start_proxy() {
    # add private key for anonymous
    vpt::ssh::key::install

    # start proxy
    vpt::ssh::azure::relay::proxy::start::async
}

vpt::demo() {
    vpt::az::proxy group show \
        --name "${VPT_AZURE_GROUP}"
}

vpt::stop_jobs() {
    while kill -9 % >/dev/null 2>&1; do
        sleep 1
    done
}

vpt::delete_bridge() {
    vpt::azure::relay::delete
}

# https://www.alibabacloud.com/help/en/elastic-compute-service/latest/change-the-tcp-time-wait-timeout-period
# echo 5 > /proc/sys/net/ipv4/tcp_tw_timeout
# netstat -nat | grep TIME_WAIT
# sudo netstat -ltnp | grep 222
# ps -aux | grep azbridge

vpt::ipv6::disable() {
    # https://itsfoss.com/disable-ipv6-ubuntu-linux/
    sudo sysctl -w net.ipv6.conf.all.disable_ipv6=1
    sudo sysctl -w net.ipv6.conf.default.disable_ipv6=1
    sudo sysctl -w net.ipv6.conf.lo.disable_ipv6=1
    ip a
}

vpt::inspect() {
    vpt-test
    sudo netstat -natp | grep azbridge
    sudo netstat -ltnp | grep 2223
    sudo netstat -a | grep 2223
    while sudo netstat -ap | grep 2223; do sleep 1; done
    sudo netstat -ltnp | grep LISTEN
    sudo lsof -i -p 2223 | grep 2223
    sudo lsof -i -p 2222 | grep 2222
    sudo netstat -nat | grep TIME_WAIT
    killall -9 azbridge
    ps -aux | grep azbridge
    jobs
}

vpt::test() {
    echo 'vpt-start-remote'
    vpt-start-remote

    echo 'vpt-start-local'
    vpt-start-local

    echo 'vpt-start-proxy'
    # vpt::ssh::azure::relay::proxy6::start::async
    vpt-start-proxy

    echo 'vpt-demo'
    vpt-demo

    echo 'vpt-stop-jobs'
    ps -aux | grep azbridge
    ps -aux | grep ssh
    sudo netstat -ap | grep 2222
    sudo netstat -ap | grep 2223
    sudo lsof -i -p 2223 | grep 2223
    sudo netstat -ap | grep 2224
    vpt-stop-jobs
    ps -aux | grep azbridge
    ps -aux | grep ssh
    sudo netstat -ap | grep 2222
    sudo netstat -ap | grep 2223
    sudo lsof -i -p 2223 | grep 2223
    sudo netstat -ap | grep 2224
}
