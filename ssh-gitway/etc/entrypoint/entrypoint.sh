#!/bin/sh
cd /etc/ssh/
[ ! -e ssh_host_ed25519_key2 ] && ssh-keygen -t ed25519 -f ssh_host_ed25519_key2 -N ''
[ ! -e ssh_host_rsa_key ] && ssh-keygen -t rsa -b 4096 -f /etc/ssh/ssh_host_rsa_key -N ''
echo "export TARGET_SSH_PORT='${TARGET_SSH_PORT}'" > /etc/entrypoint/rc
echo "export DEBUG='${DEBUG}'" >> /etc/entrypoint/rc
exec "$@"
