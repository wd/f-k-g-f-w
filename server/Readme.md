Remote Server settings.

# v2ray

Install v2ray use shell script
```
# bash <(curl -L -s https://install.direct/go.sh)
```

Put `v2ray_config.json` to `/etc/v2ray/config.json` and run command below to enable and start v2ray.
```
# systemctl enable v2ray
# systemctl start v2ray
```

Check `/var/log/v2ray/error.log` for logs.

# doh-server

Install from source
```
# apt install golang git
# git clone https://github.com/m13253/dns-over-https
# cd dns-over-https
# make
# make install
```

Put `doh-server.conf` to `/etc/dns-over-https/doh-server.conf` and run command below to enable and start doh-server.

```
# systemctl enable doh-server
# systemctl start doh-server
```

