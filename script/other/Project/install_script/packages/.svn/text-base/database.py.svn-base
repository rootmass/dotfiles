#!/usr/bin/env python
# -*- coding: utf-8 -*-
import subprocess
import syslog
import time
import datetime
import os
import sys
import re
import pdb
from yunwei.php import phplog
from yunwei.fileoperate import chown,chmod,mkdir,rm,decompress,tail
import mysql.connector as mysqlconnect
import pymongo

'''数据库备份和还原模块

由yyr编写'''

class mongodb():
	'''mongodb备份和还原类

	主要用于备份和还原mongodb数据库'''
	def __init__(self,host="127.0.0.1",port=27017,username=None,password=None,logfile=None,errlog=None):
		self.host = host
		self.port = port
		self.username = ""
		self.password = ""
		if username:self.username = "--username "+username
		if password:self.password = "--password "+password
		self.log = phplog(logfile)
		self.errlog = phplog(errlog,verbose=False)
		syslog.openlog(os.path.basename(sys.argv[0]))
		#检测是否能连接上mongodb
                mongodburl = "mongodb://%s" % self.host
		if username or password:mongodburl = "mongodb://%s:%s@%s" % (username,password,self.host)
		cnx = pymongo.MongoClient(mongodburl,self.port)
		self.databases = cnx.database_names()
                cnx.close()
		

	def backup(self,database,outdir):
		'''备份mongodb函数，

		当参数database为数据库名时就单独备份一个数据库，当为full时就对整个实例的所有数据库备份'''
		if database == "full":
			cmd = "mongodump --journal --host %s --port %d %s %s -o %s" % (self.host,self.port,self.username,self.password,outdir)
			sizedir = outdir
			#清空目录下的文件，保证备份干净
			rm(outdir+"/*",rf=True)
		else:
			if not database in self.databases:raise ValueError("不存在数据库%s" % database)
			cmd = "mongodump --journal --host %s --port %d %s %s -d %s -o %s" % (self.host,self.port,self.username,self.password,database,outdir)
			sizedir = outdir+"/"+database
			#清空目录下的文件，保证备份干净
			rm(sizedir,rf=True)
		starttime=time.time()
		result = subprocess.Popen(cmd,stdout=subprocess.PIPE,stderr=subprocess.PIPE,shell=True)
		stdout,stderr = result.communicate()
		processTime = time.time() - starttime
		if result.returncode != 0:	
			message = '"fail","%s: 备份mongodb实例%s 数据库%s 失败,失败信息：%s"' % (self.host,self.port,database,stderr.rstrip())
			self.log.savelog(message)
			self.errlog.savelog(message)
			syslog.syslog(syslog.LOG_ERR,message)
			raise IOError(message)
		else:
			sizecmd = subprocess.Popen("du -sh %s |cut -f 1" % sizedir,stdout=subprocess.PIPE,shell=True)
			size = sizecmd.communicate()[0].rstrip()
			message = '"success","%s: 备份mongodb实例%s 数据库%s 完成,路径 %s ,备份大小为%s,历时%.7f s"' % \
			(self.host,self.port,database,outdir,size,processTime)
			self.log.savelog(message)
                        syslog.syslog(message)

	def restore(self,database,indir):
		'''还原mongodb函数，

		当参数database为数据库名时就单独还原一个数据库当中，当为full时就对indir目录下的所有目录还原到实例当中'''
		if os.path.isfile(indir):
			basename = decompress(indir,check=True)
			rm("/data/mongo_restore_tmp/%s" % basename,rf=True)
			decompress(indir,"/data/mongo_restore_tmp")
			indir = "/data/mongo_restore_tmp/%s" % basename
		else:
			basename = os.path.basename(indir)
		if not database:database = basename
	  	cmd = "mongorestore --host %s --port %d --drop %s %s -d %s %s" % (self.host,self.port,self.username,self.password,database,indir)
		starttime=time.time()
		result = subprocess.Popen(cmd,stdout=subprocess.PIPE,stderr=subprocess.PIPE,shell=True)
                stdout,stderr = result.communicate()
		processTime = time.time() - starttime
		if result.returncode != 0:
                        message = '"fail","%s: 还原mongodb实例%s 数据库%s 失败，失败信息：%s"' % (self.host,self.port,database,stderr.rstrip())
                        self.log.savelog(message)
                        self.errlog.savelog(message)
                        syslog.syslog(syslog.LOG_ERR,message)
			raise IOError(message)
                else:
                        message = '"success","%s: 还原mongodb实例%s 数据库%s 完成,历时%.7f s"' % (self.host,self.port,database,processTime)
                        self.log.savelog(message)
                        syslog.syslog(message)

