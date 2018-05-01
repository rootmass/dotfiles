#!/usr/bin/env python
#-*- coding: utf-8 -*-



import re

'''网络类,关于一些网络的操作

write by yyr'''
class network():
	def __init__(self,ip):
		self.ip = ip

	def check_ip(self):
		if re.match(r"\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}",self.ip):
			for value in self.ip.split("."):
				if int(value) > 255:
					return False
			return True
		else:
			return False
	
