#!/bin/bash

#
# c't-Raspion, a Raspberry Pi based all in one sniffer
# for judging on IoT and smart home devices activity
# (c) 2019-2020 c't magazin, Germany, Hannover
# see: https://ct.de/-123456 for more information
#

set -e

WD=$(pwd)
LOG=/var/log/raspion.log
NEWLANG=de_DE.UTF-8
[[ -f .version ]] && source ./.version || VER=$(git rev-parse --short HEAD)
source ./.defaults
sudo touch $LOG
sudo chown pi:pi $LOG

trap 'error_report $LINENO' ERR
error_report() {
    echo "Installation leider fehlgeschlagen in Zeile $1."
}

echo "==> Einrichtung des c't-Raspion ($VER)" | tee -a $LOG
echo "* Wifi einschalten" | tee -a $LOG
rfkill unblock wifi >> $LOG 2>&1

echo "* Hilfspakete hinzufügen, Paketlisten aktualisieren" | tee -a $LOG
sudo dpkg -i $WD/debs/raspion-keyring_2019_all.deb  >> $LOG 2>&1
sudo dpkg -i $WD/debs/apt-ntop_1.0.190416-469_all.deb  >> $LOG 2>&1
# the former calls apt-get update in postinst

echo "* Firewallregeln vorbereiten, Module laden" | tee -a $LOG
sudo iptables -t nat -F POSTROUTING >> $LOG 2>&1
sudo ip6tables -t nat -F POSTROUTING >> $LOG 2>&1
sudo iptables -t nat -F PREROUTING >> $LOG 2>&1
sudo ip6tables -t nat -F PREROUTING >> $LOG 2>&1
sudo iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE >> $LOG 2>&1
sudo ip6tables -t nat -A POSTROUTING -o eth0 -s $IPv6NET/64 -j MASQUERADE >> $LOG 2>&1
sudo iptables -A PREROUTING -t nat -p tcp --dport 80 -j REDIRECT --to-ports 81 -i eth0 >> $LOG 2>&1
sudo ip6tables -A PREROUTING -t nat -p tcp --dport 80 -j REDIRECT --to-ports 81 -i eth0 >> $LOG 2>&1

echo "* Pakete vorkonfigurieren ..." | tee -a $LOG
sudo debconf-set-selections debconf/wireshark >> $LOG 2>&1
sudo debconf-set-selections debconf/iptables-persistent >> $LOG 2>&1
sudo apt-get install -y iptables-persistent >> $LOG 2>&1

echo "* Firewall-Regeln speichern ..." | tee -a $LOG
sudo netfilter-persistent save >> $LOG 2>&1

echo "* Raspbian aktualisieren ..." | tee -a $LOG
sudo apt-get -y --allow-downgrades dist-upgrade >> $LOG 2>&1

echo "* Raspbian Sprachanpassungen ..." | tee -a $LOG
sudo debconf-set-selections debconf/keyboard-configuration >> $LOG 2>&1
sudo cp files/keyboard /etc/default >> $LOG 2>&1
sudo dpkg-reconfigure -fnoninteractive keyboard-configuration >> $LOG 2>&1

sudo sed -i -e "/^[# ]*$NEWLANG/s/^[# ]*//" /etc/locale.gen  >> $LOG 2>&1
sudo dpkg-reconfigure -fnoninteractive locales >> $LOG 2>&1
sudo update-locale LANG=$NEWLANG >> $LOG 2>&1

sudo debconf-set-selections debconf/tzdata >> $LOG 2>&1
sudo ln -sf /usr/share/zoneinfo/Europe/Berlin /etc/localtime >> $LOG 2>&1
sudo cp files/timezone /etc >> $LOG 2>&1
sudo dpkg-reconfigure -fnoninteractive tzdata >> $LOG 2>&1

echo "* Pakete installieren ..." | tee -a $LOG
sudo apt-get install -y --allow-downgrades raspion --no-install-recommends >> $LOG 2>&1

