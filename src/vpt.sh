alias vpt-create-bridge='vpt::create_bridge'
alias vpt-start-remote='vpt::start_remote'
alias vpt-start-local='vpt::start_local'
alias vpt-demo='vpt::demo'
alias vpt-stop-jobs='vpt::stop_jobs'
alias vpt-delete-bridge='vpt::delete_bridge'

vpt::create_bridge() {
    vpt::tool::az::install
    vpt::az::login

    # create bridge
    vpt::azure::group::create
    vpt::azure::relay::create
}

vpt::start_remote() {
    vpt::tool::azbridge::install
    
    # add anonymous user
    vpt::anonymous::adduser
    vpt::anonymous::key::install
        
    # start server
    vpt::ssh::start

    vpt::create_bridge

    # start remote bridge
    vpt::azbridge::remote::start::async
}

vpt::start_local() {
    vpt::create_bridge

    # start local bridge
    vpt::azbridge::local::start::async

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
    while kill %; do
        sleep 1
    done
}

vpt::delete_bridge() {
    vpt::azure::relay::delete
}
