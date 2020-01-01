#!/bin/bash
nmap -oX /tmp/$$_nmap.xml $1
xsltproc /tmp/$$_nmap.xml -o /var/www/raspion/scans/$1_$$_nmap.html
chown pi:pi /var/www/raspion/public_html/scans/$1_$$_nmap.html

