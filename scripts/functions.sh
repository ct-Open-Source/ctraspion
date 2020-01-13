#!/bin/bash
###
# c't-Raspion, a Raspberry Pi based all in one sniffer
# for judging on IoT and smart home devices activity
# (c) 2019-2020 c't magazin, Germany, Hannover
# see: https://ct.de/-123456 for more information
# 
# file          : scripts/functions.sh
# description   : Some helper for the main RSD.sh-Script
# version       : 0.1
#       
# changes         
# author		: Benny Stark - github.com/Diggen85
# date          : 2020013
# notes         : Initial - untested
###

##
## logger $MSG [$TYPE:ERR,WAR,NOR]
## - Print pretty Text 
logger() {
    case $2 in
        ERR|ERROR)
            $TYPE="\033[31m [  ERROR  ] \033[0m" 
            ;;
        WAR|WARN|WARNING)
            $TYPE="\033[33m [ WARNING ] \033[0m" 
            ;;
        NOR|NORM|NORMAL)
            $TYPE="\033[32m [    OK   ] \033[0m" 
            ;;
        *)
            $TYPE="         - "
    esac
    MSG=${$1:-"Forgot what to say..."}
    echo -e"$TYPE $MSG"
}

##
## runPriv
## - check if we are root or we should sudo
runPriv() {
    if [ $RSD_USER == 0 ]; then 
        $@
    else
        sudo $@
    fi
}

##
## RSD-Prepare
## - Prepare the environment.
## - needs to be root or sudo
RSD-Prepare () {
    runPriv sudo apt-get install $RSD_REQPACKAGES
}

##
## RSD-Build [PKG Name]
## - build all packages or specified
## - e.g. RSD-Build 50-raspion
RSD-Build () {
    if [ -n $1 && -f $RSD_PWD/pkg/$1.sh ] ; then
        logger "Start building of specified package: $1"
        /bin/bash $RSD_PWD/pkg/$1.sh
    else
        logger "Start building of all packages"
        run-parts $RSD_PWD/pkgs/
    fi
    
}

##
## RSD-Install
## - Calls install.sh with dev dependend args
RSD-Install () {
    logger "Start the Raspion installation"
    RELEASE=0 RSD_REPO=XXX $RSD_PWD/release/install.sh
}