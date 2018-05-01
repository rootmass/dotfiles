#!/usr/bin/env python
#-*- coding: utf-8 -*-


'''puppet查询模块,用于查询puppet机器的列表,可以按照计算机组查询

   主要是通过查询puppet的数据库去获得

   writed by yyr'''
import mysql.connector
import re
import types
import pdb
class puppet():
	def __init__(self,puppet_host,username,password,port=5001):
		'''puppet的URL或者ip,port:puppet的数据库端口,默认5001'''
		self.puppet_host = puppet_host
		self.username = username
		self.password = password
		self.port = port

	def groups(self):
		'''获取puppet的组和ip,返回字典类'''
		query = "select hostgroups.name,hostgroups.id from hostgroups"
		connect = mysql.connector.connect(host=self.puppet_host,port=self.port,user=self.username,password=self.password,db="puppet")
		cursor = connect.cursor()
		cursor.execute(query)
		result = cursor.fetchall()
		cursor.close()
		return dict(result)
		
	def hosts(self):
		'''获取主机名和ip,返回字典类'''
		query = "select hosts.name,hosts.ip from hosts"
		connect = mysql.connector.connect(host=self.puppet_host,port=self.port,user=self.username,password=self.password,db="puppet")
		cursor = connect.cursor()
		cursor.execute(query)
		result = cursor.fetchall()
		cursor.close()
		return dict(result)

	def hosts_by_groups(self,groups,verbose=False):
		'''由组名查找对应的主机名和IP,多个组名用逗号隔开,ALL返回所有IP'''
		regex = re.compile(r",",re.I)
		gps = regex.sub("|",groups)
		query = "select hosts.name,hosts.ip from hosts,hostgroups where hosts.hostgroup_id = hostgroups.id and hostgroups.name regexp '%s'" % gps
		if verbose:
			query = "SELECT hosts.name,hosts.ip,hostgroups.name,fact_values.value,parameters.name,parameters.value FROM hosts,hostgroups,parameters,fact_values,fact_names WHERE hosts.hostgroup_id = hostgroups.id AND hosts.id = parameters.reference_id and fact_values.host_id = hosts.id AND fact_values.fact_name_id = fact_names.id AND fact_names.name = 'memorysize' and hostgroups.name regexp '%s'" % gps
		if "ALL" in gps:
			query = query.rsplit("and",1)[0]
		connect = mysql.connector.connect(host=self.puppet_host,port=self.port,user=self.username,password=self.password,db="puppet")
                cursor = connect.cursor()
                cursor.execute(query)
                result = cursor.fetchall()
                cursor.close()
		if verbose:
			result_dict = {}
			for e in result:
				name = e[0].encode()
				ip = e[1].encode()
				role = e[2].encode()
				mem = e[3].encode()
				p_name = e[4].encode()
				value = e[5].encode()
				if result_dict.get(name):
					result_dict[name]["parameters"].update({p_name:value})
				else:
					result_dict.update({name:{"ip":ip,"role":role,"mem":mem,"parameters":{p_name:value}}})
			return result_dict
		else:
                	return dict(result)
	
	def host_by_classes(self,classes):
		'''由puppet类查找对应的服'''
		regex = re.compile(r",",re.I)
		cls= regex.sub("|",classes)
		query_host_classes = "SELECT hosts.name,hosts.ip FROM hosts,host_classes,puppetclasses WHERE \
		puppetclasses.name regexp '%s' AND puppetclasses.id = host_classes.puppetclass_id AND host_classes.host_id = hosts.id" % cls
		query_group_classes = "SELECT hosts.name,hosts.ip FROM hosts,hostgroups,hostgroup_classes,puppetclasses WHERE puppetclasses.name regexp '%s' AND \
		puppetclasses.id = hostgroup_classes.puppetclass_id AND hostgroup_classes.hostgroup_id = hostgroups.id AND hostgroups.id = hosts.hostgroup_id;" % cls
		connect = mysql.connector.connect(host=self.puppet_host,port=self.port,user=self.username,password=self.password,db="puppet")
		cursor = connect.cursor()
		cursor.execute(query_host_classes)
		result_host_classes = cursor.fetchall()
		cursor.execute(query_group_classes)
		result_group_classes = cursor.fetchall()
		cursor.close()
		query_result = result_host_classes + result_group_classes
		result = dict(set(query_result))
		#排除中央服
		keys = result.keys()
		for key in keys:
			if "center" in key:
				del(result[key])
		return result

	def host_by_parameter(self,parameter):
		'''由puppet 参数查找对应的服

		   parameter 为一个字典value支持正则'''
		if not type(parameter) == types.DictType:raise Exception("parameter parameter must a dict")
		result = [] 
		connect = mysql.connector.connect(host=self.puppet_host,port=self.port,user=self.username,password=self.password,db="puppet")
		cursor = connect.cursor()
		for name in parameter:
			query = "SELECT hosts.name,hosts.ip FROM hosts,parameters WHERE parameters.reference_id = hosts.id AND parameters.name regexp '%s' AND \
			parameters.value regexp '%s'" % (name,parameter[name])
			cursor.execute(query)
			result.append(cursor.fetchall())
		cursor.close()
		result_set = set()
		for r in result:
			if r:result_set.update(set(r))
		for r in result:
			if r:result_set.intersection_update(set(r))
		return dict(result_set)
	def host_by_condition(self,groups=None,classes=None,parameter=None):
		'''由puppet 组,类,参数联合条件查询主机'''
		super_set = set()
		if groups:
			groups_result = self.hosts_by_groups(groups)
			super_set.update(set(groups_result.items()))
		if classes:
			classes_result = self.host_by_classes(classes)
			super_set.update(set(classes_result.items()))
		if parameter:
			parameter_result = self.host_by_parameter(parameter)
			super_set.update(set(parameter_result.items()))
		if groups:
			super_set.intersection_update(set(groups_result.items()))
		if classes:
			super_set.intersection_update(set(classes_result.items()))
		if parameter:
			super_set.intersection_update(set(parameter_result.items()))
		return dict(super_set)
	
	def host_by_out_of_sync(self):
		cmd = "SELECT ip,name,convert_tz(last_report,'+00:00','+8:00') FROM hosts WHERE TIMESTAMPDIFF(MINUTE,last_report,UTC_TIMESTAMP) > 30 ORDER BY name;"
		connect = mysql.connector.connect(host=self.puppet_host,port=self.port,user=self.username,password=self.password,db="puppet")
		cursor = connect.cursor()
		cursor.execute(cmd)
		result = cursor.fetchall()
		connect.close()
		return result

	def get_puppet_facts(self,hostname=None,ip=None):
		'''由主机名或者IP获得所有的puppet facts

		主机名和ip都为列表或者元组或者关键字ALL,但主机名和IP只能指定其一,当同时指定时以IP为基准'''
		facts = {}
		connect = mysql.connector.connect(host=self.puppet_host,port=self.port,user=self.username,password=self.password,db="puppet")
		cursor = connect.cursor()
		if ip:
			all_ips = ip
			if all_ips == "ALL":
				all_ip_query = "select ip from hosts"
				cursor.execute(all_ip_query)
				all_ips = [i[0] for i in cursor.fetchall()]
			for i in all_ips:
				cmd = "SELECT fact_names.name,fact_values.value FROM hosts,fact_names,fact_values WHERE hosts.id = fact_values.host_id AND \
				fact_values.fact_name_id = fact_names.id AND hosts.ip = '%s'" % i
				cursor.execute(cmd)
				facts[i] = dict(cursor.fetchall())
		elif hostname:
			all_names = hostname
			if all_names == "ALL":
				all_names_query = "select name from hosts"
				cursor.execute(all_names_query)
				all_names = [ i[0] for i in cursor.fetchall()]
			for h in all_names:
				cmd = "SELECT fact_names.name,fact_values.value FROM `hosts`,fact_names,fact_values WHERE hosts.id = fact_values.host_id AND \
				fact_values.fact_name_id = fact_names.id AND hosts.name = '%s'" % h
				cursor.execute(cmd)
				facts[h] = dict(cursor.fetchall())
		cursor.close()
		connect.close()
		return facts
