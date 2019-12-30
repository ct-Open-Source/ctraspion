#!/bin/bash
nmap -oX /tmp/$$_nmap.xml $1
xsltproc /tmp/$$_nmap.xml -o ~pi/public_html/scans/$1_$$_nmap.html
chown pi:pi ~pi/public_html/scans/$1_$$_nmap.html

