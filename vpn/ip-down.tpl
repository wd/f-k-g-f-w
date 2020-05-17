#!/bin/bash


if [ -f /etc/ppp/ip-script-disabled ]; then
  exit
fi

export PATH="/bin:/sbin:/usr/sbin:/usr/bin"

# routes
$ROUTES
# routes

sudo killall ts-dns
