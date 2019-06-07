#!/usr/bin/env bash

# Ask for the administrator password upfront.
sudo -v

if [ -n "$(uname -a | grep Ubuntu)" ]; then
    IS_UBUNTU=true
else
    IS_UBUNTU=false
fi

# Packages to install on all targets.
COMMON_SERVER_PACKAGES="
bash
colordiff
emacs
git
git-extras
graphviz
ImageMagick
wget
"

# Packages to install on Ubuntu only.
UBUNTU_SERVER_PACKAGES="
python-dev
python-pip
"

# Packages to install on Centos only.
CENTOS_SERVER_PACKAGES="
epel-release
python-devel
python-pip
"

# Python packages to install from PyPi on all targets.
UBUNTU_PYTHON_PACKAGES="
pip
jupyter
setuptools
"

CENTOS_PYTHON_PACKAGES="
python-pip
python-wheel
jupyter
python-setuptools
"

# Install all software first.
if $IS_UBUNTU; then
    source ./scripts/ubuntu-server-install.sh
else
    source ./scripts/centos-server-install.sh
fi

# Install & upgrade python modules
if $IS_UBUNTU; then
    PYTHON_PACKAGE=$UBUNTU_PYTHON_PACKAGES
else
    PYTHON_PACKAGE=$CENTOS_PYTHON_PACKAGES
fi

for p in $PYTHON_PACKAGES
do
    pip install --upgrade "$p"
done
