#! /usr/bin/env bash

if [[ "$SUDO_USER" = "" ]]; then
    echo "error: try using \"sudo $0\""
    exit 1
fi

# get neccessary directory detail
export USER_HOME="$(getent passwd $SUDO_USER | cut -d: -f6)"
export WEBSTACK_ROOT="$(cd "$(dirname "$0")" && cd .. && pwd)"
export SUPERVISOR_CONFD="/etc/supervisor/conf.d"
export VIRTUALENV="$USER_HOME/.virtualenvs/webstack"