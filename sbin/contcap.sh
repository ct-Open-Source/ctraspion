#!/bin/bash
nohup dumpcap -i br0 -g -q -w /home/pi/public_html/caps/$1.pcapng -a duration:$2 >> /home/pi/public_html/caps/$1.log 2>&1 &
