#!/usr/bin/env bash

# change this your home
USER_HOME="/home/ball6847"

# permission checking
if [ "$(id -u)" != "0" ]; then
   echo "You must run as root!" 1>&2
   exit 1
fi

# if you don't have pip or easy_install
wget https://bitbucket.org/pypa/setuptools/raw/bootstrap/ez_setup.py -O - | python
easy_install pip

# install virtualenv and virtualenvwrapper
pip install virtualenv
pip install virtualenvwrapper

# setup virtualenvwrapper
echo "
export WORKON_HOME="\$HOME/.virtualenvs"
source /usr/local/bin/virtualenvwrapper.sh
" >> $USER_HOME/.bashrc