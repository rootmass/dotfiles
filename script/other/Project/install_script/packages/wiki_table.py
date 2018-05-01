#!/usr/bin/env python
#-*- coding:utf-8 -*-
'''分析WIKI当中的表,反回成列表

  列表元素为元组,元组由WIKI表的一行每列组成'''

import sys
reload(sys)
sys.setdefaultencoding('utf-8')
import lxml.html
import urllib
import datetime
import re
import syslog
import ConfigParser

class wiki_table():
	def __init__(self,url,translate):
		self.url = url
		self.config = ConfigParser.ConfigParser()
		self.config_file = self.config.read(translate)
	def to_list(self,include=None):
		http_connect = urllib.urlopen(self.url)
		if http_connect.code != 200:
			raise Exception("URL:%s return code is not 200") % self.url
		raw_data = http_connect.read()
		html = lxml.html.fromstring(raw_data)
		result = []
		table_rows = html.cssselect("tr")
		for row in table_rows:
			r = []
			for td in row.cssselect("td"):
				element = unicode(td.text_content()).replace(u'\xa0',u'')
				r.append(element)
			if len(r) > 0:result.append(r)
		this_year = datetime.datetime.today().strftime("%Y")
		for r in result:
			#转换wiki上的服数格式成s<服数>的格式
			match = re.match(u"(\d+)",r[2])
			if match:
				r[2] = "s%s" % match.group(1)
			else:
				result.remove(r)
				message = '"fail","代理 %s,服数 %s,转换服数格式失败,任务去除这个代理"' % (r[1],r[2])
			#转换wiki上的时间格式'MM-DD H点'为'YYYY-mm-DD H:M:S'
			try:
				match = re.match(u'(\d+-\d+ \d+)\u70b9',r[0])
				r[0] = "%s-%s:00:00" % (this_year,match.group(1))
				if include:
					if include not in r[0]:
						result.remove(r)
						continue
			except Exception,err:
				result.remove(r)
				message = '"fail","代理 %s,服数 %s,转换时间格式失败,任务去除这个代理:%s"' % (r[1],r[2],err)
				print "\033[1;31m%s\033[0m" % message
				syslog.syslog(syslog.LOG_ERR,message)
			#按照转换表translate,转换wiki上的中文代理成英文代理
			match = re.search(u'[\u4e00-\u9fa5]',r[1])
			if match:
				try:
					r[1] = self.config.get("agent_chinese",r[1].encode('utf-8'))
				except Exception,err:
					result.remove(r)
					message = '"fail","代理 %s,服数 %s,转换中文代理名称失败,任务去除这个代理:%s"' % (r[1],r[2],err)
					print "\033[1;31m%s\033[0m" % message
					syslog.syslog(syslog.LOG_ERR,message)
			r.append("single")
		return result 
