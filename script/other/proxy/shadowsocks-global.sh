#!/usr/bin/env bash
# Copyright©K7zy
# CreateTime: 2017-07-16 14:32:04
# Create new chain

IP="104.148.55.42"
LOCAL_PORT="1080"
SSGLOBAL_PORT="51342"


iptables -t nat -N SSGLOBAL
iptables -t mangle -N SSGLOBAL

# Ignore your shadowsocks server's addresses
# It's very IMPORTANT, just be careful.
# Note 123.123.123.123 is the same as the remote server in /etc/config/shadowsocks.json
iptables -t nat -A SSGLOBAL -d ${IP} -j RETURN

# Ignore LANs and any other addresses you'd like to bypass the proxy
# See Wikipedia and RFC5735 for full list of reserved networks.
# See ashi009/bestroutetb for a highly optimized CHN route list.
iptables -t nat -A SSGLOBAL -d 0.0.0.0/8 -j RETURN
iptables -t nat -A SSGLOBAL -d 10.0.0.0/8 -j RETURN
iptables -t nat -A SSGLOBAL -d 127.0.0.0/8 -j RETURN
iptables -t nat -A SSGLOBAL -d 169.254.0.0/16 -j RETURN
iptables -t nat -A SSGLOBAL -d 172.16.0.0/12 -j RETURN
iptables -t nat -A SSGLOBAL -d 192.168.0.0/16 -j RETURN
iptables -t nat -A SSGLOBAL -d 224.0.0.0/4 -j RETURN
iptables -t nat -A SSGLOBAL -d 240.0.0.0/4 -j RETURN

# Anything else should be redirected to shadowsocks's local port
iptables -t nat -A SSGLOBAL -p tcp -j REDIRECT --to-ports ${LOCAL_PORT}

# Add any UDP rules
ip rule add fwmark 0x01/0x01 table 100
ip route add local 0.0.0.0/0 dev lo table 100
iptables -t mangle -A SSGLOBAL -p udp --dport 53 -j TPROXY --on-port ${LOCAL_PORT} --tproxy-mark 0x01/0x01

# Apply the rules
iptables -t nat -A PREROUTING -p tcp -j SSGLOBAL
iptables -t mangle -A PREROUTING -j SSGLOBAL

# Start the shadowsocks-redir
sslocal -s ny.sscat.win -p 51342 -k wtCA90viGJ -l 1080 -t 600 -m aes-256-cfb

# Up to 32 connections are enough for normal usage
# iptables -A INPUT -p tcp --syn --dport ${SSGLOBAL_PORT} -m connlimit --connlimit-above 32 -j REJECT --reject-with tcp-reset
