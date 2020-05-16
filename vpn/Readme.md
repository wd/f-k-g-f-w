## Usage

```
$ pip install greendns
$ which greendns
```
Change settings in `ip-up.tpl`, specify the right path for greendns.

```
$ sh gen.sh
$ sudo cp build/* /etc/ppp/
```
If you want to disable the script, **stop VPN first** and `sudo touch /etc/ppp/ip-script-disabled`.
