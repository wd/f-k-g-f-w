iptables -t nat -A PREROUTING -i enx000ec6d312c3 -p udp -m udp --dport 53 -j REDIRECT --to-ports 53
iptables -t nat -A PREROUTING -i enx000ec6d312c3 -p tcp -m tcp --dport 53 -j REDIRECT --to-ports 53
iptables -t nat -A PREROUTING -p tcp -m set --match-set setmefree dst -j REDIRECT --to-ports 1080
iptables -t nat -A PREROUTING -p udp -m set --match-set setmefree dst -j REDIRECT --to-ports 1080
