#!/bin/bash
# Generate time: $GEN_TIME

if [ -f /etc/ppp/ip-script-disabled ]; then
exit
fi

export PATH="/bin:/sbin:/usr/sbin:/usr/bin"
OLDGW=`netstat -nr | grep "^default" | grep -v "ppp" | head -n 1 | awk -F' ' '{print $2}'`
dscacheutil -flushcache

# routes
$ROUTES
# routes

cd /etc/ppp/ && ./ts-dns > /tmp/dns.log 2>&1 &

SERVICE_ID=`echo 'open
get State:/Network/Global/IPv4
d.show
quit' | scutil | grep PrimaryService | awk '{print $3}'`


echo "open
d.init
d.add ServerAddresses * 127.0.0.1
set State:/Network/Service/${S}SERVICE_ID/DNS
quit" | scutil

