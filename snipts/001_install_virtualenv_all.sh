#!/usr/bin/env bash

source "$(dirname $0)/000_webstack.sh"

# if you don't have pip or easy_install
wget https://bitbucket.org/pypa/setuptools/raw/bootstrap/ez_setup.py -O - | python
easy_install pip
rm -f setuptools-*.tar.gz

# install virtualenv and virtualenvwrapper
pip install virtualenv
pip install virtualenvwrapper

# setup virtualenvwrapper
echo "
export WORKON_HOME="\$HOME/.virtualenvs"
source /usr/local/bin/virtualenvwrapper.sh
" >> $HOME/.bash_aliases