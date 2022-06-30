# ssh-tunnel-over-azure-relay
Establish an SSH tunnel over an azure relay created with azbridge between two codespaces.

# Server codespace
```
$ . launch.sh server
```
# Client codespace
```
$ . launch.sh client
```
Then, in a new bash window
```
$ . launch.sh ssh
```