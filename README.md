# ssh-tunnel-over-azure-relay
Establish an SSH tunnel over an azure relay created with azbridge between two codespaces.

# Server codespace
Enter your Azure tenant and subscription when prompted. The Azure relay will automatically be created.
```
$ . launch.sh server
Tenant id:
Subscription id:
Relay: https://ms.portal.azure.com/deep/link/to/relay
Starting ssh server ...
Starting azbridge server...
```
# Client codespace
Enter your Azure tenant and subscription when prompted.
```
$ . launch.sh client
Tenant id:
Subscription id:
Relay: https://ms.portal.azure.com/deep/link/to/relay
Starting azbridge client...
```
Then, in a new bash window
```
$ . launch.sh ssh
```