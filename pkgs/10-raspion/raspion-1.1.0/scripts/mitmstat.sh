#!/bin/bash
COUNT=$(iptables -L PREROUTING -t nat --line-number | grep mitm | wc -l)
[ $COUNT -gt 0 ] && exit 1 
COUNT=$(ip6tables -L PREROUTING -t nat --line-number | grep mitm | wc -l)
[ $COUNT -gt 0 ] && exit 1 
exit 0
