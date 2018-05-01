#!/bin/bash

#=====================================================================================
#PPTP服务器上的iptables防火墙实例
#因大部分公司的PPTP服务器需要进行权限控制，如果采用linux作为pptp服务器平台，则可用iptables进#行访问控制。两个网卡：eth0和eth1，eth0:202.85.33.44 eth1:192.168.0.254
#内网划分了6个VLAN，其中PPTP用户所有的vlan5为192.168.0.0/24
#内网服务器网段地址为：192.168.55.0/24
#在pptp服务器在需要增加一条路由表：route add -net 192.168.55.0/24 gw 192.168.0.1
#192.168.0.1为vlan5的IP地址
#======================================================================================

echo "Starting.........................."
echo "RunTime='data |awk '{print $6" "$2" "3" "4"}''"
echo -e "\t\t\n\n"
echo -e "\033[1;031m \n"
echo "######################################################"
echo "#           pptp server iptables rule                #"
echo "######################################################"
echo e "\033[m \n"
echo ""

echo -e "\033[1;031m \n"
echo "######################################################"
echo "#    Network Internet Address eth0:  202.85.33.44    #"
echo "#    Internal Network Address eth1:  192.168.0.254   #
echo "######################################################"
echo e "\033[m \n"

LAN_IFACE="eth1"
INET_IFACE="eth0"
IPTABLES="/sbin/iptables"
ACCEPT_ERP_OA_HOSTS="192.168.0.91 192.168.0.90 192.168.0.85 192.168.0.86 192.168.0.87"
#以上规则为可以访问OA和ERP的权限
ACCEPT_inMAIL_HOST="192.168.0.91 192.168.0.67 192.168.0.89 192.168.0.95 192.168.0.56"
#以上规则为仅可访问内部邮件服务器的权限
ACCEPT_ERP_HOST=""
ACCEPT_inWEB_HOST=""
ACCEPT_TEST_HOST="192.168.0.45 192.168.0.47 192.168.0.48"
ACCEPT_CRM_HOST="192.168.0.91 192.168.0.4 192.168.0.9 192.168.0.10"
ACCEPT_all_HOST="192.168.0.91 192.168.0.4 192.168.0.9 192.168.0.10"
#以上为所有访问权限，也即可以访问内网，也可通过PPTP服务器访问Internet
#ACCEPT_APS_HOST="192.168.0.39"


#################### Main Options　#####################

#=======================================================
#-------Actual NetFilter Stuff  Follows-----------------
#=======================================================
############  Load modules
modprobe ip_tables               > /dev/null 2>&1
modprobe ip_conntrack               > /dev/null 2>&1
modprobe iptable_nat               > /dev/null 2>&1
#modprobe ip_nat_ftp               > /dev/null 2>&1
modprobe ip_conntrack_ftp               > /dev/null 2>&1
modprobe ip_conntrack_irc               > /dev/null 2>&1
modprobe ip_conntrack_h323               > /dev/null 2>&1
modprobe ip_nat_h323               > /dev/null 2>&1
modprobe ip_conntrack_irc               > /dev/null 2>&1
#modprobe ip_nat_irc               > /dev/null 2>&1
modprobe ip_conntrack_mms               > /dev/null 2>&1
modprobe ip_nat_mms               > /dev/null 2>&1
#modprobe ip_conntrack_pptp               > /dev/null 2>&1
#modprobe ip_nat_ftp               > /dev/null 2>&1
#modprobe ip_conntrack_proto_gre               > /dev/null 2>&1
#modprobe ip_nat_proto_gre               > /dev/null 2>&1
modprobe ip_conntrack_quake3               > /dev/null 2>&1
modprobe ip_nat_quake3               > /dev/null 2>&1
###########################################################

###########################################################
echo 1 > /proc/sys/net/ipv4/ip_forward
#echo 1 > /proc/sys/net/ipv4/conf/all/rp_fillter

