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
###

source scripts/functions.sh


#change to buildir and build
cd pkgs/50-raspion/raspion-1.1.0-RSD
runPriv apt-get build-dep
dch -i
dpkg-buildpackage -uc -us

#Copy alle files
mv 50-raspion/*.deb 50-raspion/*.dsc 50-raspion/*.tar.gz 50-raspion/*.changes development/repository/

