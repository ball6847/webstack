#!/usr/bin/env bash

source "$(dirname $0)/000_webstack.sh"

DATA_DIR="$WEBSTACK_ROOT/data"
DATA_DIR_ESC="$(echo "$DATA_DIR" | sed 's/\//\\\//g')"

service mysql stop
cp -R -p /var/lib/mysql $DATA_DIR

echo "<?php
\$file = '/etc/mysql/my.cnf';
\$content = file_get_contents(\$file);
\$content = str_replace('/var/lib/mysql', '$DATA_DIR/mysql', \$content);
file_put_contents(\$file, \$content);
" | php

echo "<?php
\$file = '/etc/apparmor.d/usr.sbin.mysqld';
\$content = file_get_contents(\$file);
\$content = str_replace('/var/lib/mysql', '$DATA_DIR/mysql', \$content);
file_put_contents(\$file, \$content);
" | php

service apparmor reload
service mysql start
