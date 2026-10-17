#!/bin/sh
# The panel mounts /data as root:root; fix that, then run as the same
# unprivileged uid the upstream image uses.
set -e
mkdir -p /data
if [ "$(id -u)" = "0" ]; then
  chown 65532:65532 /data 2>/dev/null || true
  exec setpriv --reuid=65532 --regid=65532 --clear-groups \
    /usr/local/bin/figcraft-server --listen 0.0.0.0:47900 --data /data
fi
exec /usr/local/bin/figcraft-server --listen 0.0.0.0:47900 --data /data
