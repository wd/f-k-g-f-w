#!/bin/bash
# Generate time: $GEN_TIME

# settings
LOCAL_DNS="114.114.114.114:53,223.5.5.5:53"
VPN_DNS="8.8.8.8:53,8.8.4.4:53,1.1.1.1:53"
greendns=/usr/local/Caskroom/miniconda/base/bin/greendns
############

if [ -f /etc/ppp/ip-script-disabled ]; then
exit
fi

export PATH="/bin:/sbin:/usr/sbin:/usr/bin"
OLDGW=`netstat -nr | grep "^default" | grep -v "ppp" | head -n 1 | awk -F' ' '{print $2}'`
dscacheutil -flushcache

# routes
$ROUTES
# routes

${S}greendns \
    -r greendns \
    -p 53 \
    -t 1.5 \
    --lds ${S}LOCAL_DNS \
    --rds ${S}VPN_DNS \
    --cache \
    -l warn \
    -f /etc/ppp/cn-cidrs.txt > /tmp/dns.log 2>&1 &

echo ${S}! > /tmp/dns.pid

SERVICE_ID=`echo 'open
get State:/Network/Global/IPv4
d.show
quit' | scutil | grep PrimaryService | awk '{print $3}'`


echo "open
d.init
d.add ServerAddresses * 127.0.0.1
set State:/Network/Service/${S}SERVICE_ID/DNS
quit" | scutil

