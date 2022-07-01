# ssh-tunnel-over-azure-relay
Issue an `az` https request behind a firewall using Azure Relay.

# Server codespace
Open a codespace for this repo and launch a bash shell. 
```
$ . vpt.sh
$ vpt-azure-relay-remote-start
```
# Client codespace
Open a codespace for this repo and launch a bash shell.
```
$ . vpt.sh
$ vpt-azure-relay-local-start
```
Then, in a new bash window, start the proxy
```
$ . vpt.sh
$ vpt-azure-relay-proxy-start
```
Then, in a new bash window, enable the proxy and use it
```
$ . vpt.sh
$ vpt-azure-proxy-enable
$ vpt-azure-group-show
```
Finally, to prove the proxy is in use over the relay, exit the proxy and/or the relay try the request again.
