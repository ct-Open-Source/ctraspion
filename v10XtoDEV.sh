#!/bin/sh
#
# c't-Raspion, a Raspberry Pi based all in one sniffer
# for judging on IoT and smart home devices activity
# (c) 2019-2020 c't magazin, Germany, Hannover
# see: https://ct.de/-123456 for more information
#
# 01.01.2020 - Diggen85 <Benny_Stark@live.de> 
# - Initial commit
# - changing ~/public_html to /var/www/raspion
#

set -e

WD=$(pwd)
LOG=/var/log/raspion-10Xto110.log
source ./.version
source ./.defaults
sudo touch $LOG
sudo chown pi:pi $LOG

trap 'error_report $LINENO' ERR
error_report() {
    echo "Installation leider fehlgeschlagen in Zeile $1."
}

echo "==> Update zu $VER" | tee -a $LOG

sudo systemctl stop lighttpd.service >> $LOG 2>&1

cd /etc/lighttpd/conf-enabled/
# move raspion config to config-available
sudo mv 10-dir-listing.conf 20-extport.conf  ../conf-available/ >> $LOG 2>&1
sudo ln -sf ../conf-available/10-dir-listing.conf . >> $LOG 2>&1
sudo ln -sf ../conf-available/20-extport.conf . >> $LOG 2>&1

# remove userdir and move to /var/www/raspion
sudo rm 10-userdir.conf >> $LOG 2>&1

#move public_html and modify extport.conf
sudo sed -i "s/\/\~pi//g" /etc/lighttpd/conf-enabled/10-dir-listing.conf >> $LOG 2>&1
sudo sed -i 's/server\.document-root.*$/server\.document-root = \"\/var\/www\/raspion\/"/' ../conf-available/20-extport.conf >> $LOG 2>&1
# TODO Remove dirlist entries - they are in 10-dir-listing.conf 
sudo mkdir -p /var/www/raspion
sudo mv /home/pi/public_html /var/www/raspion >> $LOG 2>&1
sudo chown -R www-data:www-data /var/www/raspion >> $LOG 2>&1
#chmod should be preserved for caps but go+w for scans is initial not set
sudo chmod -R go+w /var/www/raspion/scans >> $LOG 2>&1

#change Path in Scripts
sudo sed -i 's/\/home\/pi\/public_html/\/var\/www\/raspion/g' /usr/local/sbin/contcap.sh >> $LOG 2>&1
sudo sed -i 's/\~pi\/public_html/\/var\/www\/raspion/g' /usr/local/sbin/scan.sh /usr/local/sbin/scanvul.sh >> $LOG 2>&1
sudo sed -i 's/pi\:pi/pi\:www-data/' /usr/local/sbin/scan.sh /usr/local/sbin/scanvul.sh >> $LOG 2>&1

#start lighthttpd again
sudo systemctl start lighttpd.service >> $LOG 2>&1
cd $WD >> $LOG 2>&1

echo "==> Update des c't-Raspion zu $VER erfolgreich abgeschlossen." | tee -a $LOG