#!/bin/bash

RULES=$(iptables -L PREROUTING -t nat --line-number | grep mitm | cut -d" " -f1 | sort -r)
for r in $RULES; do iptables -D PREROUTING $r -t nat; done

RULES=$(ip6tables -L PREROUTING -t nat --line-number | grep mitm | cut -d" " -f1 | sort -r)
for r in $RULES; do ip6tables -D PREROUTING $r -t nat; done

