#!/usr/bin/env python
# -*- coding: utf-8 -*-

import subprocess
import re
from yunwei.puppet import puppet
from yunwei.ssh import ssh
from yunwei.parallel import ThreadQueue
import pymongo
import mysql.connector
import Queue
import pdb
import sys
reload(sys)
sys.setdefaultencoding('utf-8')
'''斗破乾坤机器类'''

class dpqk_machine():

	def __init__(self,puppet_host,puppet_port,puppet_user,puppet_password):
		self.puppet_host = puppet_host
		self.puppet_port = puppet_port
		self.puppet_user = puppet_user
		self.puppet_password = puppet_password
		self.all ={}
	def machine_game_count(self,ip):
		'''由IP查找到上面安装的游戏服的数量'''
		cmd = 'find /data/agent -name "topo.xml" | xargs grep -E -l "%s"|wc -l' % ip
		p = subprocess.PIPE
		run = subprocess.Popen(cmd,stdout=p,stderr=p,shell=True)
		stdout,stderr = run.communicate()
		if run.returncode != 0:
			raise Exception(stderr)
		num = stdout.strip()
		count = int(num)
		return count
	
	def machine_mongo_count(self,ip,port_string):
		'''由ip查到机器上面的mongo资源使用情况
		   port_string为puppet上的mongo_ports变量参数'''
		mongo_ports = []
		total_count = 0
		if port_string:
			if re.match(r"(\d+)-(\d+)",port_string):
				match = re.match(r"(\d+)-(\d+)",port_string)
				mongo_ports = range(int(match.group(1)),int(match.group(2))+1)
			elif re.match(r"\d+\s*\d*",port_string):
				mongo_ports = port_string.split()
		mongo_count = {}
		for port in mongo_ports:
			port = int(port)
			connection = pymongo.Connection(host=ip,port=port)
			count = len(connection.database_names())
			mongo_count[port] = count
			total_count = total_count+count
			connection.close()
		return total_count,mongo_count	

	def machine_mysql_count(self,ip,port_string):
		'''获取mysql资源使用情况
		   port_string为puppet上的mysql_source变量参数'''
		mysql_ports = []
		total_count = 0
		if port_string:
			if re.match(r"\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}:(\d+)-(\d+)",port_string):
				match = re.match(r"\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}:(\d+)-(\d+)",port_string)
				mysql_ports = range(int(match.group(1)),int(match.group(2))+1)
			elif re.match(r"\d+\s+\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}\s+\d+;?.*",port_string):
				mysql_port_string = re.sub(r"\s+\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}\s+\d+;?",",",port_string)
				mysql_ports = mysql_port_string.strip(",").split(",")
		mysql_count = {}
		for port in mysql_ports:
			port = int(port)
			cnx = mysql.connector.connect(host=ip,port=port,user="game",password="Exia@LeYou",connection_timeout=10)
			cursor = cnx.cursor()
			cursor.execute("show databases where `database` regexp '[[:alnum:]]+_[xs][[:digit:]]+'")
			result = cursor.fetchall()
			count = len(result)
			total_count = total_count+count
			mysql_count[port] = count
			cnx.close()
		return total_count,mysql_count

	def machine_web_count(self,ip):
		cmd = """'ls -l /usr/local/nginx/conf/vhost/ | grep -i -E '\\''[[:alnum:]]+_[sx][[:digit:]]+\.conf$'\\''|wc -l'"""
		SSH = ssh(ip)
		stdout,stderr,returncode = SSH.run(cmd,drop_socket=False)
		if returncode != 0:
			raise Exception("%s\n%s" % (stderr,stdout))
		return int(stdout)

	def all_machine(self,threads=50):
		'''获取所有机器的与游戏相关的属性(装服数,数据库实例数,角色.....)'''
		if self.all:return self.all
		p = puppet(self.puppet_host,self.puppet_user,self.puppet_password,self.puppet_port)
		all_machine = p.hosts_by_groups("ALL",verbose=True)
		machine_queue = Queue.Queue()
		for machine in all_machine:
			machine_queue.put({"machine":machine,"property":all_machine[machine]})
		def all_property(queue):
			while True:
				try:
					machine = machine_queue.get()
					ip = machine["property"]["ip"]
					if re.match(r"gameservermongo|gameservermongoweb",machine["property"]["role"],re.I):
						mongo_string = machine["property"]["parameters"].get("mongo_ports")
						game_count = self.machine_game_count(ip)
						mongo_total,mongo_count = self.machine_mongo_count(ip,mongo_string)
						self.all.update({machine["machine"]:machine["property"]})
						self.all[machine["machine"]].update({"game_count":game_count,"mongo":mongo_count,"web":"N/A","mysql_total":"N/A",\
						"mongo_total":mongo_total})
					elif re.match(r"mysql",machine["property"]["role"],re.I):
						mysql_string = machine["property"]["parameters"].get("mysql_source")
						mysql_total,mysql_count = self.machine_mysql_count(ip,mysql_string)
						self.all.update({machine["machine"]:machine["property"]})
						self.all[machine["machine"]].update({"game_count":"N/A","mysql":mysql_count,"web":"N/A","mongo_total":"N/A",\
						"mysql_total":mysql_total})
					elif re.match(r"web",machine["property"]["role"],re.I):
						web_count = self.machine_web_count(machine["property"]["ip"])
						self.all.update({machine["machine"]:machine["property"]})
						self.all[machine["machine"]].update({"game_count":"N/A","web":web_count,"mysql_total":"N/A","mongo_total":"N/A"})
					elif re.match(r"all_in_one",machine["property"]["role"],re.I):
						mongo_string = machine["property"]["parameters"].get("mongo_ports")
						mysql_string = machine["property"]["parameters"].get("mysql_source")
						game_count = "N/A"
						mongo_count = {}
						mongo_total = 0
						mysql_count = {}
						mysql_total = 0
						if mongo_string:
							mongo_total,mongo_count = self.machine_mongo_count(ip,mongo_string)
							game_count = self.machine_game_count(ip)
						if mysql_string:mysql_total,mysql_count = self.machine_mysql_count(ip,mysql_string)
						self.all.update({machine["machine"]:machine["property"]})
						self.all[machine["machine"]].update({"game_count":game_count,"mongo":mongo_count,"mysql":mysql_count,"web":"N/A",\
						"mongo":mongo_count,"mysql":mysql_count,"mongo_total":mongo_total,"mysql_total":mysql_total})
					else:
						self.all.update({machine["machine"]:machine["property"]})
						self.all[machine["machine"]].update({"game_count":"N/A","mongo_total":"N/A","mysql_total":"N/A","web":"N/A"})
				except Exception,err:
					message = '"fail","获取%s的属性失败:%s"' % (machine["machine"],err)
					print "\033[1;31m%s\033[0m" % message
				finally:
					queue.task_done()
		ThreadQueue(all_property,threads,machine_queue)	
		return self.all		
					
	def dynamic_get_machine (self):
		'''从puppet上查找gameservermongo,mysql,web的IP'''
		p = puppet(self.puppet_host,self.puppet_user,self.puppet_password,self.puppet_port)
		gameserver_mongo = p.hosts_by_groups("gameservermongo")
		mysqls = p.hosts_by_groups("mysql")
		webs = p.host_by_classes("nginx")
		return gameserver_mongo,webs,mysqls

	def get_cluster_from_name(self,name):
		'''从给定的主机名，找出对应的集群名'''
		if re.match(r"(\w+\d+)[ms]\.ly\.xunwan\.com",name,re.I):
			match = re.match(r"(\w+\d+)[ms]\.ly\.xunwan\.com",name,re.I)
		elif re.match(r"([a-zA-Z0-9]+_\d+)_(all|web|gameserver|slave|mysql)\.ly\.xunwan\.com",name,re.I):
			match = re.match(r"([a-zA-Z0-9]+_\d+)_(all|web|gameserver|slave|mysql)\.ly\.xunwan\.com",name,re.I)
		elif re.match(r"([\w_-]+)[_-]\d+_(all|web|gameserver|slave|mysql)\.ly\.xunwan\.com",name,re.I):
			match = re.match(r"([\w_-]+)[_-]\d+_(all|web|gameserver|slave|mysql)\.ly\.xunwan\.com",name,re.I)
		else:
			message = '"WARNING","主机:%s,命名不符合规则"' % name
			raise Exception(message)
		cluster_name = match.group(1)
		return cluster_name

	def get_cluster(self):
		'''从方法dynamic_get_machine反回的三个对象当中探索出集群对象'''
		cluster = {}	
		if not self.all:self.all_machine()
		for machine in self.all:
			try:
				cluster_name = self.get_cluster_from_name(machine)
			except Exception,err:
				message = '"fail","排除%s,信息:%s"' % (machine,err)
				print "\033[1;31m%s\033[0m" % message
				continue
			if cluster_name in cluster:
				cluster[cluster_name].update({machine:self.all[machine]})
			else:
				cluster[cluster_name] = {machine:self.all[machine]}
		return cluster
