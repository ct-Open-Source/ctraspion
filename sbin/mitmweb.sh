#!/bin/bash
mitmweb --mode transparent --web-port 9090 \
--web-iface 0.0.0.0 &>> /var/log/mitmweb.log

