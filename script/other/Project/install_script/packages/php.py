#!/usr/bin/env python
#-*- coding: utf-8 -*-
import os
import pdb
import subprocess
import logging
import re
import sys
import xml.etree.ElementTree
import syslog
import Queue
import types
from yunwei.parallel import ThreadQueue


class phplog():
     	def __init__(self,logfile=None,verbose=True):
		self.logfile = logfile
		self.verbose = verbose
        def savelog(self,message,color=None):
		'''color,颜色选项,当指定了verbose=True时,会把相应的日志颜色打印到终端

		有三种颜色,None,Success,Error,Warning. None为默认颜色,Success为绿色,Error为红色,Warning为黄色'''

                format = '"%s",%s' % ("%(asctime)s","%(message)s")
		
		if self.logfile:
			path,file = os.path.split(self.logfile)
                        if not file:
                                print "指定log日志文件路径不正确"
                                exit(1)
                        if re.match(r"^/.*",path):
                                if not os.path.exists(path):
                                        os.makedirs(path)
                        else:
                                if  not os.path.exists(sys.path[0]+"/"+path):
                                        os.makedirs(sys.path[0]+"/"+path)
                                self.logfile = sys.path[0]+"/"+self.logfile
			loggerfile = logging.getLogger(self.logfile)
			handlerfile = logging.FileHandler(self.logfile,"a")
			formatter = logging.Formatter(format,datefmt="%Y-%m-%d %H:%M:%S")
			handlerfile.setFormatter(formatter)
			if len(loggerfile.handlers) == 0:
				loggerfile.addHandler(handlerfile)
			loggerfile.setLevel(logging.INFO)
			loggerfile.info(message)
			#loggerfile.removeHandler(handlerfile)
		if self.verbose:
			loggerstream = logging.getLogger("stream")
                	console = logging.StreamHandler()
                	loggerstream.setLevel(logging.INFO)
                	formatter = logging.Formatter(format,datefmt="%Y-%m-%d %H:%M:%S")
                	console.setFormatter(formatter)
			if len(loggerstream.handlers) == 0:
                		loggerstream.addHandler(console)
			if color == "Error":
				message = "\033[1;31m%s\033[0m" % message
			elif color == "Warning":
				message = "\033[1;33m%s\033[0m" % message
			elif color == "Success":
				message = "\033[1;32m%s\033[0m" % message
                	loggerstream.info(message)
			#loggerstream.removeHandler(console)
	def background_upload_log(self,sys_argv,operator,updategame=False,agents=None,server_version=None,client_version=None,php_version=None):
		'''脚本命令行操作日志上传到后台'''
		basename = os.path.basename(sys_argv[0])
		argv = " ".join(sys_argv[1:])
		action = "log"
		cmd = '''/usr/local/php/bin/php /data/www/centeradmin/shell/yunwei.php "action=%s&script=%s&operator=%s&argv='%s'"''' % (action,basename,operator,argv)
		if agents:
			agents = "&target="+agents
		else:
			agents = ""
		if server_version:
			server_version = "&server_version=%s" % server_version
		else:
			server_version = ""
		if client_version:
			client_version = "&client_version=%s" % client_version
		else:
			client_version = ""
		if php_version:
			php_version = "&php_version=%s" % php_version
		else:
			php_version = ""
		if updategame:
			cmd = '/usr/local/php/bin/php /data/www/centeradmin/shell/yunwei.php "action=updategame&script=%s&operator=%s%s%s%s%s"' % \
			(basename,operator,agents,server_version,client_version,php_version)
		run = subprocess.Popen(cmd,stdout=subprocess.PIPE,stderr=subprocess.PIPE,shell=True)
		stdout,stderr = run.communicate()
		if not "success" in stdout or run.returncode != 0:
			raise Exception("run %s failed\ninfo:\t%s\n%s" % (cmd,stdout,stderr))

