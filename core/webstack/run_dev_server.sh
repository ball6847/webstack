#!/usr/bin/env bash

# check root permission, use sudo only!
if [[ $SUDO_USER = "" ]]; then
    echo "error: root permission required, try using \"sudo $0\""
    exit 0
fi

# get neccessary directory detail
USER_HOME="$(getent passwd $SUDO_USER | cut -d: -f6)"
DIR="$(cd "$(dirname "$0")" && pwd)"
VIRTUALENV="$USER_HOME/.virtualenvs/webstack"

"$VIRTUALENV/bin/python" "$DIR/manage.py" runserver