class mysql ():
	'''mysql 备份和还原类

	用于进行mysql的备份和还原'''
	def __init__ (self,host,port,username,password,logfile=None,errlog=None):
		self.host = host
		self.port = port
		self.username = username
		self.password = password
		self.shell_username = ""
		self.shell_password = ""
		if username:self.shell_username = "-u"+username
		if password:self.shell_password = "-p"+password
		self.log = phplog(logfile)
		self.errlog = phplog(errlog,verbose=False)
		syslog.openlog(os.path.basename(sys.argv[0]))
                #检测是否连得上mysql
                self.connect = mysqlconnect.connect(host=self.host,port=self.port,user=self.username,password=self.password)

	def __del__(self):
		self.connect.close()

	def truncate_tables(self,database,tables):
		'''清空表，tables为all或者一个列表'''
		print "\033[1;33m 开始清空 实例%s 数据库%s 表%s.....\033[0m" % (self.port,database,tables)
		self.connect.database = database
		cursor = self.connect.cursor()
		if re.match(r"^all$",tables,re.I):
			cursor.execute("show tables")
			tables = cursor.fetchall()
			tables = [t[0] for t in tables]
		for table in tables:
			cursor.execute("truncate table %s" % table)
		self.connect.commit()
		message = '"success","清空 实例%s 数据库%s 表%s 完成"' % (self.port,database,tables)
		syslog.syslog(message)
		print "\033[1;32m%s\033[0m" % message
		
	def binlog_to_sql(self,stop_date_time,database,start_date_time=None):
		'''由起始时间和结束时间找到对应的二进制日志,还原成sql文件'''
		shell_start_date_time = ""
		if start_date_time:shell_start_date_time = "--start-datetime '%s'" % start_date_time
		parameter = {"start-datetime":start_date_time,"stop-datetime":stop_date_time,"shell_start_date_time":shell_start_date_time,"port":self.port,"database":database}

		#判断之前有没有导出过相同时段的二进制日志，有就直接返回已经导出的文件
		bin_log_sql = "/data/mysql_restore_tmp/%(port)s_%(database)s_%(start-datetime)s-%(stop-datetime)s.sql" % parameter
		bin_log_sql = bin_log_sql.replace(' ','_')
		if os.path.isfile(bin_log_sql):
			check_lines = tail(bin_log_sql,4)
			if "ROLLBACK /* added by mysqlbinlog */;\n" in check_lines:return bin_log_sql 
		##############################
		start_time_Epoch = 0
		stop_time_Epoch = time.mktime(datetime.datetime.strptime(stop_date_time,"%Y-%m-%d %H:%M:%S").timetuple())
		if start_date_time:start_time_Epoch = time.mktime(datetime.datetime.strptime(start_date_time,"%Y-%m-%d %H:%M:%S").timetuple())
		if start_time_Epoch >= stop_time_Epoch:raise ValueError("结束时间必须大于起始时间")
		cursor = self.connect.cursor()

		#登录mysql查看二进制日志文件前缀和所在目录
		cursor.execute("show global variables like 'log_bin_basename'")
		result = cursor.fetchone()
		if not result[1]:raise RuntimeError("实例%s没有开启二进制日志")
		log_bin_dir,log_bin_basename = os.path.split(result[1])
		################################

		#找出在起始时间和结束时间的二进制文件
		bin_log_files = []
		for root,dirs,files in os.walk(log_bin_dir):
			if root.count(os.sep) > 1:del dirs[:]
			files.sort()
			for file in files:
				if re.match(r'^%s.\d+$' % log_bin_basename,file):
					logfile = "%s/%s" % (root,file)
					if os.lstat(logfile).st_mtime > start_time_Epoch:bin_log_files.append(logfile)
					if os.lstat("%s/%s" % (root,file)).st_mtime > stop_time_Epoch:break
		if not bin_log_files:raise ValueError("在时间范围%s - %s内，实例%s没有找到对应的二进制文件" % (start_date_time,stop_date_time,self.port))
		bin_logs = " ".join(bin_log_files)
		parameter["logfiles"] = bin_logs
		parameter["bin_log_sql"] = bin_log_sql
		mkdir("/data/mysql_restore_tmp")
		cmd = "mysqlbinlog -d %(database)s %(shell_start_date_time)s --stop-datetime '%(stop-datetime)s' %(logfiles)s > %(bin_log_sql)s" % parameter
		run = subprocess.Popen(cmd,stdout=subprocess.PIPE,stderr=subprocess.PIPE,shell=True)
		stdout,stderr = run.communicate()
		if run.returncode != 0:
			raise RuntimeError("执行导出实例%(port)s,数据库%(database)s,时间段%(start-datetime)s - %(stop-datetime)s 出错:" % parameter + stderr)
		return bin_log_sql
					
	def backup(self,database,outdir,tables=None):
		'''备份，tables是具体备份哪些表，是一个正则表达式'''
		mkdir(outdir)
		chown(outdir,"mysql","mysql",R=True)
		parameter = {"host":self.host,"port":self.port,"username":self.shell_username,"password":self.shell_password,"database":database,"outdir":outdir}
                cmd = "/usr/local/mysql/bin/mysqldump -h %(host)s -P %(port)d %(username)s %(password)s -B %(database)s -d > %(outdir)s/structure.sql &&\
		/usr/local/mysql/bin/mysqldump -h %(host)s -P %(port)d %(username)s %(password)s -R -t -n -d %(database)s > %(outdir)s/routine.sql &&\
		/usr/local/mysql/bin/mysqldump -h %(host)s -P %(port)d %(username)s %(password)s %(database)s -T %(outdir)s" % parameter
		if tables:
			regex_tables = re.compile(tables)
			self.connect.database = database
			cursor = self.connect.cursor()
			cursor.execute("show tables")
			result = cursor.fetchall()
			if not result:raise ValueError("实例%s,数据库%s,没有找到匹配正则%s的表" % (self.port,database,tables))
			tbs = [ i[0] for i in result if regex_tables.match(i[0])]
			self.connect.close()
			parameter["tbs"] = " ".join(tbs)
			cmd = """
			/usr/local/mysql/bin/mysqldump -h %(host)s -P %(port)d %(username)s %(password)s -B %(database)s -t -d > %(outdir)s/structure.sql && \
			/usr/local/mysql/bin/mysqldump -h %(host)s -P %(port)d %(username)s %(password)s -B %(database)s -d --tables %(tbs)s >> %(outdir)s/structure.sql &&\
			/usr/local/mysql/bin/mysqldump -h %(host)s -P %(port)d %(username)s %(password)s -R -t -n -d -B %(database)s >%(outdir)s/routine.sql &&\
			/usr/local/mysql/bin/mysqldump -h %(host)s -P %(port)d %(username)s %(password)s -B %(database)s --tables %(tbs)s -T %(outdir)s""" % parameter
                #清空目录下的文件，保证备份干净
		rm(outdir+"/*",rf=True)
		starttime=time.time()
		result = subprocess.Popen(cmd,stdout=subprocess.PIPE,stderr=subprocess.PIPE,shell=True)
		stdout,stderr = result.communicate()
		processTime = time.time() - starttime
		if result.returncode != 0:	
			message = '"fail","%s: 备份mysql实例%s 数据库%s 失败,失败信息：%s"' % (self.host,self.port,database,stderr.rstrip())
			self.log.savelog(message)
			self.errlog.savelog(message)
			syslog.syslog(syslog.LOG_ERR,message)
			raise IOError(message)
		else:
			sizecmd = subprocess.Popen("du -sh %s |cut -f 1" % outdir,stdout=subprocess.PIPE,shell=True)
			size = sizecmd.communicate()[0].rstrip()
			message = '"success","%s: 备份mysql实例%s 数据库%s 完成,路径 %s ,备份大小为%s,历时%.7f s"' % \
			(self.host,self.port,database,outdir,size,processTime)
			self.log.savelog(message)
                        syslog.syslog(message)

	def restore(self,indir=None,database=None,datetime=None,delete=None):
		'''datetime指定还原二进制日志到指定时间点yyyy-mm-dd HH:MM:SS。delete指定删除的表，是use information_schema;select TABLE_NAME from TABLES where TABLE_SCHEMA = '4399_s1' and 后面附加的条件'''

		parameter = {"host":self.host,"port":self.port,"username":self.shell_username,"password":self.shell_password,"database":database,"datetime":datetime,"indir":indir}
		
		if indir:
			print "\033[1;33m 实例%(port)s 数据库%(database)s 开始还原%(indir)s.....\033[0m" % parameter
			if os.path.isfile(indir):
				dbname = decompress(indir,check=True)
				rm("/data/mysql_restore_tmp/%s" % dbname,rf=True)
				decompress(indir,"/data/mysql_restore_tmp")
				indir = "/data/mysql_restore_tmp/%s" % dbname
				parameter["indir"] = indir

			if not database:
				cmd = """gawk -F':' 'NR == 3 && /Database:/{gsub(/ /,"",$NF);print $NF}' %(indir)s/*structure.sql""" % parameter
				old_database = os.popen(cmd).read().strip()
				if not old_database:
					message = '"fail","不能获取要还原的数据库名"'
					self.log.savelog(message)
                	        	self.errlog.savelog(message)
                	        	syslog.syslog(syslog.LOG_ERR,message)
					raise IOError(message)
				parameter["database"] = old_database

			if datetime:
				check_line = tail("%s/structure.sql" % indir,1)
                                match = re.match(r"-- Dump completed on ([\s\d:-]+)",check_line[0])
                                if not match:raise ValueError("查找备份包/目录%s 的完成备份时间失败,请检查备份是否完整" % indir)
                                backup_datetime = match.group(1).strip()
				try:
                                	bin_log_sql = self.binlog_to_sql(datetime,parameter["database"],backup_datetime)
					message = '"success","导出时间范围%s-%s的二进制日志到%s"' % (backup_datetime,datetime,bin_log_sql)
					syslog.syslog(message)
					print "\033[1;32m%s\033[0m" % message
                        	except ValueError,err:
                        	       	raise ValueError("获取指定的时间点的二进制日志出错,备份包的时间比指定的时间大？：%s" % err)
                        	except Exception,err:
                        	       	raise Exception("获取指定的时间点的二进制日志出错:%s" % err)		

			cmd = """structure=`find %(indir)s -name "*structure.sql"`;routine=`find %(indir)s -name "*routine.sql"`;
				 [ -z "$structure" ] && { echo "there no structure file";exit 1; }
				 [ -z "$routine" ] && { echo "there no routine file";exit 1; }
				 old_database=`gawk -F':' 'NR == 3 && /Database:/{gsub(/ /,"",$NF);print $NF}' $structure`
			         [ -z "$old_database" ] && { echo make be no structure file;exit 1; }
			         [ "$old_database" != %(database)s ] &&  sed -i 's/'$old_database'/%(database)s/g' $structure $routine
			         /usr/local/mysql/bin/mysql -h %(host)s -P %(port)d %(username)s %(password)s <`find %(indir)s -name "*structure.sql"` &&\
			         /usr/local/mysql/bin/mysqlimport -L -h %(host)s -P %(port)d %(username)s %(password)s %(database)s %(indir)s/*.txt &&\
			         /usr/local/mysql/bin/mysql -h %(host)s -P %(port)d %(username)s %(password)s <$routine""" % parameter
			starttime=time.time()
			result = subprocess.Popen(cmd,stdout=subprocess.PIPE,stderr=subprocess.PIPE,shell=True)
                	stdout,stderr = result.communicate()
			processTime = time.time() - starttime
			if result.returncode != 0:
                	        message = '"fail","%s: 还原mysql实例%s 数据库%s失败，失败信息：%s"' % (self.host,self.port,parameter["database"],stderr.rstrip())
                	        self.log.savelog(message)
                	        self.errlog.savelog(message)
                	        syslog.syslog(syslog.LOG_ERR,message)
				raise IOError(message)
                	else:
                	        message = '"success","%s: 还原mysql实例%s 数据库%s完成,历时%.7f s"' % (self.host,self.port,parameter["database"],processTime)
                	        self.log.savelog(message)
                	        syslog.syslog(message)

		if datetime:
			#获取完整备份的时间点
			print "\033[1;33m 实例%(port)s 数据库%(database)s 开始还原到指定时间点%(datetime)s.....\033[0m" % parameter
			if not indir:
				backup_datetime = None
				try:
					bin_log_sql = self.binlog_to_sql(datetime,parameter["database"],backup_datetime)
                                        message = '"success","导出时间范围%s-%s的二进制日志到%s"' % (backup_datetime,datetime,bin_log_sql)
                                        syslog.syslog(message)
                                        print "\033[1;32m%s\033[0m" % message
				except ValueError,err:
					raise ValueError("获取指定的时间点的二进制日志出错,备份包的时间比指定的时间大？：%s" % err)
				except Exception,err:
					raise Exception("获取指定的时间点的二进制日志出错:%s" % err)
				#清空所有的表
				try:
					self.truncate_tables(parameter["database"],"all")
				except Exception,err:
					message = '"fail","实例%s 数据库%s 清空表all 失败:%s"' % (self.port,parameter["database"],err)
					print "\033[1;31m%s\033[0m" % message
					syslog.syslog(syslog.LOG_ERR,message)
					raise RuntimeError(message)
			parameter["bin_log_sql"] = bin_log_sql
			cmd = "/usr/local/mysql/bin/mysql -f -h %(host)s -P %(port)d %(username)s %(password)s -D %(database)s < %(bin_log_sql)s" % parameter
			starttime=time.time()
			run = subprocess.Popen(cmd,stdout=subprocess.PIPE,stderr=subprocess.PIPE,shell=True)
			stdout,stderr = run.communicate()
			processTime = time.time() - starttime
			if run.returncode != 0:
				message = '"fail","%(host)s: 还原mysql实例%(port)s 数据库%(database)s到时间点%(datetime)s，失败信息："' % parameter + stderr
				self.log.savelog(message)
				self.errlog.savelog(message)
				syslog.syslog(syslog.LOG_ERR,message)
				raise RuntimeError(message)
			message = '"success","%(host)s: 还原mysql实例%(port)s 数据库%(database)s到时间点%(datetime)s，完成，历时 "' % parameter + "%.7f s" % processTime
			self.log.savelog(message)
			syslog.syslog(message)

		if delete:
			try:
				print "\033[1;33m 实例%(port)s 数据库%(database)s 开始删除指定的表.....\033[0m" % parameter
				select = "select TABLE_NAME from TABLES where TABLE_SCHEMA = '%s' and %s" % (parameter["database"],delete)
				self.connect.database = "information_schema"
				cursor = self.connect.cursor()
				cursor.execute(select)
				delete_tables = cursor.fetchall()
				if not delete_tables:raise ValueError("没有找到实例%s,数据库%s符合条件%s的表" % (self.port,parameter["database"],delete))
				self.connect.database = parameter["database"]
				for table in [t[0] for t in delete_tables]:
					cursor.execute("drop table %s" % table)
				self.connect.commit()
				delete_tables_string = " ".join([d[0] for d in delete_tables])
				parameter["delete_tables_string"] = delete_tables_string
				message = '"success","%(host)s: 删除mysql实例%(port)s 数据库%(database)s 表 %(delete_tables_string)s 完成"' % parameter
				print "\033[1;32m%s\033[0m" % message
				syslog.syslog(message)
			except Exception,err:
				message = '删除指定的表失败：%s' % err
				print "\033[1;31m%s\033[0m" % message
				syslog.syslog(syslog.LOG_ERR,message)
				raise RuntimeError(message)

	def update(self,database,sql):
		cnx = mysql.connector.connect(host=self.host,port=self.port,user=self.username,password=self.password,connection_timeout=10,autocommit=True)
		#cnx.cmd_query('set max_allowed_packet=67108864')
		cursor = cnx.cursor()
		result = cursor.execute(sql,multi=True)
		for r in result:
			if r.with_rows:print r.fetchall()
		cnx.close()
	#def update (self.database,sql):
	#	cmd = """mysql -h %s -P %d -u%s -p%s -B %s -e '%s' """ % (self.host,self.port,self.username,self.password,sql)
	#	query = subprocess.Popen(cmd,stdout=subprocess.PIPE,stderr=subprocess.PIPE,shell=True)
	#	stdout,stderr = query.comunicate()
	#	if query.returncode != 0:
	#		raise Exception(stderr)
			

if __name__ == "__main__":
	db = mysql("127.0.0.1",3306,"root",None)
	db.backup("zerodb","/data/database/zerodb_2")
