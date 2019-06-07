#!/usr/bin/env bash

sudo yum update -y

# Install common packages
for p in $COMMON_SERVER_PACKAGES
do
    sudo yum install -y "$p"
done

sudo yum install -y $CENTOS_SERVER_PACKAGES

