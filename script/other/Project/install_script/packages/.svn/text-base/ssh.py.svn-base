#!/usr/bin/env python
# -*- coding: utf-8 -*-

'''ssh 操作模块

SSH的操作,到远程执行命令,传送文件到远程,从远程下载文件,write by yyr'''
import os
import sys
import subprocess
import syslog
import re
import yunwei.fileoperate as fileoperate
import pdb
import time

class ssh ():
	def __init__(self,host,user="root",identify=None,timeout=None,port=22):
		self.host = host
		self.user = user
		self.identify = identify
		self.port = port
		self.timeout = timeout

	def ssh_socket(self):
                '''创建ssh socket 以及后端开启ssh 连接,实现ssh 连接重用'''

                #判断ssh socket是否存在
		cmd = "ssh -p %d -o StrictHostKeyChecking=no -o ControlPath=~/.ssh/ssh_%%h_%%p.sock -O check %s" % \
		(self.port,self.host)
		#cmd_create = "strace -e trace=!signal -o /tmp/%s.log ssh -p %d -o StrictHostKeyChecking=no -M -Nf %s" % \
		#(self.host,self.port,self.host)
		cmd_create = ["ssh","-p",str(self.port),"-o","StrictHostKeyChecking=no","-o","ControlMaster=auto",
		"-o","ControlPath=~/.ssh/ssh_%h_%p.sock","-o","ControlPersist=yes",self.host,"exit 0"]
		if self.identify:
			cmd_create.insert(1,"-i")
			cmd_create.insert(2,self.identify)
		if self.timeout:
			cmd_create.insert(1,"-o")
			cmd_create.insert(2,"ConnectTimeout=%s" % self.timeout)
                run = subprocess.Popen(cmd,stdout=subprocess.PIPE,stderr=subprocess.PIPE,shell=True)
                stdout,stderr = run.communicate()
                if run.returncode != 0:
                        if "Connection refused" in stderr:
				message = '%s ssh_socket已经失效,重建ssh shocket' % self.host
				print message
				syslog.syslog(syslog.LOG_WARNING,message)
                                os.popen('find ~/.ssh -name "*%s*.sock" -exec rm -f {} \;' % self.host)
				os.popen('pid=`pgrep -f "ssh .+ %s"`;[ -n "$pid" ] && kill $pid' % (self.host))
			try:
                        	result = subprocess.check_call(cmd_create)
			except Exception,err:
				message = '"warning","%s创建ssh socket失败,直接用直连,错误信息:%s"' % (self.host,err)
				print message
				syslog.syslog(syslog.LOG_WARNING,message)
			
			#time.sleep(2)

	def run(self,cmd,forwarding=False,drop_socket=True):
		'''通过SSH远程执行命令,并返回标准输出,标准错误,返回执行码,drop_socket默认为True表示完成命令后删除SSH SOCKET'''
		#创建socket
		self.ssh_socket()
		forward = ""		
		timeout = ""
		if forwarding == True:
			forward = "-A"
		if self.timeout:
			timeout = "-o ConnectTimeout=%s" % self.timeout
		cmd = r"""ssh %s -l %s %s -o StrictHostKeyChecking=no %s %s""" % (forward,self.user,timeout,self.host,cmd)
		try:
			run = subprocess.Popen(cmd,stdout=subprocess.PIPE,stderr=subprocess.PIPE,shell=True)
			stdout,stderr = run.communicate()
		except Exception,err:
			raise Exception(err)
		if drop_socket:
			subprocess.call(["ssh","-p",str(self.port),"-O","exit",self.host])
		return stdout,stderr,run.returncode

	def sendfile(self,source,dest,exclude=None,exclude_from=None,include=None,include_from=None,delete=False,bwlimit=0,ModifyTime=None,prune_empty_dirs=None,drop_socket=True):
		'''通过SSH连接调用rsync传送文件和文件夹

		exclude:排除文件,exclude_from:从文件中获取排除的文件,delete:是否使用rsync的delete参数 ,bwlimit:指定传输带宽(单位KB,0表示不限制),
		ModifyTime:忽略时间单位秒,drop_socket:是否清除SSH SOCKET'''
		host = self.host
		port = self.port
                #创建ssh socket
                self.ssh_socket()
                #判断传送源是否存在
                if not os.path.exists(source):
                        message='"fail","directory %s is not exist"' % source
			print message
                        syslog.syslog(syslog.LOG_ERR,message)
                        raise Exception(message)
                #如果目标服上面没有传送的父目录则创建
                dir_dest = os.path.dirname(dest.rstrip("/"))
                basename_dest = os.path.basename(dest.rstrip("/"))
                dir = os.path.dirname(source.rstrip("/"))
                basename = os.path.basename(source.rstrip("/"))
		exclude_opt = ""
		exclude_from_opt = ""
		include_opt = ""
		include_from_opt = ""
		delete_rsync = ""
		modify_window = ""
		prune_empty_dirs_opt = ""
		timeout = ""
		if exclude:exclude_opt = "--exclude %s" % exclude
		if exclude_from:exclude_from_opt = "--exclude-from %s" % exclude_from
		if include:include_opt = "--include %s" % include
		if include_from:include_from_opt = "--include-from %s" % include_from
		if delete:delete_rsync = "--delete"
		if ModifyTime:modify_window = "--modify-window=%d" % ModifyTime
		if prune_empty_dirs:prune_empty_dirs_opt = "--prune-empty-dirs"
		if self.timeout:timeout = "-o ConnectTimeout=%s" % self.timeout
                parameter = {"source":source,"dest":dest,"host":host,"port":port,"dir_dest":dir_dest,\
		"basename_dest":basename_dest,"dir":dir,"basename":basename,"bwlimit":bwlimit,"modify_window":modify_window,"timeout":timeout}

		try:
                	p = subprocess.Popen("ssh %(timeout)s -p %(port)d -o StrictHostKeyChecking=no %(host)s '[ ! -d %(dir_dest)s ] && mkdir -p %(dir_dest)s'" % \
			parameter,stdout=subprocess.PIPE,shell=True)
                	p.communicate()
                	if os.path.isfile(source):
                        	send = subprocess.Popen("rsync -avzc --bwlimit %(bwlimit)s %(modify_window)s -e \
				'ssh -p %(port)d -o StrictHostKeyChecking=no %(timeout)s' %(source)s %(host)s:%(dest)s" % \
				parameter,bufsize=-1,stdout=subprocess.PIPE,stderr=subprocess.PIPE,shell=True )
                	else:
                        	send = subprocess.Popen("rsync -avzc %s %s %s %s %s %s --bwlimit %s %s -e 'ssh -p %d -o StrictHostKeyChecking=no %s' %s %s:%s" \
                        	% (prune_empty_dirs_opt,include_opt,include_from_opt,exclude_opt,exclude_from_opt,delete_rsync,bwlimit,modify_window,\
				port,timeout,source,host,dest),bufsize=-1,stdout=subprocess.PIPE,stderr=subprocess.PIPE,shell=True )
                        stdout,stderr = send.communicate()
			if send.returncode !=0:
				raise Exception(stderr)
		except Exception,err:
			message = '"fail","传送%s失败,失败信息%s"' % (source,err)
			print message
			syslog.syslog(syslog.LOG_ERR,message)
			raise Exception(message)
		finally:
			if drop_socket:
				try:
					delete_socket = subprocess.check_call(["ssh","-p",str(port),"-O","exit",self.host])
				except subprocess.CalledProcessError:
					message ='"warning","%s 没有后台ssh连接,不用退出"' % host
					print message
					syslog.syslog(syslog.LOG_WARNING,message)
		#获取传送速率
		bytes = re.search(r"(\d+\.?\d+) bytes/sec",stdout).group(1)
		KB = float(bytes)/1024
		return stdout,stderr,KB,send.returncode

	def getfile(self,source,dest,exclude=None,exclude_from=None,include=None,include_from=None,delete=False,bwlimit=0,ModifyTime=None,prune_empty_dirs=None,drop_socket=True):
		'''通过SSH连接调用rsync从远程机器下载文件或者文件夹
		
		delete:是否使用rsync的delete参数 ,bwlimit:指定传输带宽(单位KB,0表示不限制),drop_socket:是否清除SSH SOCKET'''
		host = self.host
		port = self.port
		#创建ssh socket
                self.ssh_socket()
		#创建本地目录
		dir_dest = os.path.dirname(dest.rstrip("/"))
                basename_dest = os.path.basename(dest.rstrip("/"))
                dir = os.path.dirname(source.rstrip("/"))
                basename = os.path.basename(source.rstrip("/"))
		fileoperate.mkdir(dir_dest)
		delete = ""
		exclude_opt = ""
                exclude_from_opt = ""
                include_opt = ""
                include_from_opt = ""
		prune_empty_dirs_opt = ""
		modify_window=""
		timeout = ""
		if delete:delete = "--delete"
		if exclude:exclude_opt = "--exclude %s" % exclude
                if exclude_from:exclude_from_opt = "--exclude-from %s" % exclude_from
                if include:include_opt = "--include %s" % include
                if include_from:include_from_opt = "--include-from %s" % include_from
		if prune_empty_dirs:prune_empty_dirs_opt = "--prune-empty-dirs"
		if ModifyTime:modify_window="--modify-window=%d" % ModifyTime
		if self.timeout:timeout = "-o ConnectTimeout=%s" % self.timeout
		try:
			get = subprocess.Popen("rsync -avzc %s %s %s %s %s %s --bwlimit %d %s -e 'ssh -p %d -o StrictHostKeyChecking=no %s' %s:%s %s" %\
                	(prune_empty_dirs_opt,include_opt,include_from_opt,exclude_opt,exclude_from_opt,delete,bwlimit,modify_window,port,timeout,host,source,dest),bufsize=-1,\
			stdout=subprocess.PIPE,stderr=subprocess.PIPE,shell=True)
			stdout,stderr = get.communicate()
			if get.returncode != 0:
				raise Exception(stderr)
		except Exception,err:
			message = '"fail","下载%s失败,失败信息%s"' % (source,err)
			print message
			syslog.syslog(syslog.LOG_ERR,message)
			raise Exception(message)
		finally:
			if drop_socket:
				try:
        				delete_socket = subprocess.check_call(["ssh","-p",str(port),"-O","exit",self.host])
				except subprocess.CalledProcessError:
        				message ='"warning","%s 没有后台ssh连接,不用退出"' % host
        				print message
        				syslog.syslog(syslog.LOG_WARNING,message)
		#获取传送速率
                bytes = re.search(r"(\d+\.?\d+) bytes/sec",stdout).group(1)
                KB = float(bytes)/1024
		return stdout,stderr,KB,get.returncode
		
			
			
