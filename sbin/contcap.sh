#!/bin/bash
nohup dumpcap -i br0 -g -q -w /var/www/raspion/caps/$1.pcapng -a duration:$2 >> /var/www/raspion/caps/$1.log 2>&1 &
