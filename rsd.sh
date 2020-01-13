#!/bin/bash
###
# c't-Raspion, a Raspberry Pi based all in one sniffer
# for judging on IoT and smart home devices activity
# (c) 2019-2020 c't magazin, Germany, Hannover
# see: https://ct.de/-123456 for more information
# 
# file          : rsd.sh
# description   : main script for easy building of raspion
#               : setup environment, build packages, installs
#               : more to come
# version       : 0.1
#       
# changes         
# author		: Benny Stark - github.com/Diggen85
# date          : 2020011
# notes         : Initial - untested
###


set -e

RSD_VER=0.1.0
RSD_CWD=$(pwd)
RSD_ARGS=$@
RSD_USER=$EUID
RSD_ARCH=$(dpkg --print-architecture)
RSD_REQPACKAGES="build-essentials debhelper dh-make quilt fakeroot lintian devscripts config-package-dev"

source scripts/functions.sh

#check for armhf
if [ "$RSD_ARCH" != "armhf" ] ; then {
    logger "No armhf-Arch - crossbuilding is actually not supported" "ERR"
    exit 1
}

#check args
    #print out scripts/commands
    #run arg
case $1 in 
    prepare)
        RSD-Prepare
    ;;
    build)
        RSD-Build $2
    ;;
    install)
        RSD-Install
    ;;
    help|*)
     echo "HELP ME"
    ;;
esac


