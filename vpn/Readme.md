## Usage

Require `curl` and `jq` installed on your system. Change settings in `ts-dns.toml` if you want.

```
$ sh gen.sh
$ sudo cp build/* /etc/ppp/
```
If you want to disable the script, **disconnect your VPN first** and `sudo touch /etc/ppp/ip-script-disabled`.