echo "* Softwaregrundkonfiguration ..." | tee -a $LOG
sudo usermod -a -G wireshark pi >> $LOG 2>&1
sudo usermod -a -G www-data pi >> $LOG 2>&1
sudo cp $WD/files/ntopng.conf /etc/ntopng >> $LOG 2>&1
sudo sed -i "s/^-m=#IPv4NET#/-m=$IPv4NET/" /etc/ntopng/ntopng.conf >> $LOG 2>&1
sudo cp $WD/files/interfaces /etc/network >> $LOG 2>&1
sudo sed -i "s/^  address #IPv4HOST#/  address $IPv4HOST/" /etc/network/interfaces >> $LOG 2>&1
sudo sed -i "s/^  address #IPv6HOST#/  address $IPv6HOST/" /etc/network/interfaces >> $LOG 2>&1
sudo cp $WD/files/hostapd.conf /etc/hostapd >> $LOG 2>&1
sudo sed -i "s/^ssid=#SSID#/ssid=$SSID/" /etc/hostapd/hostapd.conf >> $LOG 2>&1
sudo cp $WD/files/ipforward.conf /etc/sysctl.d >> $LOG 2>&1
sudo cp $WD/files/hostname /etc/ >> $LOG 2>&1
sudo cp $WD/files/raspion-sudo /etc/sudoers.d/ >> $LOG 2>&1
sudo cp $WD/files/radvd.conf /etc/ >> $LOG 2>&1
sudo sed -i "s/^  RDNSS #IPv6HOST#/  RDNSS $IPv6HOST/" /etc/radvd.conf >> $LOG 2>&1
sudo mkdir -p /root/.mitmproxy >> $LOG 2>&1
sudo cp $WD/files/config.yaml /root/.mitmproxy >> $LOG 2>&1
mkdir -p /home/pi/.config/wireshark >> $LOG 2>&1
cp $WD/files/recent /home/pi/.config/wireshark >> $LOG 2>&1
cp $WD/files/preferences_wireshark /home/pi/.config/wireshark/preferences >> $LOG 2>&1
sudo cp $WD/files/settings.ini /etc/gtk-3.0 >> $LOG 2>&1
sudo cp -f $WD/files/shellinabox /etc/default >> $LOG 2>&1
cd /usr/lib/python3/dist-packages/mitmproxy/addons/onboardingapp/static >> $LOG 2>&1
sudo ln -sf /usr/share/fonts-font-awesome fontawesome >> $LOG 2>&1
PW=$(pwgen --ambiguous 9)
sudo -s <<HERE
echo "wpa_passphrase=$PW" >> /etc/hostapd/hostapd.conf
HERE

echo "* systemd-Units vorbereiten ..." | tee -a $LOG
sudo systemctl enable mitmweb.service >> $LOG 2>&1
sudo systemctl unmask hostapd >> $LOG 2>&1
sudo systemctl enable radvd >> $LOG 2>&1
sudo systemctl enable broadwayd >> $LOG 2>&1
sudo systemctl enable wireshark >> $LOG 2>&1

echo "* Weboberfläche hinzufügen ..." | tee -a $LOG
cd /etc/lighttpd/conf-enabled >> $LOG 2>&1
sudo ln -sf ../conf-available/10-userdir.conf 10-userdir.conf >> $LOG 2>&1
sudo ln -sf ../conf-available/10-proxy.conf 10-proxy.conf >> $LOG 2>&1
sudo cp $WD/files/10-dir-listing.conf . >> $LOG 2>&1
sudo -s <<HERE
echo '\$SERVER["socket"] == ":81" {
        server.document-root = "/home/pi/public_html"
        dir-listing.encoding = "utf-8"
        \$HTTP["url"] =~ "^/caps(\$|/)" {
            dir-listing.activate = "enable" 
        }
        \$HTTP["url"] =~ "^/scans(\$|/)" {
           dir-listing.activate = "enable" 
        }
        \$HTTP["url"] =~ "^/admin" {
                proxy.server = ( "" => (( "host" => "'$IPv4HOST'", "port" => "80")) )
        }
}' > /etc/lighttpd/conf-enabled/20-extport.conf
HERE
sudo chmod g+s /home/pi/public_html/caps >> $LOG 2>&1
sudo chmod 777 /home/pi/public_html/caps >> $LOG 2>&1
sudo chgrp www-data /home/pi/public_html/caps >> $LOG 2>&1

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
echo "Das Passwort für das WLAN zur Beobachtung lautet: $PW"
echo "Notieren Sie dieses bitte, ändern Sie auch gleich das Passwort"
echo "für den Benutzer pi (mit passwd)."
echo ""
echo "Starten Sie Ihren Raspberry Pi jetzt neu: sudo reboot now"


