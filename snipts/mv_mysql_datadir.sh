#!/usr/bin/env bash

if [ "$(id -u)" != "0" ]; then
   echo "You must run as root!" 1>&2
   exit 1
fi

service mysql stop
cp -R -p /var/lib/mysql /home/ball6847/webstack/data/
sed -i "s/\/var\/lib\mysql/\/home\/ball6847\/webstack\/data\/mysql/g" /etc/mysql/my.cnf
sed -i "s/\/var\/lib\mysql/\/home\/ball6847\/webstack\/data\/mysql/g" /etc/apparmor.d/usr.sbin.mysqld
service apparmor reload
service mysql start