. shim.sh

# start server
vpt-anonymous-create
vpt-ssh-start

# create bridge
vpt-tool-az-install
vpt-az-login
vpt-azure-group-create
vpt-azure-relay-create

# start bridge
vpt-tool-azbridge-install
vpt-azbridge-remote-start-async
vpt-azbridge-local-start-async; sleep 1

# start proxy
vpt-ssh-azure-relay-proxy-start-async; sleep 1

# az requets over proxy
vpt-demo

# stop bridge and proxy
kill %+; sleep 1
kill %+; sleep 1
kill %+

vpt-azure-relay-delete
