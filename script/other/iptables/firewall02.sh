#eth0 接外网--ppp0
#eth1 接内网--192.168.0.0/24

#!bin/bash
#
modprobe ipt_MASQUERADE
modprobe ip_conntrack_ftp
modprobe ip_nat_ftp

iptables -F
iptables -t nat -F
iptables -X
iptables -t nat -X
################### INPUT #######################
iptables -P INPUT DROP
iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
iptables -A INPUT -p tcp -m multiport --dports 110,80,25 -j ACCEPT
iptables -A INPUT -p tcp -s 192.168.0.0/24 --dport 139 -j ACCEPT
#允许内网samba，smtp，pop3连接

iptables -A INPUT -i eth1 -p udp -m multiport --dports 53 -j ACCEPT
#允许DNS连接

iptables -A INPUT -p tcp --dport 1723 -j ACCEPT
iptables -A INPUT -p gre -j ACCEPT
#允许外网VPN连接

iptables -A INPUT -s 192.168.0.0/24 -p tcp -m state --state ESTABLISHED,RELATED -j ACCEPT
iptables -A INPUT -i ppp0 -p tcp --syn -m connlimit --connlimit-above 15 -j DROP
#防止DOS太多连接，最多允许15个

iptables -A INPUT -p icmp -m limit --limit 3/s -j LOG --log-level INFO --log-prefix &quot;ICMP packet IN:&quot;
iptables -A INPUT -p icmp -j DROP
#禁止ICMP通讯 

iptables -t nat -A POSTROUTING -o ppp0 -s 192.168.0.0/24 -j MASQUERADE
#内网转发

iptables -N
iptables -A INPUT -p tcp --syn -j syn-flood
iptables -I syn-flood -p tcp -m limit --limit 3/s --limit-burst 6 -j RETURN
iptables -A syn-flood -j REJECT
#防止SYN轻量攻击

#####################  FORWARD链 ###################################
iptables -P FORWARD DROP
iptables -A FORWARD -p tcp -s 192.168.0.0/24 -m multiport --dports 80.110.21.25,1723 -j DROP
iptables -A FORWARD -p udp -s 192.168.0.0/24 --dport 53 -j ACCEPT
iptables -A FORWARD -p gre -s 192.168.0.0/24 -j ACCEPT
iptables -A FORWARD -P icmp -s 192.168.0.0/24 -j ACCEPT
#允许VPN客户走VPN网络连接外网

iptables -A FORWARD -m state --state ESTABLISHED,RELATED -j ACCEPT
iptables -I FORWARD -p udp --dprot 53 -m string --string &quot;tencent&quot; -m time --timestart 8:00 --timestop 12:30 --days Mon,Tue,Wed,Thu,Fri,Sat -j DROP
iptables -I FORWARD -p udp --dprot 53 -m string --string &quot;TENCENT&quot; -m time --timestart 8:00 --timestop 12:30 --days Mon,Tue,Wed,Thu,Fri,Sat -j DROP
iptables -I FORWARD -p udp --dprot 53 -m string --string &quot;tencent&quot; -m time --timestart 13:00 --timestop 18:00 --days Mon,Tue,Wed,Thu,Fri,Sat -j DROP
iptables -I FORWARD -p udp --dprot 53 -m string --string &quot;TENCENT&quot; -m time --timestart 13:00 --timestop 18:00 --days Mon,Tue,Wed,Thu,Fri,Sat -j DROP
#星期一到星期六的8:00到12:30和13:00到18:00禁止QQ通讯

iptables -I FORWARD -s 192.168.0.0/24 -m string --string &quot;ay2000.net&quot; -j DROP
iptables -I FORWARD -s 192.168.0.0/24 -m string --string &quot;宽屏影院&quot; -j DROP
iptables -I FORWARD -s 192.168.0.0/24 -m string --string &quot;色情&quot; -j DROP
iptables -I FORWARD -s 192.168.0.0/24 -m string --string &quot;广告&quot; -j DROP
#禁止ay2000.net，宽屏影院，色情，广告网页链接！但中文不太理想

iptables -A FORWARD -m ipp2p --edk --kazaa --bit -j DROP
iptables -A FORWARD -p tcp -m ipp2p --ares -j DROP
iptables -A FORWARD -p udp -m ipp2p --kazaa -j DROP
#禁止BT连接

iptables -A FORWARD -p tcp --syn --dport 80 -m connlimit --connlimit-above 15 --connlimit-mask 24 -j DROP
#只允许每组ip同时15个80端口转发

sysctl -w net.ipv4.ip_forward=1 &&gt;/dev/null
#打开转发

sysctl -w net.ipv4.tcp_syncookies-1 &&gt;/dev/null
#打开syncookies(轻量级防止DOS攻击)

synctl -w net.ipv4.netfilter.ip_conntrack_tcp_timeout_established=3800 &&gt;/dev/null
#设置默认TCP连接时长为3800秒(降低连接数)

synctl -w net.ipv4.ip_conntrack_max=300000 &&gt;/dev/null
#设置支持最大连接数为30W

iptables -I INPUT -s 192.168.0.50 -j ACCEPT
iptables -I FORWARD -s 192.168.0.50 -j ACCEPT
#放行管理机器

