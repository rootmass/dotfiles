#!/usr/bin/env python3

#-*- coding: utf-8 -*-

import requests


class Scrawler(object):
    def __init__(self, url):
        self.url = url

    def start(self):
        r =  requests.get(self.url)
        text = r.text
        with open('index.html', 'wt') as f:
            f.write(text)
            f.close



if __name__ == "__main__":
    url = "http://ss.ishadowx.com/index_cn.html"
    run  = Scrawler(url)
    run.start()
