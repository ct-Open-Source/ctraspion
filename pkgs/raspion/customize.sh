#!/bin/bash

set -e

LOGPATH=./pkg-customize.log
touch $LOGPATH
##2>&1 | tee -a $LOGPATH

WD=$(pwd)
if [ ! -e debian/rules ]; then
		echo "Run this script from pkg-root please" 2>&1 | tee -a $LOGPATH
		echo "Your workingdir is $WD" 2>&1 | tee -a $LOGPATH
		exit 1
fi

#Check for source includes
if [ ! -e ../../config.sh ]; then
		echo "can't find ../../config.sh" 2>&1 | tee -a $LOGPATH
		exit 1
fi
source ../../config.sh

customize() {
    echo "Replacing defaults in installed Config"
    sed -i.orig "s/^  address #IPv4HOST#/  address $IPv4HOST/" files/interfaces 2>&1 | tee -a $LOGPATH
    sed -i.orig "s/^  address #IPv6HOST#/  address $IPv6HOST/" files/interfaces 2>&1 | tee -a $LOGPATH
    sed -i.orig "s/^-m=#IPv4NET#/-m=$IPv4NET/" files/ntopng.conf 2>&1 | tee -a $LOGPATH
    sed -i.orig "s/^ssid=#SSID#/ssid=$SSID/" files/hostapd.conf 2>&1 | tee -a $LOGPATH
    sed -i.orig "s/^  RDNSS #IPv6HOST#/  RDNSS $IPv6HOST/" files/radvd.conf 2>&1 | tee -a $LOGPATH
    sed -i.orig "s/#IPv4HOST#/  RDNSS $IPv4HOST/" files/20-extport.conf 2>&1 | tee -a $LOGPATH
    
    echo "Replacing defaults in Package Config"
    sed -i.orig "s/#IPv6NETT#/$IPv6NET/" debian/postinst 2>&1 | tee -a $LOGPATH

}

clean() {
    echo "cleanup customized files"  2>&1 | tee -a $LOGPATH
    for file in $(find . -name "*.orig")  ; do
				NEWFN=$(echo $file | sed 's/.orig//')
        echo $file - $NEWFN 2>&1 | tee -a $LOGPATH
				mv -f $file $NEWFN  2>&1 | tee -a $LOGPATH
    done
}

case "$1" in 
    customize)  customize;;
    clean)      clean;;
    *)          exit 1;;
esac

exit 0