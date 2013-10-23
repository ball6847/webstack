#!/usr/bin/env bash

# check root permission, use sudo only!
if [[ $SUDO_USER = "" ]]; then
    echo "error: root permission is required, try using \"sudo $0\"" 1>&2
    exit 0
fi

# get neccessary directory detail
USER_HOME="$(getent passwd $SUDO_USER | cut -d: -f6)"
WEBSTACK_ROOT="$(cd "$(dirname "$0")" && cd .. && pwd)"
SUPERVISOR_CONFD="/etc/supervisor/conf.d"
VIRTUALENV="$USER_HOME/.virtualenvs/webstack"

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

# save configuration to file
echo "[program:webstack]
command=$VIRTUALENV/bin/python $VIRTUALENV/bin/gunicorn --name webstack --bind 127.0.0.1:6847 --error-logfile \"$WEBSTACK_ROOT/logs/core/gunicorn.log\" --log-level warning project.wsgi:application
directory=$WEBSTACK_ROOT/core/webstack
environment=PATH=\"$USER_HOME/.virtualenvs/webstack/bin:$PATH\"
process_name=webstack
redirect_stderr=true
stdout_logfile=$WEBSTACK_ROOT/logs/core/supervisor.log
stopasgroup=true  " > "$SUPERVISOR_CONFD/webstack.conf"

echo "success: Webstack supervisor configuration saved at $SUPERVISOR_CONFD/webstack.conf"

# end setup_supervisor.sh #