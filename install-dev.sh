#!/bin/bash

#
# c't-Raspion, a Raspberry Pi based all in one sniffer
# for judging on IoT and smart home devices activity
# (c) 2019-2020 c't magazin, Germany, Hannover
# see: https://ct.de/-123456 for more information
# 

set -e

WD=$(pwd)
LOG=./raspion-devinst.log
source ./config.sh

sudo touch $LOG
sudo chown pi:pi $LOG

trap 'error_report $LINENO' ERR
error_report() {
    echo "Installation leider fehlgeschlagen in Zeile $1."
}


echo "==> Einrichtung des c't-Raspion ($VER)" | tee -a $LOG

echo "* Hilfspakete hinzufügen, Paketlisten aktualisieren" | tee -a $LOG
sudo dpkg -i $WD/debs/raspion-keyring_2019_all.deb  >> $LOG 2>&1
sudo dpkg -i $WD/debs/apt-ntop_1.0.190416-469_all.deb  >> $LOG 2>&1
# the former calls apt-get update in postinst

echo "* Raspbian aktualisieren ..." | tee -a $LOG
sudo apt-get -y --allow-downgrades dist-upgrade >> $LOG 2>&1

echo "* Raspbian Sprachanpassungen ..." | tee -a $LOG
sudo debconf-set-selections debconf/keyboard-configuration >> $LOG 2>&1
sudo cp files/keyboard /etc/default >> $LOG 2>&1
sudo dpkg-reconfigure -fnoninteractive keyboard-configuration >> $LOG 2>&1

NEWLANG=de_DE.UTF-8
sudo cp files/locale.gen /etc >> $LOG 2>&1
sudo dpkg-reconfigure -fnoninteractive locales >> $LOG 2>&1
sudo update-locale LANG=$NEWLANG >> $LOG 2>&1

sudo debconf-set-selections debconf/tzdata >> $LOG 2>&1
sudo ln -sf /usr/share/zoneinfo/Europe/Berlin /etc/localtime >> $LOG 2>&1
sudo cp files/timezone /etc >> $LOG 2>&1
sudo dpkg-reconfigure -fnoninteractive tzdata >> $LOG 2>&1



echo "* Pakete vorkonfigurieren ..." | tee -a $LOG
sudo debconf-set-selections debconf/wireshark >> $LOG 2>&1
sudo debconf-set-selections debconf/iptables-persistent >> $LOG 2>&1

echo "* lokale Pakete erstellen ..." | tee -a $LOG
cd pkgs/raspion
dpkg-buildpackage -uc -us | tee -a $LOG


echo "* lokale Pakete installieren ..." | tee -a $LOG
##sudo apt-get install -y --allow-downgrades raspion --no-install-recommends >> $LOG 2>&1

#DEV 
exit 1337


echo "* Pi-hole installieren ..." | tee -a $LOG
if ! id pihole >/dev/null 2>&1; then
    sudo adduser --no-create-home --disabled-login --disabled-password --shell /usr/sbin/nologin --gecos "" pihole >> $LOG 2>&1
fi
sudo mkdir -p /etc/pihole >> $LOG 2>&1
sudo chown pihole:pihole /etc/pihole >> $LOG 2>&1
sudo cp $WD/files/setupVars.conf /etc/pihole >> $LOG 2>&1
sudo sed -i "s/IPV4_ADDRESS=#IPv4HOST#/IPV4_ADDRESS=$IPv4HOST/" /etc/pihole/setupVars.conf >> $LOG 2>&1
sudo sed -i "s/IPV6_ADDRESS=#IPv6HOST#/IPV6_ADDRESS=$IPv6HOST/" /etc/pihole/setupVars.conf >> $LOG 2>&1
sudo sed -i "s/DHCP_ROUTER=#IPv4HOST#/DHCP_ROUTER=$IPv4HOST/" /etc/pihole/setupVars.conf >> $LOG 2>&1
sudo sed -i "s/DHCP_START=#DHCPv4START#/DHCP_START=$DHCPv4START/" /etc/pihole/setupVars.conf >> $LOG 2>&1
sudo sed -i "s/DHCP_END=#DHCPv4END#/DHCP_END=$DHCPv4END/" /etc/pihole/setupVars.conf >> $LOG 2>&1
sudo -s <<HERE
curl -sSL https://install.pi-hole.net | bash /dev/stdin --unattended >> $LOG 2>&1
HERE
sudo chattr -f -i /etc/init.d/pihole-FTL >> $LOG 2>&1
sudo cp $WD/files/pihole-FTL /etc/init.d/ >> $LOG 2>&1
sudo chattr -f +i /etc/init.d/pihole-FTL >> $LOG 2>&1
sudo systemctl daemon-reload >> $LOG 2>&1
sudo systemctl restart pihole-FTL >> $LOG 2>&1
sudo pihole -f restartdns >> $LOG 2>&1
sudo cp $WD/files/hosts /etc/ >> $LOG 2>&1



echo "==> Installation des c't-Raspion erfolgreich abgeschlossen." | tee -a $LOG
echo ""
echo "Das Passwort für das WLAN zur Beobachtung lautet: $WPAPW"
echo "Notieren Sie dieses bitte, ändern Sie auch gleich das Passwort"
echo "für den Benutzer pi (mit passwd)."
echo ""
echo "Starten Sie Ihren Raspberry Pi jetzt neu: sudo reboot now"


