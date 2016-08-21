#!/bin/sh
ssh-keygen -A
echo "${AUTHORIZED_KEYS}" > /home/git/.ssh/authorized_keys
exec "$@"