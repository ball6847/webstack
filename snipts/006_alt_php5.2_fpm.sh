#! /usr/bin/env bash

if [[ "$SUDO_USER" = "" ]]; then
    echo "error: try using \"sudo $0\""
    exit 1
fi

install_prefix="/usr/local/php-5.2.17-fpm"

# dependencies
command="apt-get -y install libxml2-dev
    libcurl4-openssl-dev
    libmysqlclient-dev
    libtidy-dev
    libmcrypt-dev
    zlib1g-dev
    libjpeg62-dev
    libpng12-dev
    libfreetype6-dev
	libapache2-mod-fastcgi"
	
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
libmysqlclient="$(/sbin/ldconfig -p | grep libmysqlclient | cut -d\> -f2 | sed -n 1p)"

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

# download source code if neccessary
if [[ ! -d "php-5.2.17" ]]; then
    wget http://museum.php.net/php5/php-5.2.17.tar.gz
fi

# we need a clean sourcecode
if [[ -d php-5.2.17 ]]; then
    rm -rf php-5.2.17
    tar zxf php-5.2.17.tar.gz
fi

# fpm
wget http://php-fpm.org/downloads/php-5.2.17-fpm-0.5.14.diff.gz
gzip -cd php-5.2.17-fpm-0.5.14.diff.gz | patch -d php-5.2.17 -p1

cd php-5.2.17

# ==================================================
# apply bugs patch
# ==================================================

# libxml
wget https://mail.gnome.org/archives/xml/2012-August/txtbgxGXAvz4N.txt
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
	--enable-fpm
	--enable-fastcgi
	--with-apc
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
make install

# init script
cp sapi/cgi/fpm/php-fpm /etc/init.d/
mv /etc/init.d/php-fpm /etc/init.d/php-fpm-5.2
chmod +x /etc/init.d/php-fpm-5.2

# php.ini
cp /usr/local/src/php-5.2.17/php.ini-recommended $install_prefix/
mv $install_prefix/php.ini-recommended $install_prefix/php.ini

# supervisor config
if [[ -d /etc/supervisor/conf.d ]]; then

	echo "
[program:php-fpm-5.2]
command=/usr/local/php-5.2.17-fpm/bin/php-cgi --fpm --fpm-config /usr/local/php-5.2.17-fpm/etc/php-fpm.conf
process_name=php-fpm-5.2
redirect_stderr=true
stopasgroup=true
" > /etc/supervisor/conf.d/php-fpm-5.2.conf

fi

# apache config

if [[ -d /etc/apache2/conf.d ]]; then
	
	echo "
<IfModule mod_fastcgi.c>
    AddHandler php-fpm-5.2.17 .php
    Action php-fpm-5.2.17 /php-fpm-5.2.17
    Alias /php-fpm-5.2.17 /usr/lib/cgi-bin/php-fpm-5.2.17

    # AddHandler fast2car/dev/php-fpm .php
    FastCgiExternalServer /usr/lib/cgi-bin/php-fpm-5.2.17 -host localhost:9000 -pass-header Authorization -idle-timeout 900 
</IfModule>

# add this directive to your desired VirtualHost
#<FilesMatch \.php$>
#    SetHandler php-fpm-5.2.17
#</FilesMatch>
" > /etc/apache2/conf.d/php-fpm-5.2.conf

fi

a2enmod fastcgi actions

echo "Restart apache to make it take effect"

