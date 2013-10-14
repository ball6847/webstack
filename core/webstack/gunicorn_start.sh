#!/usr/bin/env bash

if [ "$(id -u)" != "0" ]; then
   echo "You must run as root!" 1>&2
   exit 1
fi

gunicorn --daemon --name webstack --bind 127.0.0.1:6847 project.wsgi:application