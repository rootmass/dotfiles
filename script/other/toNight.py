#!/usr/bin/env python
#-*- coding:utf-8 -*-
import sys, os, time, subprocess
import logging, datetime

def compare_time(local_time):
    start_time = time.strftime('%y%m%d') + '0500'
    end_time = time.strftime('%y%m%d') + '1600'

    if (float(local_time) >= float(start_time)) and (float(local_time) <= float(end_time)):
        return True

    return False

def local_address(url):
    local_str= subprocess.Popen("curl ipinfo.io").communicate()

def night_start():
    try:
        #while True:
            #print time.strftime('%Y-%m-%d %H:%M:%S')
        if compare_time(time.strftime('%y%m%d%H%M')):
            subprocess.Popen("flux -l 51 -g -0.381 -k 2400",
                                shell=True, stdout=subprocess.PIPE).communicate()
        else:
            subprocess.Popen("pkill flux ||  flux -l 39.9 -g 116 -k 2400",
                                shell=True, stdout=subprocess.PIPE).communicate()
        #time.sleep(3600)
    except KeyboardInterrupt, e:
        logging.info('signal exit')

if __name__ == '__main__':
    logging.basicConfig(level=logging.DEBUG,
                        format='%(asctime)s %(filename)s[line:%(lineno)d] %(levelname)s %(message)s',
                        datefmt='%a, %d %b %Y %H:%M:%S',
                        filename='/tmp/flux.log',
                        filemode='w')
    night_start()
