#!/local/bin/python
# -*- coding: utf-8 -*-
'''dnspod操作类'''
from dnspod.apicn import *
import os
import time

class dnspod_op():
	def __init__(self,email,password):
		self.email = email
		self.password = password
		self.records = None

	def domain_list(self):
		'''获取domain的属性'''
		api = DomainList(self.email,self.password)
		domain_stats = api()
		return domain_stats
	
	def domain_id(self):
		'''获取domain_id'''
		domain_stats = self.domain_list()
		id = domain_stats.get("domains")[0].get("id")
		return id

	def domain_name(self):
		'''获取domain_name'''
		domain_stats = self.domain_list()
		name = domain_stats.get("domains")[0].get("name")
		return name

	def cache(self,cache,timeout):
		'''缓存查询到所有的DNSPOD记录到内存,timeout缓存时间(2h)'''
		out_of = True
		if os.path.isfile(cache):
			cache_time = os.path.getmtime(cache)
			if time.time() - cache_time < timeout:
				out_of = False

	def all_records(self,cache="/tmp/dnspod.cache",timeout=7200):
		'''查询所有dnspod的记录'''
		out_of_time = self.cache(cache,timeout)
		if out_of_time == False:
			file = open(cache,"r")
			content = file.read()
			if len(content) > 0:
				records = eval(content)
			else:
				records = list()
			file.close
		else:
			id = self.domain_id()
			api = RecordList(id,email=self.email,password=self.password)
			records = api().get("records")
			file = open(cache,"w")
			file.write(str(records))
			file.close()
		self.records = records
		return self.records
			
	def get_domain_by_ip(self,ip):
		'''由IP查询到对应的域名'''
		if not self.records:self.all_records()
		domain_name = self.domain_name()
		DnsName = None
		for record in self.records:
			if record.get("value") == ip:
				DnsName = record.get("name")+"."+domain_name
				break
		return DnsName	
