#! /usr/bin/env bash

if [[ "$SUDO_USER" = "" ]]; then
    echo "error: try using \"sudo $0\""
    exit 1
fi

# dependencies
command="apt-get -y install libxml2-dev
    libcurl4-openssl-dev
    libmysqlclient-dev
    libtidy-dev
    libmcrypt-dev
    zlib1g-dev
    libjpeg62-dev
    libpng12-dev
    libfreetype6-dev"

$command

if [[ "$?" > 0 ]]; then
    echo "error: there was error while installing dependencies"
    echo "command:"
    echo "$command"
    echo
    exit 1
fi

# tracking lib error
lib_error=0

apxs2="$(which apxs2)"
libmysqlclient="$(/sbin/ldconfig -p | grep libmysqlclient | cut -d\> -f2 | sed -n 1p)"

if [[ $apxs2 = "" ]]; then
    echo "error: not found apxs2 in your system"
    echo "hint: You need apache2-prefork-dev package"
    lib_error = 1
fi

if [[ $libmysqlclient = "" ]]; then
    echo "error: not found libmysqlclient in your system"
    echo "hint: You need libmysqlclient-dev package"
    lib_error = 1
fi

# stop on lib error
if [[ $lib_error = 1 ]]; then
    exit 1
fi

libmysqlclient=$(echo $libmysqlclient)
libdir=$(dirname $libmysqlclient)

# ==================================================
# php cannot find these .so files
# we need to create symbolic link to work around
# ==================================================

if [[ ! -f "/usr/lib/libmysqlclient.so" ]]; then
    ln -s "$libmysqlclient" "/usr/lib/libmysqlclient.so"
fi

if [[ ! -f "/usr/lib/libjpeg.so" ]]; then
    ln -s "$libdir/libjpeg.so" "/usr/lib/libjpeg.so"
fi

if [[ ! -f "/usr/lib/libpng.so" ]]; then
    ln -s "$libdir/libpng.so" "/usr/lib/libpng.so"
fi

cd /usr/local/src

install_prefix="/usr/local/php-5.2.17"

# download source code if neccessary
if [[ ! -d "php-5.2.17" ]]; then
    wget http://museum.php.net/php5/php-5.2.17.tar.gz
fi

# we need a clean sourcecode
if [[ -d php-5.2.17 ]]; then
    rm -rf php-5.2.17
    tar zxf php-5.2.17.tar.gz
fi

cd php-5.2.17

# ==================================================
# apply bugs patch
# ==================================================

# libxml
wget "https://mail.gnome.org/archives/xml/2012-August/txtbgxGXAvz4N.txt"
patch -p0 -b < "txtbgxGXAvz4N.txt"

# openssl
wget "https://bugs.php.net/patch-display.php?bug_id=54736&patch=debian_patches_disable_SSLv2_for_openssl_1_0_0.patch&revision=1305414559&download=1" -O "debian_patches_disable_SSLv2_for_openssl_1_0_0.patch"
patch -p1 < debian_patches_disable_SSLv2_for_openssl_1_0_0.patch

# ==================================================
# ./configure
# ==================================================

configure_command="\
./configure --prefix=$install_prefix
    --enable-mbstring
    --enable-zip
    --with-apc
    --with-apxs2=$apxs2
    --with-gd
    --with-jpeg-dir=/usr
    --with-png-dir=/usr
    --with-freetype-dir=/usr
    --enable-gd-native-ttf
    --with-mysql
    --with-config-file-path=$install_prefix
    --with-curl
    --with-openssl
    --with-tidy
    --with-pdo-mysql
    --with-mysqli
    --with-mcrypt
    --with-zlib"

$configure_command

if [[ "$?" > 0 ]]; then
    echo "error: there was error while configuring php, it's mostly a dependencies problem, check output for error message"
    echo "configure command:"
    echo "$configure_command"
    echo
    exit 1
fi

# ==================================================
# do compile and install files
# ==================================================

make

# before install all files we need to backup libphp5.so before it will be overwriten
if [[ -f /usr/lib/apache2/modules/libphp5.so ]]; then
    mv /usr/lib/apache2/modules/libphp5.so /usr/lib/apache2/modules/~libphp5.so
fi

# install all php 5.2.17 files
make install

# rename to our version
if [[ -f /usr/lib/apache2/modules/libphp5.so ]]; then
    mv /usr/lib/apache2/modules/libphp5.so /usr/lib/apache2/modules/libphp5.2.17.so
fi

# restore previous libphp5.so file
if [[ -f /usr/lib/apache2/modules/~libphp5.so ]]; then
    mv /usr/lib/apache2/modules/~libphp5.so /usr/lib/apache2/modules/libphp5.so
fi

# apache module loader
echo "
LoadModule php5_module        /usr/lib/apache2/modules/libphp5.2.17.so
" > /etc/apache2/mods-available/php5.2.17.load

# php5 module config file
echo "
<FilesMatch \".+\.ph(p[345]?|t|tml)\$\">
    SetHandler application/x-httpd-php
</FilesMatch>
<FilesMatch \".+\.phps\$\">
    SetHandler application/x-httpd-php-source
    # Deny access to raw php sources by default
    # To re-enable it's recommended to enable access to the files
    # only in specific virtual host or directory
    Order Deny,Allow
    Deny from all
</FilesMatch>
# Deny access to files without filename (e.g. '.php')
<FilesMatch \"^\.ph(p[345]?|t|tml|ps)\$\">
    Order Deny,Allow
    Deny from all
</FilesMatch>

# Running PHP scripts in user directories is disabled by default
#
# To re-enable PHP in user directories comment the following lines
# (from <IfModule ...> to </IfModule>.) Do NOT set it to On as it
# prevents .htaccess files from disabling it.
<IfModule mod_userdir.c>
    <Directory /home/*/public_html>
        php_admin_value engine Off
    </Directory>
</IfModule>
" > /etc/apache2/mods-available/php5.2.17.conf