class phpoperate ():
	
	def __init__(self):
		self.operate = {1:"install",2:"start",3:"stop",4:"restart",5:"update",6:"quickupdate",7:"move",8:"backup",9:"rollback",10:"close",11:"rsync"}
		self.taskstatus = ["PENDING","PROCESS","CHECK","FINISH","ERROR","CANCEL" ]
		self.taskresult = {"FAIL":0,"SUCCESS":1}
		syslog.openlog(os.path.basename(sys.argv[0]))

	def phpparser(self,data):
		config = dict()
		root = xml.etree.ElementTree.fromstring(data)
		element = root.getiterator()
		for e in element:
			if e.tag == "target" or e.tag == "content":
				config[e.tag]=eval(e.text)
			elif e.tag == "type":
				config[e.tag]=self.operate[int(e.text)]
			elif e.tag == "status":
				config[e.tag]=self.taskstatus[int(e.text)]
			else:
				regex = u"^\d+$"
				if re.match(regex,str(e.text)):
					config[e.tag]=int(e.text)
				else:
					config[e.tag]=e.text
		return config

	def query (self,sid):
		php_cmd = "/usr/local/php/bin/php /data/www/centeradmin/shell/schedule.php -action=query -sid=%d" % sid
		run = subprocess.Popen(php_cmd,stdout=subprocess.PIPE,stderr=subprocess.PIPE,shell=True)
		stdout,stderr = run.communicate()
		if run.returncode != 0:
			message = '"fail","查询后台任务%d出错,出错信息:%s"' % (sid,stderr)
			print message
			syslog.syslog(syslog.LOG_ERR,message)
			exit(1)
		data = stdout
		return self.phpparser(data)

	def settaskstatus(self,sid,status):
		if not status in self.taskstatus:
			print "parameter status must PENDING,PROCESS,CHECK,FINISH,ERROR,CANCEL"
			exit(1)
		php_cmd = "/usr/local/php/bin/php /data/www/centeradmin/shell/schedule.php -action=set -sid=%d -status=%d" % (sid,self.taskstatus.index(status))
                data = os.popen(php_cmd).read() 
                return self.phpparser(data)

	def settaskresult(self,sid,flag):
		if not flag in self.taskresult:
			print "parameter flag must be SUCCESS or FAIL"
			exit(1)
		php_cmd = "/usr/local/php/bin/php /data/www/centeradmin/shell/schedule.php -action=set -sid=%d -flag=%d" % (sid,self.taskresult[flag])
		data = os.popen(php_cmd).read()
		return self.phpparser(data)

	def php_import(self,agents,server_version,parallel=20):
		'''php每次更新完服务端都要执行的导入操作'''
		queue = Queue.Queue()
		for agent in agents:
			queue.put(agent)
		def phpimport(queue,server_version):
			try:
				agent = queue.get()
				cmd = '/usr/local/php/bin/php /data/www/centeradmin/shell/yunwei.php "action=import&target=%s&type=server&version=%s"' % (agent,server_version)
				run = subprocess.Popen(cmd,stdout=subprocess.PIPE,stderr=subprocess.PIPE,shell=True)
				stdout,stderr = run.communicate()
				if not re.search(r"success",stdout,re.I) or run.returncode != 0:
					raise Exception("%s\n%s\n%s" % (cmd,stdout,stderr))
				message = '"success","%s php update import success"'% agent
				print "\033[1;32m%s\033[0m" % message
				syslog.syslog(message)
			except Exception,err:
				message = '"fail","%s php update import fail:%s"' % (agent,err)
				print "\033[1;31m%s\033[0m" % message
				syslog.syslog(syslog.LOG_ERR,message)
			finally:
				queue.task_done()
		
		ThreadQueue(phpimport,parallel,queue,server_version)

	def update_bg_version(self,agent,server_version=None,client_version=None,bg_version=None):
		if not type(agent) is types.ListType:
			raise Exception("agent must to be a list")
		php_server_version = ""
		php_client_version = ""
		php_bg_version = ""
		run = False
		if server_version:
			php_server_version = "&server_version=%s" % server_version
			run = True
		if client_version:
			php_client_version = "&client_version=%s" % client_version
			run = True
		if bg_version:
			php_bg_version = "&php_version=%s" % bg_version
			run = True
		agent_string = ",".join(agent)
		php_cmd = '/usr/local/php/bin/php /data/www/centeradmin/shell/yunwei.php "action=updategame&target=%s%s%s%s"' % (agent_string,php_server_version,php_client_version,php_bg_version)
		if run:
			try:
				running = subprocess.Popen(php_cmd,stdout=subprocess.PIPE,stderr=subprocess.PIPE,shell=True)
				stdout,stderr = running.communicate()
				if not re.search(r"success",stdout,re.I) or running.returncode != 0:
					raise Exception("%s\n%s\n%s" % (php_cmd,stdout,stderr))
				message = '"success","php background version update complete"'
				print "\033[1;32m%s\033[0m" % message
				syslog.syslog(message)
			except Exception,err:
				message = '"fail","php background version update failed:%s"' % err
				print "\033[1;31m%s\033[0m" % message
				syslog.syslog(syslog.LOG_ERR,message)

if __name__ == "__main__":
	operate = phpoperate()
	data = operate.query(10)
	for key in data:
		print "%s: %s" % (key,data[key])
	#log = phplog(verbose=True)
	#log.savelog("success","try 1 times")
