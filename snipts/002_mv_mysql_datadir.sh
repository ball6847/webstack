#!/usr/bin/env bash

source "$(dirname $0)/000_webstack.sh"

OLDDATA="/var/lib/mysql"
DATA_DIR="$WEBSTACK_ROOT/data"

service mysql stop
cp -R -p $OLDDATA $DATA_DIR

sed -i "s,$OLDDATA,$DATA_DIR/mysql,g" "/etc/mysql/my.conf"
sed -i "s,$OLDDATA,$DATA_DIR/mysql,g" "/etc/apparmor.d/usr.sbin.mysqld"

service apparmor reload
service mysql start