#!/bin/bash

IP_LIST='https://raw.githubusercontent.com/17mon/china_ip_list/master/china_ip_list.txt'
DEST_DIR="./build"

mkdir -p $DEST_DIR

download() {
    wget -O $DEST_DIR/cn-cidrs.txt $IP_LIST
}

generate_routes_add() {
    while read line; do
        echo 'route add '$line' $OLDGW'
    done < $DEST_DIR/cn-cidrs.txt
}

generate_routes_delete() {
    while read line; do
        echo 'route delete '$line' $OLDGW'
    done < $DEST_DIR/cn-cidrs.txt
}

generate_scripts() {
    export GEN_TIME=$(date)
    ROUTES=$(generate_routes_add)
    S='$'
    export ROUTES S
    envsubst < ip-up.tpl > $DEST_DIR/ip-up

    ROUTES=$(generate_routes_delete)
    export ROUTES
    envsubst < ip-down.tpl > $DEST_DIR/ip-down

    chmod +x $DEST_DIR/{ip-up,ip-down}

    unset ROUTES
}

main() {
    download
    generate_scripts
}

main
