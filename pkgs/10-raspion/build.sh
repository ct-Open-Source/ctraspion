#!/bin/bash
###
# c't-Raspion, a Raspberry Pi based all in one sniffer
# for judging on IoT and smart home devices activity
# (c) 2019-2020 c't magazin, Germany, Hannover
# see: https://ct.de/-123456 for more information
# 
# file          : pkgs/10-raspion.sh
# description   : build the main package - raspion.deb
# version       : 0.1
#       
# changes         
# author		: Benny Stark - github.com/Diggen85
# date          : 2020010
# notes         : Initial - untested
#               : needs version-infos and increment
# date          : 2020014
# notes         : runs and builds
# date          : 20200120
# notes         : add logger
#               : outsource code to functions
###

set -e

#change to buildir and build
cd ${PKG_PATH}/raspion-1.1.0

logger "install build-dep"
runPriv apt-get build-dep .

logger "change version"
dch --force-distribution --distribution $RSD_DIST  --rebuild "$DCH_CHANGELOG"
dpkg-buildpackage -uc -us

#Add Files to Repro
logger "add packages to repository"
addToRepo ${PKG_PATH}*.deb

#clean
#TODO add src Repo
rm ${PKG_PATH}*deb ${PKG_PATH}*dsc ${PKG_PATH}*tar.* ${PKG_PATH}*changes ${PKG_PATH}*buildinfo	

