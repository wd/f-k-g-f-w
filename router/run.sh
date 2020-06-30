#!/opt/bin/bash

base=$(dirname $0)
port=12345
lan='10.10.8.1/24'
v2ray=$base/bin/v2ray
config=$base/config.json

log() {
	echo $(date) "$@"
}

start_ip6tables() {
	log "start ip6tables"
	ip -f inet6 rule add fwmark 0x01/0x01 table 100
	ip -f inet6 route add local ::/0 dev lo table 100
	ip6tables -t mangle -N V2RAY
	ip6tables -t mangle -A V2RAY -p tcp -j TPROXY --on-port $port --tproxy-mark 0x01/0x01
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
	iptables -t nat -A V2RAY -d $lan -j RETURN
	iptables -t nat -A V2RAY -s 10.10.8.8 -j RETURN # hardcoded
	iptables -t nat -A V2RAY -p tcp -j RETURN -m mark --mark 0xff
	iptables -t nat -A V2RAY -p tcp -j REDIRECT --to-ports $port
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
	$v2ray -config $config </dev/null >/dev/null 2>&1 &
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
	c=$(iptables -t nat -nL V2RAY|grep $port|wc -l)
	if [ "$c" -ne 1 ];then
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
	#start_ip6tables
}

stop() {
	#stop_ip6tables
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
    curl -s "https://api.github.com/repos/v2ray/v2ray-core/releases/latest" | jq -r '.assets[] | select(.name | endswith("arm64.zip")).browser_download_url' | xargs curl -L -o /tmp/v2ray.zip --url
	unzip -fo /tmp/v2ray.zip v2ctl v2ray -d $base/bin

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
