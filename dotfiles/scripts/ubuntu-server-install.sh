#!/usr/bin/env bash

sudo apt update -y

# Install common packages
for p in $COMMON_SERVER_PACKAGES
do
    sudo apt install -y "$p"
done

sudo apt install -y $UBUNTU_SERVER_PACKAGES
