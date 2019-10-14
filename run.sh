#!/opt/bin/bash

log() {
	echo $(date) "$@"
}

start_ip6tables() {
	log "start ip6tables"
	ip -f inet6 rule add fwmark 0x01/0x01 table 100
	ip -f inet6 route add local ::/0 dev lo table 100
	ip6tables -t mangle -N V2RAY
	ip6tables -t mangle -A V2RAY -p tcp -j TPROXY --on-port 12345 --tproxy-mark 0x01/0x01
	ip6tables -t mangle -A PREROUTING -p tcp -j V2RAY
}

stop_ip6tables() {
	log "stop ip6tables"
	ip -f inet6 rule del table 100
	ip -f inet6 route flush table 100
	ip6tables -t mangle -D PREROUTING -p tcp -j V2RAY
	ip6tables -t mangle -F V2RAY
	ip6tables -t mangle -X V2RAY
}

start_iptables() {
	log "start iptables"
	iptables -t nat -N V2RAY
	iptables -t nat -A V2RAY -d 10.10.8.1/24 -j RETURN
	iptables -t nat -A V2RAY -p tcp -j RETURN -m mark --mark 0xff
	iptables -t nat -A V2RAY -p tcp -j REDIRECT --to-ports 12345
	iptables -t nat -A PREROUTING -p tcp -j V2RAY
	iptables -t nat -A OUTPUT -p tcp -j V2RAY
}


stop_iptables() {
	log "stop iptables"
	iptables -t nat -D PREROUTING -p tcp -j V2RAY
	iptables -t nat -D OUTPUT -p tcp -j V2RAY
	iptables -t nat -F V2RAY
	iptables -t nat -X V2RAY
}

start_v2ray() {
	log "start v2ray"
	/opt/svgfw/bin/v2ray -config /opt/gfw/config.json </dev/null >/dev/null 2>&1 &
}

stop_v2ray() {
	log "stop v2ray"
	killall v2ray
}

check_v2ray() {
	c=$(ps|grep /opt/svgfw/bin/v2ray|grep -v grep|wc -l)
	if [ "$c" -ne 1 ];then
		log "v2ray dead: $c"
		stop
		sleep 1
		start
	else
		log "v2ray alive: $c"
	fi
}

start() {
	start_v2ray
	start_iptables
	#start_ip6tables
}

stop() {
	#stop_ip6tables
	stop_iptables
	stop_v2ray
}

check() {
	check_v2ray
}

if [ "$1" == "start" ];then
	start
elif [ "$1" == "stop" ];then
	stop
elif [ "$1" == "check" ];then
	check
elif [ "$1" == "restart" ];then
	stop
	sleep 1
	start
fi
