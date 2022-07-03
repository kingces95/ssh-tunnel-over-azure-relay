. shim.sh

(
    echo 'vpt-start-remote'
    vpt-start-remote > /tmp/remote.log

    echo 'vpt-start-local'
    vpt-start-local > /tmp/local.log

    echo 'vpt-demo'
    vpt-demo

    echo 'vpt-stop-jobs'
    vpt-stop-jobs

    echo 'vpt-delete-bridge'
    vpt-delete-bridge

    echo 'Success!'
)
