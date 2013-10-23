#!/usr/bin/env bash

source "$(dirname $0)/000_webstack.sh"

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

# try checking for old conf.d dir
if [[ ! -d "$configdir" ]]; then
    if [[ ! -d "/etc/apache2/conf.d" ]]; then
        echo "" 1>&2
        exit 1
    fi
    configdir="/etc/apache2/conf.d/"
fi

echo "Apache config dir = $configdir"

# generate config file using provided template
webstackconf="$(cat $WEBSTACK_ROOT/etc/templates/webstack_apache2.conf)"
echo "${webstackconf//\{\{ WEBSTACK_ROOT \}\}/$WEBSTACK_ROOT}" > $WEBSTACK_ROOT/etc/apache2/webstack.conf

# for apache2.4, check if webstack.conf is already in conf directory or if it already enabled
if [[ $configdir = "/etc/apache2/conf-available/" ]] && [[ ! -f "/etc/apache2/conf-enabled/webstack.conf" ]]; then
    a2enconf webstack.conf
fi

# enable module required for webstack
a2enmod proxy proxy_http rewrite

# if it's not already in its place
if [[ ! -f $configdir"webstack.conf" ]]; then
    echo "Adding webstack config."
    ln -s "$WEBSTACK_ROOT/etc/apache2/webstack.conf" "$configdir"
fi

# make it takes effect
service apache2 restart

echo "Webstack should work now."
