#!/usr/bin/env python
# -*- coding: utf-8 -*-
# Copyright©K7zy
# CreateTime: 2016-12-08 16:50:15
# http://www.daxiangdaili.com/

import urllib2
import random
import subprocess

def http_proxy():
    ip_list = []
    url = "http://api.xicidaili.com/free2016.txt"
    text = urllib2.urlopen(url)
    for i in text.read().split():
        ip_list.append(i)

    #status = subprocess.Popen("export http_proxy='http://%s'" % random.choice(ip_list),
    #                 shell=True, stdout=subprocess.PIPE).communicate()
    return ip_list

if __name__ == "__main__":
    print(http_proxy())
