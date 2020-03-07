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
# date          : 2020014
# notes         : runs and builds 
#               : install and builded Package not tested
###


set -e

RSD_VER=0.1.0
RSD_CWD=$(pwd)
RSD_ARGS=$@
RSD_USER=$EUID

RSD_ARCH=$(dpkg --print-architecture)
RSD_DIST="raspion"
RSD_REPO="development/repository"

RSD_REQPACKAGES="build-essential debhelper dh-make quilt fakeroot lintian devscripts config-package-dev"
RSD_APTARGS="--no-install-recommends -y"

DEBFULLNAME="RSD Script"
DEBEMAIL="pi@raspberry"

# Comments for builded Debian Packages
DCH_CHANGELOG="Initial RSD Build"

source scripts/functions.sh

#check for armhf
if [ "$RSD_ARCH" != "armhf" ] ; then 
    logger "No armhf-Arch - crossbuilding is actually not supported" "ERR"
    exit 1
fi

#TODO check args
case $1 in 
    prepare)
        RSD-Prepare
    ;;
    build)
        RSD-Build $2
    ;;
        buildrepository)
	    RSD-BuildRepository
    ;;
    install)
        RSD-Install
    ;;
    all)
	    RSD-Prepare
	    RSD-Build
	    RSD-BuildRepository
	    RSD-Install
	;;
    help|*)
        echo "rsd.sh - Spy-Academy for c't raspion"
        echo "./rsd.sh all - Executes all options below"
        echo "./rsd.sh prepare - Installs Depencies for building raspion"
        echo "./rsd.sh build - Builds packages under pkg/"
        echo "./rsd.sh buildrepository - Builds and setup the local apt-repository"
        echo "./rsd.sh install - just runs release/install.sh"
        ;;
esac


