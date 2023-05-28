#!/bin/bash

base=$(dirname $0)
port=12345
lan='10.10.8.1/24'
v2ray=$base/v2ray
config=$base/config.json

log() {
	echo $(date) "$@"
}

start_iptables() {
	log "start iptables"

	ip rule add fwmark 1 table 100 
	ip route add local 0.0.0.0/0 dev lo table 100

	iptables -t mangle -N V2RAY_PRE

	iptables -t mangle -A V2RAY_PRE -d <VPS-IP> -j RETURN

	iptables -t mangle -A V2RAY_PRE -d 127.0.0.1/8  -j RETURN
	iptables -t mangle -A V2RAY_PRE -d 255.255.255.255/32 -j RETURN
	iptables -t mangle -A V2RAY_PRE -d 224.0.0.0/4 -j RETURN
	iptables -t mangle -A V2RAY_PRE -d 192.168.0.0/16 -j RETURN

	iptables -t mangle -A V2RAY_PRE -d $lan -p tcp ! --dport 53 -j RETURN
	iptables -t mangle -A V2RAY_PRE -d $lan -p udp ! --dport 53 -j RETURN

	iptables -t mangle -A V2RAY_PRE  -p udp -j TPROXY --on-port $port --tproxy-mark 0x01/0x01
	iptables -t mangle -A V2RAY_PRE -p tcp -j TPROXY --on-port $port --tproxy-mark 0x01/0x01
	
	# 只处理来自 br-lan 和 wg0 的流量
	iptables -t mangle -A PREROUTING -i br-lan -j V2RAY_PRE
	iptables -t mangle -A PREROUTING -i wg0 -j V2RAY_PRE
}


stop_iptables() {
	log "stop iptables"

	ip rule del fwmark 1 table 100 
	ip route flush table 100

	iptables -t mangle -D PREROUTING -i br-lan -j V2RAY_PRE
	iptables -t mangle -D PREROUTING -i wg0 -j V2RAY_PRE

	iptables -t mangle -F V2RAY_PRE
	iptables -t mangle -X V2RAY_PRE
}

start_v2ray() {
	log "start v2ray"
	ulimit -SHn 65535
	$v2ray run -c $config </dev/null >> $base/v2ray.log 2>&1 &
}

stop_v2ray() {
	log "stop v2ray"
	killall v2ray
}

check_v2ray() {
	c=$(ps|grep $v2ray|grep -v grep|wc -l)
	if [ "$c" -ne 1 ];then
		log "v2ray dead: $c"
		stop_v2ray
		sleep 1
		start_v2ray
	else
		log "v2ray alive: $c"
	fi
}

check_iptables() {
	c=$(iptables -t mangle -nL V2RAY_PRE|wc -l)
	if [ "$c" -eq 0 ];then
		log "iptables dead: $c"
		stop_iptables
		sleep 1
		start_iptables
	else
		log "iptables alive: $c"
	fi
}

start() {
	start_v2ray
	start_iptables
}

stop() {
	stop_iptables
	stop_v2ray
}

restart() {
	stop
	sleep 1
	start
}

update() {
    log "update v2ray"
    rm /tmp/v2ray.zip
    curl -s "https://api.github.com/repos/v2fly/v2ray-core/releases/latest" | jq -r '.assets[] | select(.name | endswith("linux-64.zip")).browser_download_url' | xargs curl -L -o /tmp/v2ray.zip --url
	unzip -o /tmp/v2ray.zip v2ray -d $base

	log "update geosite"
	curl -s -L 'https://github.com/Loyalsoldier/v2ray-rules-dat/raw/release/geosite.dat' -o $(dirname $v2ray)/geosite.dat

	log "update geoip"
	curl -s -L 'https://github.com/Loyalsoldier/geoip/raw/release/geoip.dat' -o $(dirname $v2ray)/geoip.dat
}

check() {
	check_v2ray
	check_iptables
}

if [ "$1" == "start" ];then
	start
elif [ "$1" == "stop" ];then
	stop
elif [ "$1" == "check" ];then
	check
elif [ "$1" == "restart" ];then
	restart
elif [ "$1" == "update" ];then
    update
fi

