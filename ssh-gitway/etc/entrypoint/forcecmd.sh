#!/bin/sh
#set -o nounset
set -o errexit

. /etc/entrypoint/rc

if [ "$FORCE_GIT_USER" -ne "0" ]; then
  # Fix the user name and take the USER variable as the target container
  TARGET_USER="git"
  CONTAINER_LINK="${USER}"
else
  # Split the username on the last + token and use the first part as the name and the second part as the target
  TARGET_USER="$(echo ${USER} | cut -d '+' -f 1)"
  CONTAINER_LINK="$(echo ${USER} | cut -d '+' -f 2-)"

  #TODO: Harden this logic to ensure neither variable is unset
fi

# If the SSH Cmd is NOT set, send back the motd file
# Otherwise, jump to the next SSH host forwarding the command
${SSH_ORIGINAL_COMMAND:-cat /etc/motd} || \
ssh -q -t -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -p ${TARGET_SSH_PORT:-2022} "${TARGET_USER}@${CONTAINER_LINK}" "${SSH_ORIGINAL_COMMAND}"
