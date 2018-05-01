#!/usr/bin/env python
# -*- coding: utf-8 -*-

import sys
import os
import subprocess
import re
import xml.etree.ElementTree as ET
import Queue
import time
import syslog
import pdb
import urllib
import types
import dns.resolver
import mysql.connector
from yunwei.php import phpoperate,phplog
from yunwei.parallel import ThreadQueue
from yunwei.ssh import ssh
from yunwei.network import network
from yunwei.puppet import puppet
from yunwei.parse_list import parse_list

class dpqk():
	'''斗破乾坤操作类,包括查询,开启,关闭,重启功能

	通过提供任务列表(可能静态文件列表,手工指定,后台id获得),和并行线程数来并行执行操作.'''
	def __init__(self,waittime=5,logfile=None,errlog=None):
		self.waittime = waittime
		self.logfile = logfile
		self.errlog = errlog
		#初始化日志
		self.log = phplog(self.logfile)
		self.errlog = phplog(self.errlog,verbose=False)
		syslog.openlog(os.path.basename(sys.argv[0]))
		#定义错误收集队列(用于记录任务集的最终状态,只要有一个任务失败最终状态就失败)
		self.error_queue = Queue.Queue()
		self.all_web = {}

	def check_topo_name(self,toponame):
		'''检查拓扑的名字是否符合规范'''
		reg = re.compile(r"^[\w]+_[sxt][\d]+$",re.I)
		if reg.match(toponame):
			return 0
		else:
			return 1

	def get_all_agent(self,center,config_dir="/data/agent",language=None,sshport=22):
		'''通过分析中央服配置文件获取所有代理列表'''
		cmd = r"""'find %s -mindepth 2 -maxdepth 2 -regextype posix-extended -iregex ".*/[stx][0-9]+$" | gawk -F'\''/'\'' '\''{print $(NF-1)"_"$NF}'\'''""" % config_dir
		SSH = ssh(host=center,port=sshport,timeout=10)
		stdout,stderr,returncode = SSH.run(cmd,drop_socket=False)
		return stdout.strip().split("\n")

	def get_all_agent_lang(self,center,language,language_agent,config_dir="/data/agent",sshport=22):
		'''获取所有代理的扩展,支持用语言版本获取所属的代理
		   language_agent为语言版本和代理的字典,由配置文件monitor_center.conf指定'''
		if language == "sc":
			exclude = "$(NF-1) !~/%s/" % "|".join(language_agent.values())
		else:
			exclude = "$(NF-1) ~/%s/" % language_agent[language]	
		cmd = r"""'find %s -mindepth 2 -maxdepth 2 -regextype posix-extended -iregex ".*/[stx][0-9]+$" | gawk -F'\''/'\'' '\''%s{print $(NF-1)"_"$NF}'\'''""" % \
		(config_dir,exclude)
		SSH = ssh(host=center,port=sshport,timeout=10)
		stdout,stderr,returncode = SSH.run(cmd,drop_socket=False)
		return stdout.strip().split("\n")

	def gethefu(self,hefu_url,ca_file,cert_file,key_file):
		'''获取合服列表,通过访问中央服合服URL获取合服列表'''
		URLopener = urllib.URLopener(ca_file=ca_file,cert_file=cert_file,key_file=key_file)
		result = URLopener.open(hefu_url).read()
		hefu_list = result.strip().split("\n")
		return hefu_list

	def merge_change(self,change_list,config,list_type=None,reverse=False):
		'''合服与单服的相向转换
		   config为配置文件的对象,即ConfigParser.read(filename)反回的对象
		   reverse,是否反向转换,即由合服反向转换为单服'''
		if not config.has_section("merge_info"):raise Exception("配置文件当中没有合服信息的相关配置")
		#在配置文件当中读取所有合成服列表
		merge_servers = config.options("merge_info")
		set_change_list = set(change_list)
		if not list_type:list_type = ""
		if reverse == True:
			for merge_server in merge_servers:
				if merge_server in set_change_list:
					#引用列表分析类
					parse = parse_list(lists=False)
					#取得已经合服的单服
					standards_string = config.get("merge_info",merge_server)
					standard = parse.parse_string(standards_string)
					set_standard = set(standard)
					#移除任务列表当中的合成服
					set_change_list.remove(merge_server)
					#把合成服的单服添加到任务列表当中
					set_change_list.update(set_standard)
					message = "列表%s当中的%s合服已经转换为单服列表%s" % (list_type,merge_server,standards_string)
					print "\033[1;32m%s\033[0m" % message
					syslog.syslog(message)
		else:
			for merge_server in merge_servers:
				#引用列表分析类
				parse = parse_list(lists=False)
				#获取已经合服的单服
				standards_string = config.get("merge_info",merge_server)
				standard = parse.parse_string(standards_string)
				set_standard = set(standard)
				#判断任务列表当中有没有已经合了服的单服
				set_interval = set_change_list.intersection(set_standard)
				if len(set_interval) < 1:
					continue
				#任务列表当中合有同一合成服当中的部分单服的情况
				if not set_standard.issubset(set_change_list):
					set_difference = set_standard.difference(set_change_list)
					list_difference = list(set_difference)
					list_interval = list(set_interval)
					list_difference.sort();list_interval.sort()
					diff_string = ','.join(list_difference)
					inter_string = ','.join(list_interval)
					#移除任务列表当中的已经合了服的单服
					set_change_list.difference_update(set_standard)
					#把合成服添加到任务列表当中
					set_change_list.add(merge_server)
					message = "警告:%s的由%s合成,只有%s在%s列表当中,%s却不在列表当中,脚本把%s转换成%s" % \
					(merge_server,standards_string,inter_string,list_type,diff_string,inter_string,merge_server)
					print "\033[1;33m%s\033[0m" % message
					syslog.syslog(syslog.LOG_WARNING,message)
				else:
					set_change_list.difference_update(set_standard)
					set_change_list.add(merge_server)
					message = "%s列表当中%s转换成%s" % (list_type,standards_string,merge_server)
					print "\033[1;32m%s\033[0m" % message
					syslog.syslog(message)
		return list(set_change_list)	

	def cross_info(self):
		'''返回所有跨服战对应的服列表'''
		cmd = """find /data/agent -maxdepth 2 -mindepth 2 -type d  -regextype posix-extended -iregex ".*/.*cross/[stx][0-9]+" """
		p = subprocess.PIPE
		run = subprocess.Popen(cmd,stdout=p,stderr=p,shell=True)
		stdout,stderr = run.communicate()
		if not stdout:
			raise Exception("没有找到任何跨服战")
		all_cross_dir = stdout.strip().split("\n")
		cross_info = dict()
		for dir in all_cross_dir:
			cross_value = list()
			cross_agent,cross_sid = dir.strip().split("/")[-2:]
			cross_xml = ET.parse("%s/logic.xml" % dir)
			xml_root = cross_xml.getroot()
			crosses = xml_root.find("./crosses")
			for cross in crosses:
				agent,sid = cross.get("agent"),cross.get("zone")
				cross_value.append("%s_%s" % (agent,sid))
			#如果跨服战配置不为空就添加到跨服信息字典
			if len(cross_value) > 0:
				cross_info["%s_%s" % (cross_agent,cross_sid)] = set(cross_value)
		return cross_info
						
	def host_query(self,host_list):
		'''由主机IP或者主机域名查找到主机上开的服'''
		if len(host_list) < 1:return list()
		host_string = "|".join(host_list)
		cmd = """find /data/agent/ -name "topo.xml" |xargs grep -l -E "%s"|gawk -F'/' '{print $(NF-2)"_"$(NF-1)}'""" % host_string
		p = subprocess.PIPE
		query = subprocess.Popen(cmd,stdout=p,stderr=p,shell=True)
		stdout,stderr = query.communicate()
		if len(stdout) <=0:
			message = "主机%s 上没有找到任何开服" % host_string
			print "\033[1;31m%s\033[0m" % message
		return stdout.strip().split("\n")

	def Monitor_xml(self,agent,id,config_dir="/data/agent"):
		'''分析中央服Monitor的相关xml文件,反回代理所在的物理服的IP(域名),和物理服的监听端口'''
		try:
			topoxml = ET.parse("%s/%s/%s/topo.xml" % (config_dir,agent,id))
			topo_root = topoxml.getroot()
			host = topo_root.find("group").get("ip")
			port = int(topo_root.find("group").get("port"))
		except Exception,err:
			message = '"fail","获取代理%s_%s 的host和port失败"' % (agent,id)
			syslog.syslog(syslog.LOG_ERR,message)
                        self.log.savelog(message,color="Error")
                        if self.errlog:
                        	self.errlog.savelog(message)
			raise Exception(message)
		return host,port

	def topo_xml (self,agent,id,config_dir="/data/agent"):
		'''分析中央服Monitor的相关xml文件,反回代理的进程元组'''
		topoxml = ET.parse("%s/%s/%s/topo.xml" % (config_dir,agent,id))
		topo_root = topoxml.getroot()
		processes = topo_root.findall("./group/process")
		processes_list = list()
		for p in processes:
			Ares = p.get("exe")
			args = ""
			for i in p:
				args = args+" "+i.get("value")
			processes_list.append(Ares+args)
		return tuple(processes_list)

	def monitor_query(self,agent,id):
		'''查询游戏运行状态,返回游戏程序运行信息和版本号'''	
		host,port = self.Monitor_xml(agent,id)
		cmd = "/data/monitor/Monitor --query-topo=%s_%s --host %s --port %s" % (agent,id,host,port)
		query = subprocess.Popen(cmd,stdout=subprocess.PIPE,stderr=subprocess.PIPE,shell=True)
		stdout,stderr = query.communicate()
		ptree = ET.fromstring(stdout)
		output = ""
		processes = ptree.findall("./host/process")
		version_element = ptree.find("./host/process/user_output")
		version = dict()
		if version_element != None:
			version.update(eval(version_element.text))
		for p in processes:
			Ares = p.get("exe")
			argvs = ""
			for arg in p:
				if arg.get("value"):
					argvs = argvs+" "+arg.get("value")
			output = output+Ares+argvs+"\n"
		return output,version
	
	def ps_query(self,agent,id,host,sshport=22):
		'''以ps的方式查询游戏运行状态,返回游戏程序运行信息和版本号'''
		cmd = """'pgrep -lf "^(\./Ares|\./LogServer) .+ .*/%s_%s_" || exit 0 '""" % (agent,id)
		cmd_version = r"""'grep -o -E '\''\{"server":\{"version":".+","time":".+"\},"client":\{"version":".+","time":".+"\}\}'\'' /data/monitor/conf/%s_%s_logic.xml || exit 0'""" % (agent,id)
		try:
			SSH = ssh(host=host,port=sshport,timeout=10)
			stdout,stderr,returncode = SSH.run(cmd,drop_socket=False)
			if returncode != 0:raise Exception(stderr)
			output = stdout
		except Exception,err:
			raise Exception(err)
		version = dict()
		try:
			stdout,stderr,returncode = SSH.run(cmd_version,drop_socket=False)
			if returncode != 0:raise Exception(stderr)
		except Exception,err:
                        raise Exception(err)
		if len(stdout) > 0:
			version.update(eval(stdout))
		return output,version

	def change_version(self,agent,id,ServerVersion=None,ClientVersion=None):
		'''替换代理配置文件当中的相应版本号,特别用于紧急维护'''
		host,port = self.Monitor_xml(agent,id)
		if ServerVersion:
			#判断代理上面存不存在版本
			try:
				remote = ssh(host)
				stdout,stderr,returncode = remote.run("test -d /data/server/%s" % ServerVersion,drop_socket=False)
				if returncode != 0:
					message = '"fail","远程服务器%s不存在服务端版本%s"' % (host,ServerVersion)
					raise Exception(message)
			except Exception,err:
				raise Exception(err)		
			topoxml_cmd = r"""sed -r -i -e 's@path="[^"]+"@path="/data/server/%s"@' -e 's/"ver=[^"]*"/"ver=%s"/' /data/agent/%s/%s/topo.xml""" % \
			(ServerVersion,ServerVersion,agent,id)
			logicxml_cmd =r"""sed -r -i 's/("server":\{"version":)"[^"]*"/\1"%s"/' /data/agent/%s/%s/logic.xml""" % (ServerVersion,agent,id)
			cmd = topoxml_cmd+";"+logicxml_cmd
			try:
				change = subprocess.Popen(cmd,stdout=subprocess.PIPE,stderr=subprocess.PIPE,shell=True)
				stdout,stderr = change.communicate()
			except Exception,err:
				message = '"fail","修改%s_%s服务端配置失败,失败信息:%s"' % (agent,id,err)
				raise Exception(message)

		if ClientVersion:
			#判断cdn上面存不存在版本
			#code = urllib.urlopen("http://dpqk.cdn.ly.xunwan.com/%s/config.o" % ClientVersion).getcode()
        		#if code != 200:
                	#	message = '"fail","cdn http://dpqk.cdn.ly.xunwan.com 上不存在客户端版本%s"' % ClientVersion
			#	raise Exception(message)
			cmd = r"""sed -r -i 's/("client":\{"version":)"[^"]*"/\1"%s"/' /data/agent/%s/%s/logic.xml""" % (ClientVersion,agent,id)
			try:
                                change = subprocess.Popen(cmd,stdout=subprocess.PIPE,stderr=subprocess.PIPE,shell=True)
                                stdout,stderr = change.communicate()
                        except Exception,err:
                                message = '"fail","修改%s_%s客户端配置失败,失败信息:%s"' % (agent,id,err)
                                raise Exception(message)

			
	def state(self,agent,id,monitor=False,config_dir="/data/agent",sshport=22):
		try:
			host,port = self.Monitor_xml(agent,id,config_dir)
		except Exception,err:
			raise Exception(err)
		#获取配置文件当中的进程信息
		try:
			config_processes = self.topo_xml(agent,id,config_dir)
		except Exception,err:
			raise Exception(err)
		#获取游戏运行的进程信息
		try:
			if monitor == False:
				running_processes,version = self.ps_query(agent,id,host,sshport)
			else:
				running_processes,version = self.monitor_query(agent,id)
		except Exception,err:
			raise Exception(err)

		if not running_processes:
			string = "代理%s_%s处于关闭当中" % (agent,id)
			running = "false"
		else:
			running = "true"
			string = running_processes
			for p in config_processes:
				if p not in running_processes:
					string = "代理%s_%s,所在物理服%s,%s不在进程当中,状态异常" % (agent,id,host,p)
					running = "unknown"
					break
			if not version:
				running = "unknown"
				string = string + "\n没有版本信息返回"
		
		output = "\n##############%s_%s#############\n" % (agent,id)
		output = output+string
		return output,running,version
			
			

					
	def query(self,tasklist,monitor=False):
		while True:
			toponame = tasklist.get()
			result = self.check_topo_name(toponame)
			if result == 0:
				agent,id = toponame.rsplit("_",1)
				try:
					output,running,version = self.state(agent,id,monitor)
					if running == "true":
						message = "%s\nserver:%s client:%s\n" % (output,version["server"]["version"],version["client"]["version"])
					elif running == "unknown":
						message = "\033[1;31m%s\033[0m" % output
					else:
						message = output
					print message
				except Exception,err:
					message = "查询%s状态出错,出错信息:%s" % (toponame,err)
					print "\033[0m%s\033[0m" % message
					tasklist.task_done()
					continue
			else:
				message = '"fail","%s 的拓扑名不符合规范"' % toponame
				syslog.syslog(syslog.LOG_ERR,message)
				self.log.savelog(message,color="Error")
				if self.errlog:
                                                self.errlog.savelog(message)
			tasklist.task_done()
	
	def start(self,agent,monitor=False):
		toponame = agent
                result = self.check_topo_name(toponame)
                if result != 0:
			message = '"fail","%s 的拓扑名不符合规范"' % toponame
			raise Exception(message)
		else:

			agent,id = toponame.rsplit("_",1)
			try:
				host,port = self.Monitor_xml(agent,id)
			except Exception,err:
				raise Exception(err)
			try:
				output,running,version = self.state(agent,id,monitor)
			except Exception,err:
				raise Exception(err)
			if running == "true":
				message = '"warning","%s_%s 目前状态:开启 执行动作:开启 执行结果:停止执行"' % (agent,id)
				syslog.syslog(syslog.LOG_WARNING,message)
				self.log.savelog(message,color="Warning")
			elif running == "unknown":
				message = '"fail","%s_%s 目前状态:半开启 执行动作:开启 执行结果:停止执行,信息%s"' % (agent,id,output)
				raise Exception(message)
			elif running == "false":
				cmd = "/data/monitor/Monitor --start=%s_%s --topo-file=/data/agent/%s/%s/topo.xml \
				--logic-file=/data/agent/%s/%s/logic.xml --host=%s --port=%d" % (agent,id,agent,id,agent,id,host,port)
				for r in range(1,4):
					print os.popen(cmd).read()
					for i in range(1,4):
						time.sleep(self.waittime)
						try:
							output,running,version = self.state(agent,id,monitor)
						except Exception,err:
							self.log.savelog(err,color="Error")
                        			        syslog.syslog(syslog.LOG_ERR,str(err))
                        			        if self.errlog:
                        			                self.errlog.savelog(err)
							continue
		
						if running == "true":
							message='"success","%s_%s 目前状态:关闭 执行动作:开启 执行结果:开启%d次成功"' % (agent,id,r)
							self.log.savelog(message,color="Success")
							syslog.syslog(message)
							break
						else:
							print "%s_%s 经过%d秒还在开启中...." % (agent,id,i*self.waittime)
					else:
						if r < 3:
							print "%s_%s 经过%d秒后还没有开启成功,现尝试进行第%d次启动" % (agent,id,i*self.waittime,r+1)
						continue
					break
				else:
					if running == "unknown":
						message='"fail","%s_%s 目前状态:半开启 执行动作:开启 执行结果:已经尝试%d次启动失败,%s"' % (agent,id,r,output)
					else:
						message='"fail","%s_%s 目前状态:关闭 执行动作:开启 执行结果:已经尝试%d次启动失败"' % (agent,id,r)
					raise Exception(message)		
	def stop(self,agent,monitor=False):
		toponame = agent
                result = self.check_topo_name(toponame)
                if result != 0:
			message = '"fail","%s 的拓扑名不符合规范"' % toponame
			raise Exception(message)
		else:
	                agent,id = toponame.rsplit("_",1)
			try:
                       		host,port = self.Monitor_xml(agent,id)
                	except Exception,err:
				raise Exception(err)
			try:
				output,running,version = self.state(agent,id,monitor)
			except Exception,err:
				raise Exception(err)
			if running == "false":
				message = '"warning","%s_%s 目前状态:关闭 执行动作:关闭 执行结果:停止执行"' % (agent,id)
				self.log.savelog(message,color="Warning")
				syslog.syslog(syslog.LOG_WARNING,message)
			elif running == "true" or running == "unknown":
				cmd = "/data/monitor/Monitor --stop=%s_%s --topo-file=/data/agent/%s/%s/topo.xml --host=%s --port=%d" % \
				(agent,id,agent,id,host,port)
				for r in range(1,4):
					print os.popen(cmd).read()
					for i in range(1,4):
						time.sleep(self.waittime)
						try:
							output,running,version = self.state(agent,id,monitor)
						except Exception,err:
							self.log.savelog(err,color="Error")
                				        syslog.syslog(syslog.LOG_ERR,str(err))
                				        if self.errlog:
                				                self.errlog.savelog(err)
							continue
						if running == "false":
							message='"success","%s_%s 目前状态:开启 执行动作:关闭 执行结果:关闭%d次成功"' % (agent,id,r)
							self.log.savelog(message,color="Success")
							syslog.syslog(message)
							break
						else:
							print "%s_%s 经过%d秒还在关闭中...." % (agent,id,i*self.waittime)
					else:
						if r < 3:
							print "%s_%s 经过%d秒后还没有关闭成功,现尝试进行第%d次关闭" % (agent,id,i*self.waittime,r+1)
						continue
					break
				else:
					message='"fail","%s_%s 目前状态:开启 执行动作:关闭 执行结果:已经尝试%d次关闭失败"' % (agent,id,r)
					raise Exception(message)
					
	def reload (self,agent,ClientVersion,monitor=False):
                toponame = agent
                result = self.check_topo_name(toponame)
                if result != 0:
			message = '"fail","%s 的拓扑名不符合规范"' % toponame
			raise Exception(message)
                else:
			agent,id = toponame.rsplit("_",1)
			try:
                        	host,port = self.Monitor_xml(agent,id)
                	except Exception,err:
				raise Exception(err)
			try:
				output,running,version = self.state(agent,id,monitor)
			except Exception,err:
				raise Exception(err)
			if running == "false":
                                message = '"fail","%s_%s 目前状态:关闭 执行动作:重载 执行结果:停止执行"' % (agent,id)
                               	raise Exception(message)
			else:
				cmd = "/data/monitor/Monitor --reload-topo=%s_%s --topo-file=/data/agent/%s/%s/topo.xml \
                                --logic-file=/data/agent/%s/%s/logic.xml --host=%s --port=%d" % (agent,id,agent,id,agent,id,host,port)
				for r in range(1,4):
					print os.popen(cmd).read()
					for i in range(1,4):
						time.sleep(self.waittime)
						try:
							output,running,parameter = self.state(agent,id,monitor)
						except Exception,err:
							self.log.savelog(message,color="Error")
                				        syslog.syslog(syslog.LOG_ERR,str(err))
                				        if self.errlog:
                				                self.errlog.savelog(err)
							continue
						try:
							current_version = parameter["client"]["version"]
						except:
							current_version = None
						if ClientVersion == current_version:
							message='"success","%s_%s 目前状态:开启 执行动作:重载 执行结果:重载%d次客户端%s成功"' % \
							(agent,id,r,ClientVersion)
							self.log.savelog(message,color="Success")
							syslog.syslog(message)
							break
						else:
							print "%s_%s 经过%d秒还在重载中...." % (agent,id,i*self.waittime)
					else:
						if r < 3:
							print "%s_%s 经过%d秒后还没有重载成功,现尝试进行第%d次重载" % (agent,id,i*self.waittime,r+1)
						continue
					break
				else:
					message='"fail","%s_%s 目前状态:开启 执行动作:重载 执行结果:已经尝试%d次重载客户端%s失败"' % (agent,id,r,ClientVersion)
					raise Exception(message)
						

	def restart(self,agent,ServerVersion=None,ClientVersion=None,monitor=False):
		''' 斗破乾坤重启函数
		
		提供版本号时会检查版本号是否正确(应用于更新重启),不提供版本号为正常重启操作'''
		toponame = agent
                result = self.check_topo_name(toponame)
                if result != 0:
			message = '"fail","%s 的拓扑名不符合规范"' % toponame
			raise Exception(message)
		else:
	                agent,id = toponame.rsplit("_",1)
			try:
                        	host,port = self.Monitor_xml(agent,id)
			except Exception,err:
				raise Exception(err)
			try:
				output,running,parameter = self.state(agent,id,monitor)			
			except Exception,err:
                                raise Exception(err)

		        if running == "false":
		                message = '"warning","%s_%s 目前状态:关闭 执行动作:重启 执行结果:不执行关闭动作"' % (agent,id)
		                print "\033[1;33m%s\033[0m" % message
		                syslog.syslog(message)
		        elif running == "true" or running == "unknown":
		                cmd = "/data/monitor/Monitor --stop=%s_%s --topo-file=/data/agent/%s/%s/topo.xml --host=%s --port=%d" % \
				(agent,id,agent,id,host,port)
		                for r in range(1,4):
		                        print os.popen(cmd).read()
		                        for i in range(1,4):
		                                time.sleep(self.waittime)
		        			try:
							output,running,parameter = self.state(agent,id,monitor)
						except Exception,err:
							self.log.savelog(err,color="Error")
                				        syslog.syslog(syslog.LOG_ERR,str(err))
                				        if self.errlog:
                				                self.errlog.savelog(err)
							continue                       
		                                if running == "false":
		                                        message='"success","%s_%s 目前状态:开启 执行动作:重启 执行结果:关闭%d次成功"' % (agent,id,r)
		                                        print "\033[1;32m%s\033[0m" % message
		                                        syslog.syslog(message)
		                                        break
		                                else:
		                                        print "%s_%s 重启操作经过%d秒还在关闭中...." % (agent,id,i*self.waittime)
		                        else:
		                                if r < 3:
		                                        print "%s_%s 重启操作经过%d秒后还没有关闭成功,现尝试进行第%d次关闭" % (agent,id,i*self.waittime,r+1)
		                                continue
		                        break
		                else:
					if running == "unknown":
						message='"fail","%s_%s 目前状态:开启 执行动作:重启 执行结果:尝试%d次关闭失败,重启失败,%s"' % (agent,id,r,output)
					else:
		                        	message='"fail","%s_%s 目前状态:开启 执行动作:重启 执行结果:尝试%d次关闭失败,重启失败"' % (agent,id,r)
					raise Exception(message)
			cmd = "/data/monitor/Monitor --start=%s_%s --topo-file=/data/agent/%s/%s/topo.xml --logic-file=/data/agent/%s/%s/logic.xml \
			--host=%s --port=%d" % (agent,id,agent,id,agent,id,host,port)
		        for r in range(1,4):
				print os.popen(cmd).read()
		                for i in range(1,4):
		                	time.sleep(self.waittime)
					try:
						output,running,parameter = self.state(agent,id,monitor)
					except Exception,err:
						self.log.savelog(err,color="Error")
                			        syslog.syslog(syslog.LOG_ERR,str(err))
                			        if self.errlog:
                			                self.errlog.savelog(err)
						continue
		                        if running == "true":
						server_version = parameter["server"]["version"]
						client_version = parameter["client"]["version"]
						color = "Success"
						#判断版本号是否一致
						if ServerVersion and ClientVersion:
							if server_version == ServerVersion and client_version == ClientVersion:
								message = '"success","%s_%s 目前状态:关闭 执行动作:重启 执行结果:开启%d次成功,服务端:%s,客户端:%s,重启成功"' % (agent,id,r,ServerVersion,ClientVersion)
								ERR = False
								syslog_type = syslog.LOG_INFO
                                                	else:
								message = '"success","%s_%s 目前状态:关闭 执行动作:重启 执行结果:开启%d次成功,运行服务端版本:%s,更新服务端版本:%s,运行客户端版本:%s,更新客户端版本:%s版本不一致,重启失败"' % (agent,id,r,server_version,ServerVersion,client_version,ClientVersion)
								ERR = True				
								syslog_type = syslog.LOG_ERR
						elif ServerVersion:
							if server_version == ServerVersion:
								message = '"success","%s_%s 目前状态:关闭 执行动作:重启 执行结果:开启%d次成功,服务端版本:%s,重启成功"' % (agent,id,r,ServerVersion)
								ERR = False
								syslog_type = syslog.LOG_INFO
							else:
								message = '"success","%s_%s 目前状态:关闭 执行动作:重启 执行结果:开启%d次成功,运行服务端版本:%s,更新服务端版本:%s,版本不一致,重启失败"' % (agent,id,r,server_version,ServerVersion)
								ERR = True
                                                                syslog_type = syslog.LOG_ERR
						elif ClientVersion:
							if client_version == ClientVersion:
								message = '"success","%s_%s 目前状态:关闭 执行动作:重启 执行结果:开启%d次成功,客户端版本:%s,重启成功"' % (agent,id,r,ClientVersion)
                                                                ERR = False
								syslog_type = syslog.LOG_INFO
							else:
								message = '"success","%s_%s 目前状态:关闭 执行动作:重启 执行结果:开启%d次成功,运行客户端版本:%s,更新客户端版本:%s,版本不一致,重启失败"' % (agent,id,r,client_version,ClientVersion)
								ERR = True
								syslog_type = syslog.LOG_ERR
						else:
		                        		message='"success","%s_%s 目前状态:关闭 执行动作:重启 执行结果:开启%d次成功,重启成功"' % (agent,id,r)
							ERR = False
							syslog_type = syslog.LOG_INFO
						if ERR:
							raise Exception(message)
		                                self.log.savelog(message,color)
		                                syslog.syslog(syslog_type,message)
		                                break
		                        else:
		                                print "%s_%s 重启操作经过%d秒还在开启中...." % (agent,id,i*self.waittime)
		                else:
		                	if r < 3:
		                        	print "%s_%s 重启操作经过%d秒后还没有开启成功,现尝试进行第%d次启动" % (agent,id,i*self.waittime,r+1)
		                	continue
		               	break
			else:	
				if running == "unknown":
					message='"fail","%s_%s 目前状态:半开启 执行动作:重启 执行结果:尝试%d次启动失败,重启失败" %s' % (agent,id,r,output)
				else:
					message='"fail","%s_%s 目前状态:关闭 执行动作:重启 执行结果:尝试%d次启动失败,重启失败"' % (agent,id,r)
				raise Exception(message)
	
	def update(self,agent,ServerVersion=None,ClientVersion=None,monitor=False):
		toponame = agent
                result = self.check_topo_name(toponame)
                if result != 0:
			message = '"fail","%s 的拓扑名不符合规范"' % toponame
                      	raise Exception(message)
		else:
			agent_prefix,id = toponame.rsplit("_",1)
			try:
                                host,port = self.Monitor_xml(agent_prefix,id)
                        except Exception,err:
				raise Exception(err)
			if ServerVersion and ClientVersion:
				try:
					self.change_version(agent_prefix,id,ServerVersion,ClientVersion)
					self.restart(agent,ServerVersion,ClientVersion,monitor)
				except Exception,err:
					raise Exception(err)
			elif ServerVersion:
				try:
                                        self.change_version(agent_prefix,id,ServerVersion)
                                	self.restart(agent,ServerVersion,monitor=monitor)
                                except Exception,err:
					raise Exception(err)
			elif ClientVersion:
				try:
                                        self.change_version(agent_prefix,id,ClientVersion=ClientVersion)
					self.reload(agent,ClientVersion,monitor)
                                except Exception,err:
					raise Exception(err)
			

	def checksum (self,source,dest,host=None,generate=None,checksum=None,port=22):
		basename = os.path.basename(source.rstrip("/"))
		dir = os.path.dirname(source.rstrip("/"))
		parameter = {"port":port,"host":host,"dest":dest,"basename":basename,"source":source,"dir":dir}
		if generate:
			if os.path.isfile(source):
			
				if dir:
					os.popen("cd %(dir)s;md5sum %(basename)s > %(basename)s_source.md5" % parameter)
				else:
					os.popen("md5sum %(basename)s > %(basename)s_source.md5" % parameter)
			else:					
				cmd = 'export LC_ALL=en_US.UTF-8;cd %(source)s && find -type f ! -name "*.md5"|\
				grep -v -E "(.*\.log$|app\.config\.php$|.*\.antlog$|.*\.html.php$|/_log/.+)" |xargs md5sum |sort -k 2 > %(basename)s_source.md5' % parameter
				run = subprocess.Popen(cmd,stdout=subprocess.PIPE,stderr=subprocess.PIPE,shell=True)
				stdout,stderr = run.communicate()
				if run.returncode != 0:
					raise Exception(stderr)
		if checksum:
			if os.path.isfile(source):
				result = subprocess.Popen("""ssh -p %(port)d -o StrictHostKeyChecking=no %(host)s '
				if [ -f "%(dest)s" ];then
					dir = dirname %(dest)s
					basename = basename %(dest)s
					cd $dir;md5sum $basename > ${basename}_dest.md5;
					diff -q ${basename}_dest.md5 %(basename)s_source.md5
				elif [ -d "%(dest)s" ];then
					cd %(dest)s;md5sum %(basename)s > %(basename)s_dest.md5
					diff -q %(basename)s_dest.md5 %(basename)s_source.md5
				else
					echo "目标路径%(dest)s不存在"
					exit 1'"""% parameter,shell=True )
				result.communicate()

			else:
				result = subprocess.Popen("""
				ssh -p %(port)d -o StrictHostKeyChecking=no %(host)s '
				export LC_ALL=en_US.UTF-8				
				dir=$(dirname `find %(dest)s -name %(basename)s_source.md5`)
				[ -z "$dir" ] && { echo "不存在%(basename)s_source.md5 MD5校验文件";exit 1; }
				cd $dir
				find -type f ! -name "*.md5" |grep -v -E "(.*\.log$|app\.config\.php$|.*\.antlog$|.*\.html.php$|/_log/.+)" | xargs md5sum |\
				sort -k 2 > %(basename)s_dest.md5;diff -q %(basename)s_dest.md5 %(basename)s_source.md5'""" % \
				parameter,stdout=subprocess.PIPE,shell=True)
				result.communicate()
			if result.returncode != 0:
				message='"fail","%s:%s md5 校验失败,文件传送失败"' % (host,dest)
	                        self.log.savelog(message,color="Error")
	                        syslog.syslog(syslog.LOG_ERR,message)
	                        if self.errlog:
	                                self.errlog.savelog(message)
				#记录到错误收集队列
                                self.error_queue.put(message)
			elif result.returncode == 0:
				message='"success","%s:%s md5 校验成功,文件传送成功"' % (host,dest)
	                        self.log.savelog(message,color="Success")
	                        syslog.syslog(message)
			else:
				message='"success","%s:%s md5 校验状态未知,文件传送不成功"' % (host,dest)
	                        self.log.savelog(message,color="Error")
	                        syslog.syslog(syslog.LOG_ERR,message)
				if self.errlog:
	                                self.errlog.savelog(message)
				#记录到错误收集队列
                                self.error_queue.put(message)

				

	def sendfile(self,source,dest,host,port=22):
		#创建ssh socket
		SSH = ssh(host=host,port=port,timeout=10)
		SSH.ssh_socket()
		#判断传送源是否存在
		if not os.path.exists(source):
			message='"fail","directory %s is not exist"' % source
                        self.log.savelog(message,color="Error")
                        syslog.syslog(syslog.LOG_ERR,message)
                        if self.errlog:
                                self.errlog.savelog(message)
			exit(1)
		#如果目标服上面没有传送的父目录则创建
		dir_dest = os.path.dirname(dest.rstrip("/"))
		basename_dest = os.path.basename(dest.rstrip("/"))
		dir = os.path.dirname(source.rstrip("/"))
		basename = os.path.basename(source.rstrip("/"))
		parameter = {"source":source,"dest":dest,"host":host,"port":port,"dir_dest":dir_dest,"basename_dest":basename_dest,"dir":dir,"basename":basename}
		p = subprocess.Popen("ssh -p %(port)d -o StrictHostKeyChecking=no %(host)s '[ ! -d %(dir_dest)s ] && mkdir -p %(dir_dest)s'" % parameter,\
		stdout=subprocess.PIPE,shell=True)
		p.communicate()
		print "开始传送%s ....." % basename
		if os.path.isfile(source):		
			os.popen("rsync -avzc --modify-window=31536000 -e 'ssh -p %(port)d -o StrictHostKeyChecking=no' %(source)s %(source)s.md5 %(host)s:%(dest)s" % parameter )
		else:					
			send = subprocess.Popen("rsync -azc --delete --modify-window=31536000 -e 'ssh -p %d -o StrictHostKeyChecking=no' %s %s:%s" \
			% (port,source,host,dest),bufsize=-1,stdout=subprocess.PIPE,stderr=subprocess.PIPE,shell=True )
			send.communicate()
			

	def sendclient (self,tasklist,port=22):
		while True:
			source,remote = tasklist.get().split()
			host,dest = remote.split(":")
			if not source and not host and not dest:
				message='"fail","列表格式不正确"'
				self.log.savelog(message,color="Error")
	                        syslog.syslog(syslog.LOG_ERR,message)
                        	if self.errlog:
                                	self.errlog.savelog(message)
				#记录到错误收集队列
                                self.error_queue.put(message)
				exit(1)
			try:
				#创建ssh socket
				SSH = ssh(host=host,port=port,timeout=10)
				#SSH.ssh_socket()
				#判断有没有客户端版本,没有就直接传,有就复制上一版本成这个版本,再传
				dir_dest = os.path.dirname(dest.rstrip("/"))
				basename_dest = os.path.basename(dest.rstrip("/"))
				basename = os.path.basename(source.rstrip("/"))
				parameter = {"port":port,"host":host,"dest":dest,"basename":basename,"source":source,"dir_dest":dir_dest}
				p = subprocess.Popen("ssh -p %(port)d -o StrictHostKeyChecking=no %(host)s '[ ! -d %(dir_dest)s ] && mkdir -p %(dir_dest)s'" % parameter,\
				stdout=subprocess.PIPE,shell=True)
				p.communicate()
				if re.match(r"\d+\.\d+_\d+",basename):
					p = subprocess.Popen("""ssh -p %(port)d -o StrictHostKeyChecking=no %(host)s '
							cd %(dir_dest)s
							if [ ! -d %(basename)s ];then
								last=`ls -lt | gawk '\\''{if ($NF ~/[0-9]\.[0-9]+_[0-9]+/) print $NF}'\\''|head -n 1`
								[ -n "$last" ] && \
								{ echo %(host)s 上没有%(basename)s这个版本,复制上一版本$last成%(basename)s;
								  rsync -a --exclude=*.md5 $last/ %(basename)s/; }||\
								{ echo %(host)s 上没有任何客户端版本; }
							else
								echo %(host)s 上客户端版本%(basename)s已经存在
							fi'""" % parameter,stdout=subprocess.PIPE,stderr=subprocess.PIPE,shell=True)
					output,error = p.communicate()
					if p.returncode != 0:
						message = '"fail","%s 客户端复制上一版本失败,失败信息为:%s"' % (host,error.rstrip())
						print "\033[1;31m%s\033[0m" % message
						syslog.syslog(syslog.LOG_ERR,message)
						#记录到错误收集队列
                	        	        self.error_queue.put(message)
					else:
						message = '"success","%s 客户端复制上一版本完成,复制信息为:%s"' % (host,output.rstrip())
						print "\033[1;32m%s\033[0m" % message
						syslog.syslog(message)
				#调用传送文件函数
				print "开始传送%s到%s ......" % (source,remote)
				SSH.sendfile(source,dest,delete=True,ModifyTime=time.time(),drop_socket=False)
				#调用校验MD5函数
				self.checksum(source,dest,host,checksum=True)
			except Exception,err:
				tasklist.task_done()
				continue
			tasklist.task_done()

	def sendserver (self,tasklist,port=22):		
		while True:
			source,remote = tasklist.get().split()
			host,dest = remote.split(":")
			if not source and not host and not dest:
				message='"fail","列表格式不正确"'
				self.log.savelog(message,color="Error")
	                        syslog.syslog(syslog.LOG_ERR,message)
                        	if self.errlog:
                                	self.errlog.savelog(message)
				#记录到错误收集队列
                                self.error_queue.put(message)
				exit(1)
			#创建ssh socket
			#SSH = ssh(host=host,port=port)
                        #SSH.ssh_socket()
			#调用传送文件函数
			try:
				SSH = ssh(host=host,port=port,timeout=10)
                    		SSH.sendfile(source,dest,delete=True,drop_socket=False)
			except Exception,err:
				tasklist.task_done()
				continue
			#调用校验MD5函数
			try:
				self.checksum(source,dest,host,checksum=True)
			except Exception,err:
				tasklist.task_done()
				continue	
			tasklist.task_done()
	def sendback(self,tasklist,exclude_from,port=22):
		while True:
			source,remote = tasklist.get().split()
                        host,dest = remote.split(":")
			if not source and not host and not dest:
                                message='"fail","列表格式不正确"'
                                self.log.savelog(message,color="Error")
                                syslog.syslog(syslog.LOG_ERR,message)
                                if self.errlog:
                                        self.errlog.savelog(message)
                                #记录到错误收集队列
                                self.error_queue.put(message)
                                exit(1)
			try:
                                SSH = ssh(host=host,port=port,timeout=10)
                                SSH.sendfile(source,dest,exclude_from=exclude_from,delete=True,drop_socket=False)
                        except Exception,err:
				message = '"file","%s,%s 传送后台文件失败:%s"' % (host,dest,err)
				print "\033[1;31m%s\033[0m" % message
				self.log.savelog(message,color="Error")
                                syslog.syslog(syslog.LOG_ERR,message)
                                if self.errlog:
                                        self.errlog.savelog(message)
                                #记录到错误收集队列
                                self.error_queue.put(message)
                                tasklist.task_done()
                                continue
                        #调用校验MD5函数
                        try:
                                self.checksum(source,dest,host,checksum=True)
                        except Exception,err:
                                tasklist.task_done()
                                continue
                        tasklist.task_done()


	def generate_sync_queue(self,type,version,hostlist,language,language_version):
		'''生成传送文件队列(服务端和客户端和后台)

		由传入的主机序列hostlist生成 source remote:/dest的传送文件格式
	
		language_version为大版本对应的语言信息,为一个字典'''

		#生成发送客户端的任务队列
		if type == "client":
			main_version = language_version[language]
		        clientpath = "/data/client/%s/%s" % (main_version,version)
			assetspath = "/data/client/%s/assets" % main_version
			staticpath = "/data/client/%s/static" % main_version
		        if not os.path.exists(clientpath):
		                message = '"fail","不存在客户端版本号%s"' % version
		                self.log.savelog(message,color="Error")
		                self.errlog.savelog(message)
		                syslog.syslog(message)
				#记录到错误收集队列
                                self.error_queue.put(message)
		                exit(1)
		        #生成MD5
		        print "生成客户端MD5..."
		        self.checksum(clientpath,clientpath,generate=True)
			self.checksum(assetspath,assetspath,generate=True)
			self.checksum(staticpath,staticpath,generate=True)
		        clientlist = Queue.Queue(0)
		        for h in hostlist:
		                clientlist.put("%s/ %s:%s" % (clientpath,h.rstrip(),clientpath))
				clientlist.put("%s/ %s:%s" % (assetspath,h.rstrip(),assetspath))
				clientlist.put("%s/ %s:%s" % (staticpath,h.rstrip(),staticpath))
			return clientlist
		
		#生成服务端的任务队列
		if type == "server":
		        serverpath = "/data/server/"+version
		        if not os.path.exists(serverpath):
		                message = '"fail","不存在服务端版本号%s"' % version
		                self.log.savelog(message,color="Error")
		                self.errlog.savelog(message)
		                syslog.syslog(message)
				#记录到错误收集队列
                                self.error_queue.put(message)
		                exit(1)
		        #生成MD5
		        print "生成服务端MD5..."
		        self.checksum(serverpath,serverpath,generate=True)
		        serverlist = Queue.Queue(0)
		        for h in hostlist:
		                serverlist.put("%s/ %s:/data/server/%s/" % (serverpath,h.rstrip(),version))
			return serverlist
		#生成后台的任务队列
		if type == "background":
			background_path = "/data/php/" + version
			if not os.path.exists(background_path):
                                message = '"fail","不存在后台版本号%s"' % version
                                self.log.savelog(message,color="Error")
                                self.errlog.savelog(message)
                                syslog.syslog(message)
                                #记录到错误收集队列
                                self.error_queue.put(message)
                                exit(1)
			#生成MD5
                        print "生成后台MD5..."
                        self.checksum(background_path,background_path,generate=True)
                        backgroundlist = Queue.Queue(0)
                        for h in hostlist:
				agent,ip = h
                                backgroundlist.put("%s/ %s:/data/www/%s/" % (background_path,ip,agent))
                        return backgroundlist

	def game_property(self,agents,config_url,cert_file,key_file,ca_file,puppet=None,puppet_port=None,puppet_user=None,puppet_passwd=None,puppet_run=None,parallel=20):
		'''查找代理服的一些属性,数据库IP,端口,域名等,返回一个字典

		参数agent为一个列表,如[agent_s1,agent_s2,....],center中央服域名或者IP
		config_url为获取所有代理配置文件的url,puppet为puppet的主机IP或者域名,如果puppet为None不查询puppet属性,domain_suffix为puppet管理域的域名后缀,parallel并行线程数'''

		if type(agents) != types.ListType:
			message = "agent must list"
			raise Exception(message)
		#生成任务队列
                task_queue = Queue.Queue()
                for agent in agents:
                        task_queue.put(agent)	

		#全局容器
		property = dict()
		def GameProperty(task_queue,property):
			while True:
				agent = task_queue.get()
				try:
					if self.check_topo_name(agent) == 1:
						raise Exception("拓扑名%s不符合规范" % agent)
					agent_prefix,id = agent.rsplit("_",1)
					url_topo = "%s/%s/%s/topo.xml" % (config_url,agent_prefix,id)
					url_logic = "%s/%s/%s/logic.xml" % (config_url,agent_prefix,id)
					#建立到config_url的连接
					url_opener = urllib.URLopener(cert_file=cert_file,key_file=key_file,ca_file=ca_file)
					#获取topo字串
                        	        topo_string = url_opener.open(url_topo).read()
					#获取logic字串
					logic_string = url_opener.open(url_logic).read()
					topo = ET.fromstring(topo_string)
					logic = ET.fromstring(logic_string)
				except Exception,err:
					message = '"fail","从URL %s 上获取代理%s配置文件出错,错误信息:%s"' % (config_url,agent,err)
					print "\033[1;31m%s\033[0m" % message
					syslog.syslog(syslog.LOG_ERR,message)
					task_queue.task_done()
					continue

				#创建代理一个容器
				agent_dict = {agent:{}}
				try:
					php = logic.find("php")
					mongo_ip = logic.find("./db_master/ip").text
					mongo_port = logic.find("./db_master/port").text
					mongo_db = logic.find("./db_master/db_name").text
					mysql_ip = logic.find("./logserver/database/item").get("host")
					mysql_port = logic.find("./logserver/database/item").get("port")
					mysql_db = logic.find("./logserver/database/item").get("db")
					server_domain = logic.find("./logics/logic").get("domain")
					login_port = logic.find("./login/php").get("port")
					game_login_port = logic.find("./login").get("port")
					server_hostname = topo.find('./group').get('tag')					
					server_ip = topo.find('./group').get('ip')
					mongo_partner = ""
					mysql_partner = ""
					mongo_backup = ""
					mysql_backup = ""
					try:
						if not re.match(r"\d{1,4}\.\d{1,4}\.\d{1,4}\.\d{1,4}",server_ip):
							for rdata in dns.resolver.query(server_ip,"A"):server_ip = rdata.address
					except Exception,err:
						message = '"fail","代理%s所在的物理服域名为%s,解析域名失败,失败信息:%s"' % (agent,server_ip,err)
						print "\033[1;31m%s\033[0m" % message
						syslog.syslog(syslog.LOG_ERR,message)
					if puppet_run:
						try:
							#查询代理的mysql,mongo主机一些puppet属性
							select_mysql_backup = "SELECT hosts.ip,parameters.value FROM parameters,hosts  \
							WHERE hosts.id = parameters.reference_id AND parameters.name = 'mysql_source' AND parameters.value REGEXP '%s'" % mysql_ip
							select_mongo_backup = "SELECT hosts.ip,parameters.value FROM parameters,hosts  \
							WHERE hosts.id = parameters.reference_id AND parameters.name = 'mongo_source' AND parameters.value REGEXP '%s'" % mongo_ip
							mysql_cnx = mysql.connector.connect(host=puppet,port=puppet_port,user=puppet_user,passwd=puppet_passwd,database="puppet")
							cursor = mysql_cnx.cursor()
							cursor.execute(select_mysql_backup)
							mysql_backup_property = cursor.fetchall()
							cursor.execute(select_mongo_backup)
							mongo_backup_property = cursor.fetchall()
							mongo_backup = mongo_backup_property[0][0]
							mysql_backup = mysql_backup_property[0][0]
							for source in mongo_backup_property[0][1].split(";"):
								if mongo_ip+" "+mongo_port in source:
									mongo_backup_port = source.split()[0]
									break
							for source in mysql_backup_property[0][1].split(";"):
								if mysql_ip+" "+mysql_port in source:
									mysql_backup_port = source.split()[0]
									break
						except Exception,err:
							message = '"fail","代理%s　获取备份数据库slave ip失败,信息:%s"' % (agent,err)
							print "\033[1;31m%s\033[0m" % message
							syslog.syslog(syslog.LOG_ERR,message)
						finally:
							if mysql_cnx.is_connected():mysql_cnx.close()
					agent_dict[agent].update(eval(php.text))
					agent_dict[agent].update({"mongo_ip":mongo_ip})
					agent_dict[agent].update({"mongo_backup":mongo_backup})
					agent_dict[agent].update({"mongo_port":mongo_port})
					agent_dict[agent].update({"mongo_db":mongo_db})
					agent_dict[agent].update({"mysql_ip":mysql_ip})
					agent_dict[agent].update({"mysql_backup":mysql_backup})
					agent_dict[agent].update({"mysql_port":mysql_port})
					agent_dict[agent].update({"mysql_db":mysql_db})
					agent_dict[agent].update({"server_hostname":server_hostname})
					agent_dict[agent].update({"server_ip":server_ip})
					agent_dict[agent].update({"server_domain":server_domain})
					agent_dict[agent].update({"login_port":login_port})
					agent_dict[agent].update({"game_login_port":game_login_port})
					#把代理容器添加到全局容器
					property.update(agent_dict)
				except Exception,err:
					message = '"fail","代理%s获取属性失败,信息:%s"' % (agent,err)
					print "\033[1;31m%s\033[0m" % message
					syslog.syslog(syslog.LOG_ERR,message)
					task_queue.task_done()
					continue
				task_queue.task_done()
		#调用多线各队列函数
		ThreadQueue(GameProperty,parallel,task_queue,property)
		return property
							
	def machine_puppet_property(self,hosts,center,puppet,domain_suffix,parallel=20):
		'''由代理或者主机域名或者主机ip反主机的puppet属性

		如主机应用的puppet类,主机的puppet参数,主机上安装的数据库实例,主机的角色....
		host为一个列表,元素可以为agent_sid,ip,域名,puppet参数为puppet的主机ip或者域名,domain_suffix为puppet管理的域名后缀'''
		if type(hosts) != types.ListType:
			raise Exception("host must list")
		#生成任务队列
		task_queue = Queue.Queue()
		for host in hosts:
			task_queue.put(host)
		#创建字典容器
		puppet_property = dict()
		#定义一个内部函数,从队列当中获取任务
		def property(task_queue,puppet_property):
			while True:
				host = task_queue.get()
				try:
					if re.match(r"\w+_[s|x|t]\d+$",host):
						#获取代理所在物理服的puppet域名
						agent_prefix,sid = host.rsplit("_",1)
						#建立与中央服的连接,查询代理服所在物理服的计算机名
						SSH = ssh(center,timeout=10)
						stdout,stderr,returncode = SSH.run("cat /data/agent/%s/%s/topo.xml" % (agent_prefix,id),drop_socket=False)
						if returncode !=0:
							raise Exception(stderr)
						topo_string = stdout
						topo = ET.fromstring(topo_string)
						server_hostname = topo.find('./group').get('tag')
						server_domain = server_hostname.lower()+"."+domain_suffix.lower()
					elif re.match(r"\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}",host):
						nt = network(host)
						if not nt.check_ip():
							raise Exception("ip 地址:%s错误" % host)
						#与host连接并查询其计算机名
						ssh_host = ssh(host)
						stdout,stderr,returncode = ssh_host.run("hostname",drop_socket=False)
						if returncode != 0:
							raise Exception(stderr)
						server_hostname = stdout.strip()
						server_domain = server_hostname.lower()
						if not re.match(r".+\.%s" % domain_suffix,server_domain):server_domain = server_domain+"."+domain_suffix.lower()
					elif re.match(r".+\.%s" % domain_suffix,host):
						server_domain = host.lower()
					else:
						raise Exception("%s 不在puppet的管理域%s" % (host,domain_suffix))
						
					#定义查询语句
					cmd = "/etc/puppet/node.rb %s" % server_domain
					#创建与puppet的ssh 连接
					SSH = ssh(puppet,timeout=10)
					stdout,stderr,returncode = SSH.run(cmd,drop_socket=False)
					if returncode != 0:
						raise Exception(stderr)
					#对返回的数据进行格式化成字典以便查询
					temp_list = stdout.split("\n")
					#定义可转化成字典的列表函数
					def mktuple(string):
						if re.match(r".+:.*",string):
							key,value = string.split(":",1)
							return (key.strip(),value.strip(' "'))
						else:
							return (None,None)
					machine_puppet_property = dict(map(mktuple,temp_list))
					#添加到全局容器当中
					puppet_property.update({host:machine_puppet_property})
				except Exception,err:
					message = '"fail","获取主机%s的puppet属性发生错误,错误信息:%s"' % (host,err)
					print "\033[1;31m%s\033[0m" % message
					task_queue.task_done()
					syslog.syslog(syslog.LOG_ERR,message)
					continue
				task_queue.task_done()
		#调用线程队列函数
		ThreadQueue(property,parallel,task_queue,puppet_property)
		return puppet_property		

	def web_query(self,puppet_host,port,username,password):
		'''返回全部代理的web ip 地址
		
		   puppet_host:puppet主机,port:puppet mysql端口,userame:puppet mysql用户名,password:puppet mysql密码,detail是否输出更详细输出(联通地址)'''
		output = {}
		puppet_classes = "nginx"
		#调用puppet模块获取相应组的IP地址
		p = puppet(puppet_host=puppet_host,port=port,username=username,password=password)
		nginx_hosts = p.host_by_classes(puppet_classes)
		names = nginx_hosts.keys()
		facts = p.get_puppet_facts(hostname=names)
		for fact in facts:
			agents = {}
			domains = facts[fact].get("nginx_server_names")
			if domains:agents = eval("{%s}" % domains)	
			ip = facts[fact]["ipaddress"]
			for agent in agents:
				if not agent in output:
					output[agent]=ip
				else:
					message='"fail","代理%s的web分别存在于%s与%s当中,请删除不正确的配置,排除这个代理"' % (agent,output[agent],ip)
					print "\033[1;31m%s\033[0m" % message
					syslog.syslog(syslog.LOG_ERR,message)
					del output[agent]
		return output

	def domain_query(self,agents,puppet_host,port,username,password):
		'''返回代理服的游戏域名,agents为一个列表'''
		#调用puppet模块获取相应组的IP地址
		all_domains = {}
		output = {}
		puppet_classes = "nginx"
		p = puppet(puppet_host=puppet_host,port=port,username=username,password=password)
		nginx_hosts = p.host_by_classes(puppet_classes)
		names = nginx_hosts.keys()
		facts = p.get_puppet_facts(hostname=names)
		for fact in facts:
			domains = facts[fact].get("nginx_server_names")
			if not domains:continue
			domains = eval("{%s}" % domains)
			for agent in domains:
				domain = " ".join(domains[agent])
				all_domains[agent]=domain

		for agent in agents:
			if agent in all_domains:
				output[agent] = all_domains[agent]
			else:
				message = '"fail","查找代理%s的域名失败"' % agent
				print "\033[1;31m%s\033[0m" % message
				syslog.syslog(syslog.LOG_ERR,message)
		return output
		
	def update_mysql(self,agents,config_url,cert_file,key_file,ca_file,sql,mysql_user=None,mysql_passwd=None,parallel=20):
		'''mysql更新函数,按照agents列表更新对应的mysql数据库,可以指定sqlfile(文件),sql(sql语句)'''
		agents_property = self.game_property(agents,config_url,cert_file,key_file,ca_file,parallel=parallel)
		if not mysql_user:mysql_user = "game"
		if not mysql_passwd:mysql_passwd = "Exia@LeYou"
		#if os.path.isfile(sql):
		#	f = open(sql,"r")
		#	run_sql = re.sub(r"/\*.+\*/;?","",f.read())
		#	f.close()
		#elif sql:
		#	run_sql = sql
		#else:
		#	raise Exception("neither sqlfile or sql specify")
		#def update(task_queue,sql,mysql_user,mysql_passwd):
		#	while True:
		#		try:
		#			agt = task_queue.get()
		#			for agent in agt:
		#				mysql_ip = agt[agent]["mysql_ip"]
		#				mysql_port = int(agt[agent]["mysql_port"])
		#			cnx = mysql.connector.connect(host=mysql_ip,port=mysql_port,user=mysql_user,password=mysql_passwd,database=agent)
		#			cursor = cnx.cursor()
		#			for result in cursor.execute(sql,multi=True):
		#				pass
		#			cnx.close()
		#			message = '"success","更新代理%s mysql: %s:%s 成功"' % (agent,mysql_ip,mysql_port)
		#			print "\033[1;32m%s\033[0m" % message
		#			syslog.syslog(message)
		#		except Exception,err:
		#			message = '"fail","更新代理%s mysql: %s:%s 出错,信息:%s"' % (agent,mysql_ip,mysql_port,err)
		#			print "\033[1;31m%s\033[0m" % message
		#			syslog.syslog(syslog.LOG_ERR,message)
		#		finally:
		#			task_queue.task_done()
		def update(task_queue,sql,mysql_user,mysql_passwd):
			while True:
				try:
					agt = task_queue.get()
					for agent in agt:
						mysql_ip = agt[agent]["mysql_ip"]
						mysql_port = int(agt[agent]["mysql_port"])
					if os.path.isfile(sql):
						cmd = """mysql -h %s -P %d -u%s -p%s -D %s < %s""" % (mysql_ip,mysql_port,mysql_user,mysql_passwd,agent,sql)
					else:
						cmd = """mysql -h %s -P %d -u%s -p%s -D %s -e '%s'""" % (mysql_ip,mysql_port,mysql_user,mysql_passwd,agent,sql)
					query = subprocess.Popen(cmd,stdout=subprocess.PIPE,stderr=subprocess.PIPE,shell=True)
					stdout,stderr = query.communicate()
					if query.returncode != 0:
						raise Exception(stderr)
					message = '"success","更新代理%s mysql: %s:%s 成功"' % (agent,mysql_ip,mysql_port)
					print "\033[1;32m%s\033[0m" % message
					syslog.syslog(message)
				except Exception,err:
					message = '"fail","更新代理%s mysql: %s:%s 出错,信息:%s"' % (agent,mysql_ip,mysql_port,err)
					print "\033[1;31m%s\033[0m" % message
					syslog.syslog(syslog.LOG_ERR,message)
				finally:
					task_queue.task_done()
		task_queue = Queue.Queue()
		for agent in agents_property:
			task_queue.put({agent:agents_property[agent]})
		ThreadQueue(update,parallel,task_queue,sql,mysql_user,mysql_passwd)

		
	def query_thread(self,parallel,task_queue,monitor=False):
		ThreadQueue(self.query,parallel,task_queue,monitor)

	def stop_thread(self,parallel,task_queue,monitor=False):
		def stop(task_queue,monitor):
			while True:
				agent = task_queue.get()
				try:
					self.stop(agent,monitor)
                                	task_queue.task_done()
				except Exception,err:
					message = '"fail","关闭代理%s出错,出错信息:%s"' % (agent,err)
					self.log.savelog(err,color="Error")
                                        syslog.syslog(syslog.LOG_ERR,message)
                                        if self.errlog:
                                                self.errlog.savelog(message)
                                        #记录到错误收集队列
                                        task_queue.task_done()
                                        self.error_queue.put(message)
					continue
		ThreadQueue(stop,parallel,task_queue,monitor)

	def start_thread(self,parallel,task_queue,monitor=False):
		def start(task_queue,monitor):
			while True:
				agent = task_queue.get()
				try:
					self.start(agent,monitor)
                                	task_queue.task_done()
				except Exception,err:
					message = '"fail","开启代理%s出错,出错信息:%s"' % (agent,err)
					self.log.savelog(err,color="Error")
                                        syslog.syslog(syslog.LOG_ERR,message)
                                        if self.errlog:
                                                self.errlog.savelog(message)
                                        #记录到错误收集队列
					task_queue.task_done()
                                        self.error_queue.put(message)
					continue
		ThreadQueue(start,parallel,task_queue,monitor)

	def restart_thread(self,parallel,task_queue,ServerVersion=None,ClientVersion=None,monitor=False):
		def restart(task_queue,ServerVersion,ClientVersion,monitor):
			while True:
				agent = task_queue.get()
				try:
					self.restart(agent,ServerVersion,ClientVersion,monitor)
                                	task_queue.task_done()
				except Exception,err:
                                        message = '"fail","重启代理%s出错,出错信息:%s"' % (agent,err)
                                        self.log.savelog(err,color="Error")
                                        syslog.syslog(syslog.LOG_ERR,message)
                                        if self.errlog:
                                                self.errlog.savelog(message)
                                        #记录到错误收集队列
                                        task_queue.task_done()
                                        self.error_queue.put(message)
					continue
		ThreadQueue(restart,parallel,task_queue,ServerVersion,ClientVersion,monitor)

	def update_thread(self,parallel,task_queue,ServerVersion,ClientVersion,monitor=False):
		def update(task_queue,ServerVersion,ClientVersion,monitor):
			while True:
				agent = task_queue.get()
				try:
					self.update(agent,ServerVersion,ClientVersion,monitor)
                        	        task_queue.task_done()
				except Exception,err:
					message = '"fail","更新代理%s出错,出错信息:%s"' % (agent,err)
                        	        self.log.savelog(err,color="Error")
                        	        syslog.syslog(syslog.LOG_ERR,message)
                        	        if self.errlog:
                        	                self.errlog.savelog(message)
                        	        #记录到错误收集队列
                        	        task_queue.task_done()
                        	        self.error_queue.put(message)
					continue
		ThreadQueue(update,parallel,task_queue,ServerVersion,ClientVersion,monitor)

	def sendclient_thread(self,parallel,task_queue):
		ThreadQueue(self.sendclient,parallel,task_queue)
	def sendserver_thread(self,parallel,task_queue):
		ThreadQueue(self.sendserver,parallel,task_queue)
	def sendback_thread(self,parallel,task_queue,exclude_from):
		ThreadQueue(self.sendback,parallel,task_queue,exclude_from)


	def phpfunction(self,taskid,cdn,parallel=None):
		'''后台操作函数,专门用到与后台通信和读取任务信息

		线程数与任务数相同,任务数超过一千线程数就为一千.'''
		operate = phpoperate()
		mission = operate.query(taskid)
		def settaskresult(result):
			setresult = operate.settaskresult(taskid,result)
			if setresult["res"] != 1:
				message = '"finish","设置后台计划任务%d标记为%s时失败,失败的信息为:%s"' % (taskid,result,setresult["msg"])
				self.log.savelog(message,color="Error")
				syslog.syslog(syslog.LOG_ERR,message)
				if self.errlog:
					self.errlog.savelog(message)
			else:
				message = '"finish","设置后台计划任务%d标记为%s时成功"' % (taskid,result)
				self.log.savelog(message,color="Success")
				syslog.syslog(message)
		try:
			if mission["res"] != 1:
				message = '"fail","获取后台计划任务%d失败,失败的信息为:%s"' % (taskid,mission["msg"])
				self.log.savelog(message,color="Error")
				syslog.syslog(syslog.LOG_ERR,message)
				if self.errlog:
					self.errlog.savelog(message)
				settaskresult("FAIL")
				exit(1)
			if mission["status"] != "PENDING":
				message = '"fail","后台计划任务%d,并不是计划中,如要操行请新建任务"' % taskid
				self.log.savelog(message,color="Error")
				syslog.syslog(syslog.LOG_ERR,message)
				if self.errlog:
		                        self.errlog.savelog(message)
				settaskresult("FAIL")
				exit(1)
			settaskstatus = operate.settaskstatus(taskid,"PROCESS")
			if settaskstatus["res"] != 1:
				message = '"fail","设置后台计划任务%d状态失败,失败的信息为:%s"' % (taskid,settaskstatus["msg"])
				self.log.savelog(message,color="Error")
				syslog.syslog(syslog.LOG_ERR,message)
				if self.errlog:
		                        self.errlog.savelog(message)
				settaskresult("FAIL")
				exit(1)
			#初始化任务队列
			tasklist = Queue.Queue(0)
			if re.match(r"(start|stop|restart|update)",mission["type"]): 
				for agent in mission["target"]:
					for id in mission["target"][agent]:
						tasklist.put(agent+"_"+id)
			elif re.match(r"rsync",mission["type"]):
				if mission["content"]["version_type"] == "1":
					SyncType = "client"
				elif mission["content"]["version_type"] == "2":
					SyncType = "server"
				version = mission["content"]["version"]
				hostlist = mission["target"].values()
				tasklist = self.generate_sync_queue(SyncType,version,hostlist)
		except KeyError,err:
			message = '"fail","后台任务%d传递任务信息出错,信息:%s"' % (taskid,err)
			self.log.savelog(message,color="Error")
                        syslog.syslog(syslog.LOG_ERR,message)
                        if self.errlog:
                        	self.errlog.savelog(message)
			settaskresult("FAIL")
			exit(1)
		#初始化线程数
		if not parallel:
			if tasklist.qsize() > 100:
				parallel = 100
			else:
				parallel = tasklist.qsize()
				 
			
		if mission["type"] == "start" or mission["type"] == "install":
			ThreadQueue(self.start,parallel,tasklist)
		if mission["type"] == "stop":		
			ThreadQueue(self.stop,parallel,tasklist)
		if mission["type"] == "restart":
			ThreadQueue(self.restart,parallel,tasklist)
		if mission["type"] == "update":
			#version_type = {"1":"client","2":"server"}
			client=None
			server=None
			for version in mission["content"]:
				if version["version_type"] == 1:
					client=version["version"]
				elif version["version_type"] == 2:
					server=version["version"]
			if client:
				try:
					code = urllib.urlopen("http://%s/%s/config.o" % (cdn,client)).getcode()
                			if code != 200:
                        			message = '"fail","cdn 上面没有客户端%s版本,请更新cdn"' % client
                        			self.log.savelog(message,color="Error")
                        			if self.errlog:self.errlog.savelog(message)
                        			syslog.syslog(syslog.LOG_ERR,message)
						settaskresult("FAIL")
                        			exit(1)
				except Exception,err:
					message = '"fail","检查http://%s/%s发生错误,请确认域名是否正确,错误信息:%s"' % (cdn,client,err)
                			print "\033[1;31m%s\033[0m" % message
                			syslog.syslog(syslog.LOG_ERR,message)
                			exit(1)
			if server:
				ThreadQueue(self.restart,parallel,tasklist,server,client)
			elif client:
				ThreadQueue(self.reload,parallel,tasklist,client)		
				
		if mission["type"] == "rsync":
			if SyncType == "client":
				ThreadQueue(self.sendclient,parallel,tasklist)
			elif SyncType == "server":
				ThreadQueue(self.sendserver,parallel,tasklist)

		settaskstatus = operate.settaskstatus(taskid,"FINISH")
	        if settaskstatus["res"] != 1:
	                message = '"fail","设置后台计划任务%d状态失败,失败的信息为:%s"' % (taskid,settaskstatus["msg"])
	                self.log.savelog(message,color="Error")
			syslog.syslog(message)
			if self.errlog:
	                        self.errlog.savelog(message)
	                settaskresult("FAIL")
	                exit(1)
		if self.error_queue.qsize() == 0: 
			settaskresult("SUCCESS")
		else:
			settaskresult("FAIL")

