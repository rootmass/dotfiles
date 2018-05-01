#!/usr/bin/env python
# -*- coding: utf-8 -*-

'''分析选项列表类

用于分析选项当中指定范围,返回一个元组或者列表
如4399_s1~4399_s4,4399_s7~4399_s15,4399_s20,91wan_s3~91wan_s10,37wan_s3,....
会返回一个4399_S1,4399_S2,....4399_S4,4399_s7,4399_s8,...4399_s15,4399_s20,91wan_s3,91wan_s4,91wan_s5,....91wan_s10,37wan_s3,....
的元组或者列表

write by yyr'''

import re

class parse_list():
	def __init__(self,lists=False):
		'''lists为true时返回列表,否则返回元组'''
		self.global_list = list()
		self.lists = lists

	def parse(self,elements):
		'''分析出带有范围的列表,参数elements的类型为列表'''
		regex_range = re.compile(r"([^~]+[^\d]+)([\d]+)~([^~]+[^\d]+)([\d]+)")
		result_list = list()
		for element in elements:
			if regex_range.match(element):
				m = regex_range.match(element)
				if m.group(1) == m.group(3) and int(m.group(2)) <= int(m.group(4)):
					for i in range(int(m.group(2)),int(m.group(4))+1):
						result_list.append(m.group(1)+str(i))
				else:
					raise Exception("%s格式不对" % element)
			else:
				result_list.append(element)
		#去除出现重复的元素
		result_list = list(set(result_list))
		#扩展类列表
		self.global_list.extend(result_list)
		#去除出现重复的元素
		self.global_list = list(set(self.global_list))		
		if self.lists:
			return result_list
		else:
			return tuple(result_list)

	def parse_string(self,string):
		'''分析字符串'''
		elements = string.strip().strip(",").split(",")
		#调用分析范围列表函数
		return self.parse(elements)
		
	def parse_file(self,file):
		'''分析文件,

		文件格式例子如下:
		4399_s6~4399_s10,4399_s12
		91wan_s3
		91wan_s6~91wan_s66,37wan_s2~37wan_s5,7789_s3
		qq163_s8 

		write by yyr'''
		elements = list()
		file = open(file,"r")
		lines = file.readlines()
		file.close()
		for line in lines:
			elements.extend(line.strip().strip(",").split(","))
		#调用分析范围列表函数
		return self.parse(elements)		
		
