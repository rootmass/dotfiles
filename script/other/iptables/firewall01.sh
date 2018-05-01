#!/bin/bash

#define all variance or parameter

WAN_INT="eth0"
WAN_INT_IP="222.222.101.1"

LAN_INT="eth1"
LAN_INT_IP="192.168.222.101"

ALLOW_ACCESS_CLTENT="192.168.222.3 192.168.222.5 192.168.222.7 192.168.222.9 192.168.222.11 192.168.222.13 192.168.222.15 192.168.222.17 192.168.222.19 192.168.222.21"

WAN_WIN2003_SRV="222.222.101.2"

PORT="20,21,25,53,80,110,143,554,1755,7070"

IPT="/sbin/iptables"

##################################################################################

start(){
 echo ""
 echo -e "\033[1;032m Flush all chains ……           [ok] \033[m"

#flush all rules at first
  $IPT -t filter -F
  $IPT -t nat -F
  $IPT -t mangle -F

#default policy is drop
  $IPT -t filter -p INPUT DROP
  $IPT -t filter -P OUTPUT DROP
  $IPT -t filter -P FORWARD DROP

#open ssh service
  $IPT -t filter -A INPUT -p tcp --dport 22 -j ACCEPT
  $IPT -t filter -A OUTPUT -p tcp --sport 22 -j ACCEPT

#snat
  echo 1 > /proc/sys/net/ipv4/ip_forward
  $IPT -t nat -A POSTROUTING -s 192.168.222.0/24 -o $WAN_INT -j SNAT --to-source $WAN_INT_IP

################################################ACCEPT ERP ACCESS ################
if ["$ALLOW_ACCESS_CLIENT" != ""]; then
   for LAN IN ${ALLOW_ACCESS_CLIENT}; do
  $IPT -t filter -A FORWARD -p tcp -m mutiport -s ${LAN} -o $WAN_INT --dport $PORT -j ACCEPT
  $IPT -t filter -A FORWARD -p udp -m mutiport -s ${LAN} -o $WAN_INT --dport $PORT -j ACCEPT
  $IPT -t filter -A FORWARD -p tcp -m mutiport -i $WAN_INT --sport $PORT -j ACCEPT
  $IPT -t filter -A FORWARD -p udp -m mutiport -i $WAN_INT --sport $PORT -j ACCEPT

  echo ""
  echo ${LAN} Access to Externel...... ACCEPT access Win2003 server           [OK]
  done
fi

}

#######################################################################################
stop(){
################# Flush everything
  $IPT -F
  $IPT -X
  $IPT -Z
  $IPT -F -t nat
  $IPT -X -t nat
  $IPT -Z -t nat
  $IPT -P INPUT ACCEPT
  $IPT -P OUTPUT ACCEPT
  $IPT -P FORWARD ACCEPT

echo "##########################################################"
echo "#                                                        #"
echo "#       Stop firewall server Access rule Successfull !   #"
echo "#                                                        #"
echo "##########################################################"

}
##################################################################

case "$1" in
  start)
     start
     ;;
  stop)
     stop
     ;;
  restart)
     stop
     start
     ;;
   *)
    echo $"Usage:$0 {start|stop|restart}"
    exit 1
esac
exit $?
     



}

