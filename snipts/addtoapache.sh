#!/usr/bin/env bash

if [ "$(id -u)" != "0" ]; then
   echo "You must run as root!" 1>&2
   exit 1
fi

# disable default site if currently enabled
if [[ -e "/etc/apache2/sites-enabled/default" ]]; then
    tobedisabled="$tobedisabled default"
fi

if [[ -e "/etc/apache2/sites-enabled/000-default.conf" ]]; then
    tobedisabled="$tobedisabled 000-default"
fi

if [ "$(echo $tobedisabled | tr -d ' ')" != "" ]; then
    echo "Disabling sites, $tobedisabled."
    a2dissite $tobedisabled
fi

# apache2 now use conf-available instead of conf.d
configdir="/etc/apache2/conf-available/"

if [[ ! -d "$configdir" ]]; then
    if [[ ! -d "/etc/apache2/conf.d" ]]; then
        echo "" 1>&2
        exit 1
    fi
    configdir="/etc/apache2/conf.d/"
fi

echo "Apache config dir = $configdir"

if [[ $configdir = "/etc/apache2/conf-available/" ]] && [[ ! -f "/etc/apache2/conf-enabled/webstack.conf" ]]; then
    a2enmod proxy proxy_http rewrite
    a2enconf webstack.conf
fi

# if it's not already in its place
if [[ ! -f $configdir"webstack.conf" ]]; then
    echo "Adding webstack config."
    ln -s /home/ball6847/webstack/etc/apache2/webstack.conf $configdir
    service apache2 restart
fi

echo "Webstack should work now."
