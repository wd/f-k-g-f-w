Client side settings when useing a linux box.

Note: Faild to get netflix in Mibox work, it's weird, I can watch through my MAC, but sometimes get a 'useing proxy warning' in Mibox. Swtich back to the router version.

# iptables

Use `netfilter-persistent` to persistent your iptables settings. Change `enx000ec6d312c3` to your local ethernet card device name.

# doh-client

# v2ray

# ipset

put `ipset-persistent.service` to `/etc/systemd/system/`.

# dnsmasq

Put `gfw.conf` to `/etc/dnsmasq.d/`.
