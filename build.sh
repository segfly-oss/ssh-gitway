#!/usr/bin/env bash
shopt -s expand_aliases

ROCKER_VERSION='segfly/rocker:1.3.0a'

# Do not use the --rm flag with Circle CI https://discuss.circleci.com/t/docker-error-removing-intermediate-container
if [ -z "${CIRCLECI+x}" ]; then
  alias rocker='docker run -v /var/run/docker.sock:/var/run/docker.sock -v ${HOME}/.rocker_cache:/root/.rocker_cache -v $(pwd):/build -it --rm ${ROCKER_VERSION}'
else
  alias rocker='docker run -v /var/run/docker.sock:/var/run/docker.sock -v ${HOME}/.rocker_cache:/root/.rocker_cache -v $(pwd):/build -t ${ROCKER_VERSION}'
fi

set -o nounset
set -o errexit
set -o xtrace

# Show info for rocker
rocker --version

# Build the sample git server
rocker build -f ssh-gitway/Dockerfile
rocker build -f sample-git-server/Dockerfile