start(){
  echo ""
 echo -e "\033[1;032m  Flush all chains..........                    [OK] \033[m"

  $IPTABLES -F
  $IPTABLES -X
  $IPTABLES -Z
  $IPTABLES -F -t nat
  $IPTABLES -X -t nat
  $IPTABLES -Z -t nat
  $IPTABLES -P INPUT DROP
  $IPTABLES -P OUTPUT ACCEPT
  $IPTABLES -P FORWARD DROP

  $IPTABLES -A INPUT -p icmp -m limit --limit 1/s --limit-burst 10 -j ACCEPT
  $IPTABLES -A INPUT -s 202.102.224.68 -j ACCEPT
  $IPTABLES -A INPUT -s 202.96.134.133 -j ACCEPT
  $IPTABLES -A INPUT -s 127.0.0.0/8 -j ACCEPT
  $IPTABLES -A INPUT -d 127.0.0.0/8 -j ACCEPT
  $IPTABLES -A INPUT -p 47 -j ACCEPT
  $IPTABLES -A INPUT -p tcp --dport 22 -j ACCEPT
  $IPTABLES -A INPUT -p tcp --dport 1723 -j ACCEPT
  $IPTABLES -A INPUT -p tcp --dport 133 -j ACCEPT
  $IPTABLES -A INPUT -p tcp --dport 1194 -j ACCEPT
  $IPTABLES -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
  $IPTABLES -A INPUT -S 192.168.55.19 -j ACCEPT
  $IPTABLES -A INPUT -j ACCEPT
  $IPTABLES -t nat -A POSTROUTING -O eth0 -s 192.168.0.0/24 -j SNAT --to 202.85.33.44
######################################################################################
  $IPTABLES -A FORWARD -m state --state ESTABLISHED,RELATED -j ACCEPT
  $IPTABLES -A FORWARD -S 192.168.0.22 -j ACCEPT
  $IPTABLES -A FORWARD -p tcp -i ppp+ --dport 113 -j ACCEPT
  $IPTABLES -A FORWARD -p icmp -j ACCEPT
  $IPTABLES -A FORWARD -p tcp --dport 113 -j ACCEPT
  $IPTABLES -I FORWARD -d 192.168.0.0/24 -j ACCEPT
#####################################################################################
  $IPTABLES -I FORWARD -d 192.168.55.229 -j ACCEPT
  $IPTABLES -I FORWARD -s 192.168.55.229 -j ACCEPT
  $IPTABLES -A FORWARD -d 192.168.55.219 -j ACCEPT

  $IPTABLES -I FORWARD -s 192.168.0.0/24 -d 192.168.55.15 -j ACCEPT
  $IPTABLES -I FORWARD -s 192.168.0.0/24 -d 192.168.55.14 -j ACCEPT
  $IPTABLES -I FORWARD -s 192.168.0.0/24 -d 192.168.55.16 -j ACCEPT
  $IPTABLES -I FORWARD -s 192.168.0.0/24 -d 210.75.1.165 -j ACCEPT
  $IPTABLES -A FORWARD -p udp -m multiport --dport 53,449 -j ACCEPT
  $IPTABLES -A FORWARD -p tcp -m multiport --dport 53,449 -j ACCEPT

echo -e "\033[1;034m \n"
echo "....................................................."
echo "....................................................."
echo "....................................................."
echo ""
echo -e "\033[1;032m \n"
##################################accept erp access ##################################
if ["$ACCEPT_ERP_OA_HOST" != ""]; then
  for LAN in ${ACCEPT_ERP_OA_HOST} ; do
   
   $IPTABLES -A FORWARD  -i ppp+ -o eth1 -s ${LAN} -d 192.168.55.17 -j ACCEPT
   $IPTABLES -A FORWARD  -i ppp+ -o eth1 -s ${LAN} -d 192.168.55.91 -j ACCEPT
  echo ""
  echo ${LAN}  Access to Externel............Accept erp and oa access   [OK]
 done
fi
echo -e "\033[1;034m \n"
echo "....................................................."
echo "....................................................."
echo "....................................................."
echo ""
echo -e "\033[1;032m \n"
############################accept erp access #############################
if ["$ACCEPT_ERP_HOST" != ""]; then
  for LAN in ${ACCEPT_ERP_HOST} ; do
   
   $IPTABLES -A FORWARD  -i ppp+ -o eth1 -s ${LAN} -d 192.168.55.17 -j ACCEPT
  echo ""
  echo ${LAN}  Access to Externel............Accept only erp  access   [OK]
 done
fi
echo -e "\033[1;034m \n"
echo "....................................................."
echo "....................................................."
echo "....................................................."
echo ""
echo -e "\033[1;032m \n"
############################accept crm access #############################
if ["$ACCEPT_CRM_HOST" != ""]; then
  for LAN in ${ACCEPT_CRM_HOST} ; do
   
   $IPTABLES -A FORWARD  -i ppp+ -o eth1 -s ${LAN} -d 192.168.55.9 -j ACCEPT
  echo ""
  echo ${LAN}  Access to Externel............Accept only CRM  access   [OK]
 done
fi
echo -e "\033[1;034m \n"
echo "....................................................."
echo "....................................................."
echo "....................................................."
echo ""
echo -e "\033[1;032m \n"
############################accept test access #############################
if ["$ACCEPT_TEST_HOST" != ""]; then
  for LAN in ${ACCEPT_TEST_HOST} ; do
   
   $IPTABLES -A FORWARD  -i ppp+ -o eth1 -s ${LAN} -d 192.168.55.30 -j ACCEPT
  echo ""
  echo ${LAN}  Access to Externel............Accept only TESTAPP  access   [OK]
 done
fi
echo -e "\033[1;034m \n"
echo "....................................................."
echo "....................................................."
echo "....................................................."
echo ""
echo -e "\033[1;032m \n"
############################accept inMAIL access #############################
if ["$ACCEPT_inMAIL_HOST" != ""]; then
  for LAN in ${ACCEPT_inMAIL_HOST} ; do
   
   $IPTABLES -A FORWARD  -i ppp+ -o eth1 -s ${LAN} -d 192.168.55.8 -j ACCEPT
  echo ""
  echo ${LAN}  Access to Externel............Accept only inMAIL  access   [OK]
 done
fi
echo -e "\033[1;034m \n"
echo "....................................................."
echo "....................................................."
echo "....................................................."
echo ""
echo -e "\033[1;032m \n"
############################accept inWEB access #############################
if ["$ACCEPT_inWEB_HOST" != ""]; then
  for LAN in ${ACCEPT_inWEB_HOST} ; do
   
   $IPTABLES -A FORWARD  -i ppp+ -o eth1 -s ${LAN} -d 192.168.55.8 -j ACCEPT
  echo ""
  echo ${LAN}  Access to Externel............Accept only inWEB  access   [OK]
 done
fi
echo -e "\033[1;034m \n"
echo "....................................................."
echo "....................................................."
echo "....................................................."
echo ""
echo -e "\033[1;032m \n"
############################accept aps access #############################
if ["$ACCEPT_APS_HOST" != ""]; then
  for LAN in ${ACCEPT_APS_HOST} ; do
   
   $IPTABLES -A FORWARD  -i ppp+ -o eth1 -s ${LAN} -d 192.168.55.23 -j ACCEPT
  echo ""
  echo ${LAN}  Access to Externel............Accept only TESTAPP  access   [OK]
 done
fi
echo -e "\033[1;034m \n"
echo "....................................................."
echo "....................................................."
echo "....................................................."
echo ""
echo -e "\033[1;032m \n"
############################accept ALL access #############################
if ["$ACCEPT_all_HOST" != ""]; then
  for LAN in ${ACCEPT_all_HOST} ; do
   
   $IPTABLES -A FORWARD  -i ppp+ -o eth1 -s ${LAN} -d 192.168.55.30 -j ACCEPT
  echo ""
  echo ${LAN}  Access to Externel............Accept only TESTAPP  access   [OK]
 done
fi
echo -e "\033[1;034m \n"
echo "....................................................."
echo "....................................................."
echo "....................................................."
echo ""
echo -e "\033[1;032m \n"
##############################logrule####################################
#LOGACCESS="no"
LOGACCESS="yes"
if ["$LOGACCESS"="yes"];then
# $IPTABLES -I FORWARD -p tcp -m multiport --dport 445,135 -j LOG
  $IPTABLES -I INPUT -p tcp ! -s 192.168.55.180 -j LOG --log-prfix 'IPTABLES INPUT TCP ACCEPT:'
# $IPTABLES -I INPUT -p udp ! -s 192.168.55.180 -j LOG --log-prfix 'IPTABLES INPUT TCP ACCEPT:'
  $IPTABLES -A INPUT -P TCP ! --syn -m state NEW -j LOG --log-tcp-options --log-ip-options --log-prefix 'IPTABLES INPUT DROP:'
  $IPTABLES -I FORWARD -p tcp -s 192.168.0.0/24 -j LOG --log-prefix 'IPTABLES FORWARD TCP ACCEPT:'
  $IPTABLES -I FORWARD -p udp -s 192.168.0.0/24 -j LOG --log-prefix 'IPTABLES FORWARD UDP ACCEPT:'
  $IPTABLES -A FORWARD -P TCP ! --syn -m state NEW -j LOG --log-tcp-options --log-ip-options --log-prefix 'IPTABLES FORWARD DROP:'
echo LOG illegal access...................................        [OK]
fi
echo -e "\033[1;031m \n"
echo "######################################################"
echo "#   Load PPTP server Access rule Successfull !       #"
echo "######################################################"
echo e "\033[m \n"
echo ""
###########################Type of Service mangle optimizations ###########
# ${IPTABLES} -t mangle -A OUTPUT -p tcp --dport 23 -j TOS --set-tos Minimize-Delay
# ${IPTABLES} -t mangle -A OUTPUT -p tcp --dport 22 -j TOS --set-tos Minimize-Delay
# ${IPTABLES} -t mangle -A OUTPUT -p tcp --dport 20 -j TOS --set-tos Minimize-Cost
# ${IPTABLES} -t mangle -A OUTPUT -p tcp --dport 21 -j TOS --set-tos Minimize-Delay
# ${IPTABLES} -t mangle -A OUTPUT -p udp --dport 4000:7000 -j TOS --set-tos Minimize-Delay
}

stop(){
##############  flush everything #####################
  $IPTABLES -F
  $IPTABLES -X
  $IPTABLES -Z
  $IPTABLES -F -t nat
  $IPTABLES -X -t nat
  $IPTABLES -Z -t nat
  $IPTABLES -P INPUT ACCEPT
  $IPTABLES -P OUTPUT ACCEPT
  $IPTABLES -P FORWARD ACCEPT
  

echo -e "\033[1;031m \n"
echo "######################################################"
echo "#   Stop PPTP server Access rule Successfull !       #"
echo "######################################################"
echo e "\033[m \n"
echo ""
}

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
     echo $"Usage:$0" {start|stop|restart}"
     exit 1
esac
exit $?