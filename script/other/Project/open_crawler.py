#!/usr/bin/env python
# -*- coding:utf-8 -*-

from HTMLParser import HTMLParser
import urllib2, re, sys, os

class MyParser(HTMLParser):
    def __init__(self):
        HTMLParser.__init__(self)

    def handle_starttag(self, tag, attrs):
        items = []
        if tag == 'a':
            for name,value in attrs:
                if name == 'href':
                    m = re.findall('^http://open.163.com/.*', value)
                    if m == []:
                        continue
                    else:
                        items.append(m)
        for i in items:
            urlvar = 'you-get ' + ''.join(i)
            os.system(urlvar)

#url = 'http://open.163.com/special/opencourse/cs50.html'
if len (sys.argv) < 2:
    print('Usage: *.py <url>')
    sys.exit(1)
else:
    url = sys.argv[1]

page = urllib2.urlopen(url)
info = page.read()

if __name__ == '__main__':
    crawler = MyParser()
    crawler.feed(info)
