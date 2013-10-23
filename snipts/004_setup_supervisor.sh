#!/usr/bin/env bash

source "$(dirname $0)/000_webstack.sh"

# print detected directory to user
echo "USER_HOME=$USER_HOME"
echo "WEBSTACK_ROOT=$WEBSTACK_ROOT"

# check gunicorn startup script
if [[ ! -f "$WEBSTACK_ROOT/core/webstack/gunicorn_start.sh" ]]; then
    echo "error: not found gunicorn startup script at $WEBSTACK_ROOT/core/webstack/gunicorn_start.sh"
    exit 1
fi

# check webstack virtualenv directory
if [[ ! -d "$VIRTUALENV/bin" ]]; then
    echo "error: not found .virtualenvs/webstack/bin directory in $USER_HOME"
    exit 1
fi

# try to install Supervisor
if [[ $(apt-cache policy supervisor | grep "Installed: (none)") ]]; then
    echo "Installing Supervisor"
    
    # install supervisor package
    if [[ ! $(apt-get -y -q install supervisor) ]]; then
        echo "Cannot install Supervisor"
        exit 1
    fi
else
    echo "skip: Supervisor already installed on your system"
    
    if [[ -f "$SUPERVISOR_CONFD/webstack.conf" ]]; then
        read -p "warning: Your previous configuration will be overwritten, are you sure with this? (y/n)" -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            echo "OK, exit"
            exit 1
        fi
    fi
fi

# create error log file for supervisor
if [[ ! -f "$WEBSTACK_ROOT/logs/core/supervisor.log" ]]; then
    su $SUDO_USER -c "touch $WEBSTACK_ROOT/logs/core/supervisor.log"
fi

echo "Configuring webstack for supervisor"

# generate config file using provided template
webstackconf="$(cat $WEBSTACK_ROOT/etc/templates/webstack_supervisor.conf)"
webstackconf="${webstackconf//\{\{ WEBSTACK_ROOT \}\}/$WEBSTACK_ROOT}"
webstackconf="${webstackconf//\{\{ VIRTUALENV \}\}/$VIRTUALENV}"
webstackconf="${webstackconf//\{\{ PATH \}\}/$PATH}"
echo "$webstackconf" > "$SUPERVISOR_CONFD/webstack.conf"

echo "success: Webstack supervisor configuration saved at $SUPERVISOR_CONFD/webstack.conf"

# end setup_supervisor.sh #