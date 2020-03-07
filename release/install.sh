#!/bin/bash
###
# c't-Raspion, a Raspberry Pi based all in one sniffer
# for judging on IoT and smart home devices activity
# (c) 2019-2020 c't magazin, Germany, Hannover
# see: https://ct.de/-123456 for more information
# 
# file          : release/install.sh
# description   : main installer for raspion
#               : based on the work of P.Siering<ps@ct.de>
# version       : 0.1
#       
# changes         
# author		: Benny Stark - github.com/Diggen85
# date          : 2020013
# notes         : Initial - untested
###

set -e

WD=$(pwd)
LOG=./raspion-inst.log
NEWLANG=de_DE.UTF-8
source ./.version
sudo touch $LOG
sudo chown pi:pi $LOG


error_report() {
    echo "Installation leider fehlgeschlagen in Zeile $1."
}
trap 'error_report $LINENO' ERR


echo "==> Einrichtung des c't-Raspion ($VER)" | tee -a $LOG

echo "* Wifi einschalten" | tee -a $LOG
rfkill unblock wifi >> $LOG 2>&1

echo "* Hilfspakete hinzufügen, Paketlisten aktualisieren" | tee -a $LOG
sudo dpkg -i $WD/debs/raspion-keyring_2019_all.deb  >> $LOG 2>&1
sudo dpkg -i $WD/debs/apt-ntop_1.0.190416-469_all.deb  >> $LOG 2>&1
# the former calls apt-get update in postinst

echo "* Raspbian aktualisieren ..." | tee -a $LOG
#BUGFIX: For failed install if kernel upgrades -> iptables wont find his modules - BST20200121
if  LC_ALL=C sudo apt-get --just-print upgrade | grep -xiq "raspberrypi-kernel"; then
        echo "  Beim aktualisieren wird der raspberrypi-kernel aktualisiert."
        echo "  Nach der Aktualisierung wird ein neustart benötigt"
        echo "  Bitte starten Sie die Installation dannach erneut."
        read -p " Zum fortfahren bitte eine Taste drücken."
        sudo apt-get -y --allow-downgrades dist-upgrade >> $LOG 2>&1
        sudo reboot
fi

sudo apt-get -y --allow-downgrades dist-upgrade >> $LOG 2>&1

echo "* Raspbian Sprachanpassungen ..." | tee -a $LOG
sudo debconf-set-selections debconf/keyboard-configuration >> $LOG 2>&1
sudo cp debconf/keyboard /etc/default >> $LOG 2>&1
sudo dpkg-reconfigure -fnoninteractive keyboard-configuration >> $LOG 2>&1

sudo sed -i -e "/^[# ]*$NEWLANG/s/^[# ]*//" /etc/locale.gen  >> $LOG 2>&1
sudo dpkg-reconfigure -fnoninteractive locales >> $LOG 2>&1
sudo update-locale LANG=$NEWLANG >> $LOG 2>&1

sudo debconf-set-selections debconf/tzdata >> $LOG 2>&1
sudo ln -sf /usr/share/zoneinfo/Europe/Berlin /etc/localtime >> $LOG 2>&1
sudo cp debconf/timezone /etc >> $LOG 2>&1
sudo dpkg-reconfigure -fnoninteractive tzdata >> $LOG 2>&1

echo "* Pakete vorkonfigurieren ..." | tee -a $LOG
sudo debconf-set-selections debconf/wireshark >> $LOG 2>&1
sudo debconf-set-selections debconf/iptables-persistent >> $LOG 2>&1

echo "* Bugfix:iptables-1.8.2-4: Aktiviere iptables-legacy" >> $LOG 2>&1
# iptables-1.8.2-4 has Problems with MASQUERADE and ipv6
# we are using old iptables anyway
sudo update-alternatives --set iptables /usr/sbin/iptables-legacy >> $LOG 2>&1
sudo update-alternatives --set ip6tables /usr/sbin/ip6tables-legacy >> $LOG 2>&1

echo "* Pakete installieren ..." | tee -a $LOG
sudo apt-get install -y --allow-downgrades raspion --no-install-recommends >> $LOG 2>&1

echo "* Lade raspion's default.conf" | tee -a $LOG
. /usr/share/raspion/etc.templates/default.conf
echo "* Pi-hole installieren ..." | tee -a $LOG
if ! id pihole >/dev/null 2>&1; then
    sudo adduser --no-create-home --disabled-login --disabled-password --shell /usr/sbin/nologin --gecos "" pihole >> $LOG 2>&1
fi
sudo mkdir -p /etc/pihole >> $LOG 2>&1
sudo chown pihole:pihole /etc/pihole >> $LOG 2>&1
sudo cp $WD/pihole/setupVars.conf /etc/pihole >> $LOG 2>&1
sudo sed -i "s/IPV4_ADDRESS=#IPV4HOST#/IPV4_ADDRESS=$IPV4HOST/" /etc/pihole/setupVars.conf >> $LOG 2>&1
sudo sed -i "s/IPV6_ADDRESS=#IPV6HOST#/IPV6_ADDRESS=$IPV6HOST/" /etc/pihole/setupVars.conf >> $LOG 2>&1
sudo sed -i "s/DHCP_ROUTER=#IPV4HOST#/DHCP_ROUTER=$IPV4HOST/" /etc/pihole/setupVars.conf >> $LOG 2>&1
sudo sed -i "s/DHCP_START=#DHCPV4START#/DHCP_START=$DHCPV4START/" /etc/pihole/setupVars.conf >> $LOG 2>&1
sudo sed -i "s/DHCP_END=#DHCPV4END#/DHCP_END=$DHCPV4END/" /etc/pihole/setupVars.conf >> $LOG 2>&1
sudo -s <<HERE
curl -sSL https://install.pi-hole.net | bash /dev/stdin --unattended >> $LOG 2>&1
HERE
sudo chattr -f -i /etc/init.d/pihole-FTL >> $LOG 2>&1
sudo cp $WD/pihole/pihole-FTL /etc/init.d/ >> $LOG 2>&1
sudo chattr -f +i /etc/init.d/pihole-FTL >> $LOG 2>&1
sudo systemctl daemon-reload >> $LOG 2>&1
sudo systemctl restart pihole-FTL >> $LOG 2>&1
sudo pihole -f restartdns >> $LOG 2>&1


#im Log nach dem hostapd Passwort suchen
WPAPW=$(cat $LOG | grep "The hostapd Password is: "| cut -d":" -f2)

echo "==> Installation des c't-Raspion erfolgreich abgeschlossen." | tee -a $LOG
echo ""
echo "Das Passwort für das WLAN zur Beobachtung lautet: $WPAPW"
echo "Notieren Sie dieses bitte!"
echo ""
echo "Ändern Sie auch gleich das Passwort"
echo "für den Benutzer pi."
passwd
echo ""
echo "Starten Sie Ihren Raspberry Pi jetzt neu: sudo reboot now"


