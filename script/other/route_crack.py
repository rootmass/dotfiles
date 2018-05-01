#!/usr/bin/env python
# -*- coding: utf-8 -*-
# Copyright©K7zy
# CreateTime: 2016-09-30 16:47:39

import HTMLParser, urlparse, urllib, urllib2, cookielib
import json, subprocess, sys

def crack(address):
    headers = {"User-Agent": "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/53.0.2785.143 Safari/537.36",
            "Referer": "https://www.sufiss.com/ucenter/"}

    payload = {
        "email": "vapije@hostcalls.com",
        "password": "pass654321",
        "task": "login",
        "act": "login",
        "formhash": "29789348"
    }

if __name__ == "__main___":
    if not len(sys.argv) > 3:
        print(sys.argv)
        print("Usage: *.py {ip} {user.txt} {pass.txt}")
    crack()
