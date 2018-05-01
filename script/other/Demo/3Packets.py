#!/usr/bin/env python
# -*- coding: utf-8 -*-
# Copyright©K7zy
# CreateTime: 2016-10-23 00:02:04

from scapy.all import *

dpkt = sniff(iface="wlan0", count = 100)
wrpcap("Packets.pcap", dpkt)
