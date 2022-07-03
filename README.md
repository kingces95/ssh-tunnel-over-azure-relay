# Virtual Private Tunnel
Issue an `az` https request behind a firewall using Azure Relay.

# Server codespace
Open a codespace for this repo and launch a bash shell. 
```
$ . vpt.sh
$ vpt-azbridge-remote-start
```
# Client codespace
Open a codespace for this repo and launch a bash shell.
```
$ . vpt.sh
$ vpt-azbridge-local-start
```
Then, in a new bash window, start the proxy
```
$ . vpt.sh
$ vpt-ssh-azure-relay-proxy-start
```
Then, in a new bash window, enable the proxy and use it
```
$ . vpt.sh
$ vpt-az-proxy-enable
$ vpt-demo
```
Finally, to prove the proxy is in use over the relay, exit the proxy and/or the relay try the request again.
