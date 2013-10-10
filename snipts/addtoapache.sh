#!/usr/bin/env bash

if [ "$(id -u)" != "0" ]; then
   echo "You must run as root!" 1>&2
   exit 1
fi

a2dissite default
ln -s /home/ball6847/webstack/etc/apache2/webstack.conf /etc/apache2/conf.d/
service apache2 restart