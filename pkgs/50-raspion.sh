#!/bin/bash
###
# c't-Raspion, a Raspberry Pi based all in one sniffer
# for judging on IoT and smart home devices activity
# (c) 2019-2020 c't magazin, Germany, Hannover
# see: https://ct.de/-123456 for more information
# 
# file          : pkgs/50-raspion.sh
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
###

set -e

#change to buildir and build
cd ${PKG_PATH}/raspion-1.1.0

runPriv apt-get build-dep .
dch --force-distribution --distribution $DCH_DISTRIBUTION --rebuild "$DCH_CHANGELOG"

dpkg-buildpackage -uc -us

#Copy alle files
mv ${PKG_PATH}*.deb ${PKG_PATH}*.dsc ${PKG_PATH}*.tar.xz ${PKG_PATH}*.changes $RSD_CWD/development/repository/

