#!/usr/bin/env bash

if [[ $EUID -ne 0 ]]; then
   echo "Error:This script must be run as root!" 1>&2
   exit 1
fi

#if [ $(cat /proc/net/wireless| awk 'NR>2{print $0}'  | wc -c) -eq 0 ];then
#    echo "No wireless network card, please check your network!"
#    exit 44
#fi

for iface in `iw dev | grep Interface | awk '{print $2}'`;do
    if [ -z $iface ];then
        echo "No network card"
    else
        echo "Interfaces:"$iface
    fi
done
read -p "interface name(default_vale:${iface}):" interface


echo "+++++++++++++++++++ Scan wireless network +++++++++++++++++++++ "
/sbin/iwlist ${interface} scan | grep ESSID

read -p "Your choice ESSID: " SSID
read -p "Your input PASSWORD: " PASS

if [[ -f /run/wpa_supplicant/$interface ]];then

    net=$(wpa_cli -i $interface add_network)
    wpa_cli -i $interface set_network $net ssid "$SSID"
    wpa_cli -i "$interface" set_network "$net" psk "$PASS"
    #wpa_cli -i ${interface}  enable_network $net
else
    echo "wpa_supplicant not running!!!"
fi

/sbin/dhclient "$interface"

###########################Version 2###################################
#
#cat > /tmp/wpa_supplicant <<EOF
#	ctrl_interface=/var/run/wpa_supplicant
#	ctrl_interface_group=wheel
#	update_config=1
#
#	network={
#		ssid="$SSID"
#		scan_ssid=1
#		psk=$password
#		proto=RSN
#		key_mgmt=WPA-PSK
#		pairwise=CCMP
#		auth_alg=OPEN
#	}
#EOF
#wpa_supplicant -Dnl80211 -iwlan0 -c /tmp/wpa_supplicant.conf
#dhclient wlan0
#######################################################################
