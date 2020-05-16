#!/bin/bash


if [ -f /etc/ppp/ip-script-disabled ]; then
  exit
fi

export PATH="/bin:/sbin:/usr/sbin:/usr/bin"

# routes
$ROUTES
# routes

DNS_PID=`cat /tmp/dns.pid`
sudo kill -SIGKILL ${S}DNS_PID
rm /tmp/dns.pid
