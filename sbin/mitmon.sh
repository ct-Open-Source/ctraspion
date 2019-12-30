#!/bin/bash
# Ausnahme für einzelnen Host:
#iptables -t nat -A PREROUTING -i br0 -p tcp -s 192.168.24.234 \
#-m tcp --dport 80 -j ACCEPT -m comment --comment mitm
#iptables -t nat -A PREROUTING -i br0 -p tcp -s 192.168.24.234 \
#-m tcp --dport 443 -j ACCEPT -m comment --comment mitm

# Grundregel IPv4
iptables -t nat -A PREROUTING -i br0 -p tcp -m tcp --dport 80 \
-j REDIRECT --to-ports 8080 -m comment --comment mitm
iptables -t nat -A PREROUTING -i br0 -p tcp -m tcp --dport 443 \
-j REDIRECT --to-ports 8080 -m comment --comment mitm

# Grundregel IPv6
ip6tables -t nat -A PREROUTING -i br0 -p tcp -m tcp --dport 80 \
-j REDIRECT --to-ports 8080 -m comment --comment mitm
ip6tables -t nat -A PREROUTING -i br0 -p tcp -m tcp --dport 443 \
-j REDIRECT --to-ports 8080 -m comment --comment mitm

