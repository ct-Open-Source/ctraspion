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
sudo touch $LOG
sudo chown pi:pi $LOG

trap 'error_report $LINENO' ERR
error_report() {
    echo "Installation leider fehlgeschlagen in Zeile $1."
}

echo "==> Einrichtung des c't-Raspion ($VER)" | tee -a $LOG

echo "* Raspbian aktualisieren ..." | tee -a $LOG
sudo apt-get update >> $LOG 2>&1
sudo apt-get -y dist-upgrade >> $LOG 2>&1

echo "* Raspbian Sprachanpassungen ..." | tee -a $LOG
sudo debconf-set-selections debconf/keyboard-configuration >> $LOG 2>&1
sudo cp files/keyboard /etc/default >> $LOG 2>&1
sudo dpkg-reconfigure -fnoninteractive keyboard-configuration >> $LOG 2>&1

sudo sed -e "/^[# ]*$NEWLANG/s/^[# ]*//" /etc/locale.gen  >> $LOG 2>&1
sudo dpkg-reconfigure -fnoninteractive locales >> $LOG 2>&1
sudo update-locale LANG=$NEWLANG >> $LOG 2>&1

sudo debconf-set-selections debconf/tzdata >> $LOG 2>&1
sudo ln -sf /usr/share/zoneinfo/Europe/Berlin /etc/localtime >> $LOG 2>&1
sudo cp files/timezone /etc >> $LOG 2>&1
sudo dpkg-reconfigure -fnoninteractive tzdata >> $LOG 2>&1

echo "* Pakete vorkonfigurieren ..." | tee -a $LOG
sudo debconf-set-selections debconf/wireshark >> $LOG 2>&1
sudo debconf-set-selections debconf/iptables-persistent >> $LOG 2>&1

echo "* Pakete installieren ..." | tee -a $LOG
sudo apt-get install -y --no-install-recommends --allow-change-held-packages \
     hostapd mitmproxy bridge-utils ipv6calc iptables-persistent radvd \
     shellinabox nmap xsltproc lighttpd tcpreplay pwgen wireshark-gtk >> $LOG 2>&1
cd /tmp
wget http://packages.ntop.org/RaspberryPI/apt-ntop_1.0.190416-469_all.deb >> $LOG 2>&1
sudo dpkg -i apt-ntop_1.0.190416-469_all.deb >> $LOG 2>&1
sudo apt-get install -y --no-install-recommends ntopng >> $LOG 2>&1
sudo dpkg -i $WD/debs/*.deb >> $LOG 2>&1
sudo apt-mark hold wireshark-gtk >> $LOG 2>&1
sudo apt-mark hold libgtk-3-0 >> $LOG 2>&1
sudo apt-mark hold libgtk-3-common >> $LOG 2>&1
sudo apt-mark hold libgtk-3-bin >> $LOG 2>&1

sudo cp $WD/sbin/* /usr/local/sbin >> $LOG 2>&1
sudo chmod +x /usr/local/sbin/*.sh >> $LOG 2>&1
sudo cp $WD/files/prefix_delegation /etc/dhcp/dhclient-exit-hooks.d >> $LOG 2>&1
sudo chmod +x /etc/dhcp/dhclient-exit-hooks.d/prefix_delegation >> $LOG 2>&1

echo "* Softwaregrundkonfiguration ..." | tee -a $LOG
sudo usermod -a -G wireshark pi >> $LOG 2>&1
sudo usermod -a -G www-data pi >> $LOG 2>&1
sudo cp $WD/files/ntopng.conf /etc/ntopng >> $LOG 2>&1
sudo cp $WD/files/interfaces /etc/network >> $LOG 2>&1
sudo cp $WD/files/hostapd.conf /etc/hostapd >> $LOG 2>&1
sudo cp $WD/files/ipforward.conf /etc/sysctl.d >> $LOG 2>&1
sudo cp $WD/files/hostname /etc/ >> $LOG 2>&1
sudo cp $WD/files/raspion-sudo /etc/sudoers.d/ >> $LOG 2>&1
sudo cp $WD/files/radvd.conf /etc/ >> $LOG 2>&1
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

echo "* Firewall-Regeln setzen und speichern ..." | tee -a $LOG
sudo iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE >> $LOG 2>&1
sudo ip6tables -t nat -A POSTROUTING -o eth0 -s fd00:24::/64 -j MASQUERADE >> $LOG 2>&1
sudo iptables -A PREROUTING -t nat -p tcp --dport 80 -j REDIRECT --to-ports 81 -i eth0 >> $LOG 2>&1
sudo ip6tables -A PREROUTING -t nat -p tcp --dport 80 -j REDIRECT --to-ports 81 -i eth0 >> $LOG 2>&1
sudo netfilter-persistent save >> $LOG 2>&1

echo "* systemd-Units vorbereiten ..." | tee -a $LOG
sudo cp $WD/files/mitmweb.service /etc/systemd/system >> $LOG 2>&1
sudo cp $WD/files/broadwayd.service /etc/systemd/system >> $LOG 2>&1
sudo cp $WD/files/wireshark.service /etc/systemd/system >> $LOG 2>&1
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
sudo cp $WD/files/20-extport.conf . >> $LOG 2>&1
mkdir -p /home/pi/public_html/scans >> $LOG 2>&1
mkdir -p /home/pi/public_html/caps >> $LOG 2>&1
sudo chmod g+s /home/pi/public_html/caps >> $LOG 2>&1
sudo chmod 777 /home/pi/public_html/caps >> $LOG 2>&1
sudo chgrp www-data /home/pi/public_html/caps >> $LOG 2>&1
cp $WD/files/*.png /home/pi/public_html >> $LOG 2>&1
cp $WD/files/*.php /home/pi/public_html >> $LOG 2>&1
cp $WD/files/*.css /home/pi/public_html >> $LOG 2>&1
cp $WD/files/*.js /home/pi/public_html >> $LOG 2>&1
cp $WD/files/*.ico /home/pi/public_html >> $LOG 2>&1

echo "* Pi-hole installieren ..." | tee -a $LOG
if ! id pihole >/dev/null 2>&1; then
    sudo adduser --no-create-home --disabled-login --disabled-password --shell /usr/sbin/nologin --gecos "" pihole >> $LOG 2>&1
fi
sudo mkdir -p /etc/pihole >> $LOG 2>&1
sudo chown pihole:pihole /etc/pihole >> $LOG 2>&1
sudo cp $WD/files/setupVars.conf /etc/pihole >> $LOG 2>&1
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


