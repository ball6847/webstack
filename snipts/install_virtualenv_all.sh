#!/usr/bin/env bash

# permission checking
if [ "$SUDO_USER" = "" ]; then
   echo "You must run as root!, try using \"sudo $0\"" 1>&2
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
" >> $HOME/.bash_aliases
