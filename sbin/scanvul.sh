#!/bin/bash
nmap -oX /tmp/$$_nmap.xml --script vuln $1
xsltproc /tmp/$$_nmap.xml -o /var/www/raspion/scans/$1_$$_nmap.html
chown pi:pi /var/www/raspion/scans/$1_$$_nmap.html

