#!/usr/bin/env python
# -*- coding: utf-8 -*-
import subprocess
import sys
import syslog
import time
import os
import pdb
import grp
import pwd
from yunwei.php import phplog

'''通用文件操作模块

专门针对游戏服务器常用的文件操作集中成一通用模块'''

def compress(indir,outdir,compressfile,logfile=None,errlog=None):
	'''压缩函数，

	目前支持最合适的两种压缩方式，bz2压缩率最少，消耗CPU最多，lzo消耗最少，压缩率稍高'''

	#初始化日志实例
	log = phplog(logfile)
	errlog = phplog(errlog,verbose=False)
	syslog.openlog(os.path.basename(sys.argv[0]))

	available = ("bz2","lzo")
	suffix = compressfile.rsplit(".",1)[-1]
	if not suffix in available:
		message ='"fail","指定的压缩文件%s不是bz2或者lzo"' % compressfile
		log.savelog(message)
                errlog.savelog(message)
                syslog.syslog(syslog.LOG_ERR,message)
		raise ValueError(message)
	dir = os.path.dirname(indir.rstrip("/"))
	filename = os.path.basename(indir.rstrip("/"))
	localtime = time.strftime("%Y-%m-%d_%H-%M-%S")
	if suffix == "bz2":
		cmd="cd %s;tar -cjf %s/%s %s" % (dir,outdir,compressfile,filename)
	else:
		cmd="cd %s;tar --lzop -cf %s/%s %s" % (dir,outdir,compressfile,filename)	
	mkdir(outdir)
	starttime=time.time()
	compress = subprocess.Popen(cmd,stdout=subprocess.PIPE,stderr=subprocess.PIPE,shell=True)
	stdour,stderr = compress.communicate()
	processtime = time.time() - starttime
	if compress.returncode != 0:
		message = '"fail","压缩%s 为%s失败,失败信息为: %s"' % (indir,compressfile,stderr)
		log.savelog(message)
		errlog.savelog(message)
		syslog.syslog(syslog.LOG_ERR,message)
		raise Exception(message)
	else:
		size_byte=os.path.getsize(outdir+"/"+compressfile)
		size_MB=float(size_byte)/1024/1024
		message = '"success","压缩%s 为%s/%s成功,历时 %.7f s,大小为 %.3f MB"' % (indir,outdir,compressfile,processtime,size_MB)
		log.savelog(message)
		syslog.syslog(message)
		return 0

def decompress(file,outdir=None,logfile=None,errlog=None,check=False):
	'''解压缩函数，

        目前支持最合适的两种压缩方式，bz2压缩率最少，消耗CPU最多，lzo消耗最少，压缩率稍高,返回压缩目录名
        参数check为True时，只返回压缩的首个目录或者文件，并非真正解压'''
	#初始化日志实例
        log = phplog(logfile)
        errlog = phplog(errlog,verbose=False)
	syslog.openlog(os.path.basename(sys.argv[0]))
	if not outdir:outdir=os.path.dirname(sys.argv[0])

	available = ("bz2","lzo")
	suffix = file.split(".")[-1]
	if not suffix in available:
		message ='"fail","指定的压缩文件不是bz2或者lzo"'
                log.savelog(message)
                errlog.savelog(message)
                syslog.syslog(syslog.LOG_ERR,message)
                raise ValueError(message)
	if not os.path.isfile(file):
		message ='"fail","指定的压缩文件%s不存在"' % file
                log.savelog(message)
                errlog.savelog(message)
                syslog.syslog(syslog.LOG_ERR,message)
		raise IOError(message)
	if suffix == "bz2":
		cmd = 'content=(`tar --show-stored-names -xvjf %s -C %s`);[ "$?" -eq 0 ] && echo ${content[0]} ||exit 1' % (file,outdir)
		if check:cmd = 'content=(`tar --show-stored-names -tjf %s`);[ "$?" -eq 0 ] && echo ${content[0]} ||exit 1' % file
	else:
		cmd = 'content=(`tar --show-stored-names --lzop -xvf %s -C %s`);[ "$?" -eq 0 ] && echo ${content[0]} ||exit 1' % (file,outdir)
		if check:cmd = 'content=(`tar --show-stored-names --lzop -tf %s`);[ "$?" -eq 0 ] && echo ${content[0]} ||exit 1' % file
	mkdir(outdir)
	starttime=time.time()
	decompress = subprocess.Popen(cmd,stdout=subprocess.PIPE,stderr=subprocess.PIPE,shell=True)
	stdout,stderr = decompress.communicate()
	processtime = time.time() - starttime
	if check:
		if stdout and decompress.returncode == 0:
			return stdout.strip()
		else:
			raise RuntimeError("检测%s压缩包，并获取目录名失败" % file)
	if decompress.returncode != 0:
                message = '"fail","解压%s 到%s失败,失败信息为: %s"' % (file,outdir,stderr)
                log.savelog(message)
                errlog.savelog(message)
                syslog.syslog(syslog.LOG_ERR,message)
		raise Exception(message)
        else:
                message = '"success","解压%s 到%s成功,历时: %.7f s"' % (file,outdir,processtime)
                log.savelog(message)
                syslog.syslog(message)
		return stdout.rstrip()

def chown(path,user,group,R=False):
	try:
		uid,gid= pwd.getpwnam(user)[2],grp.getgrnam(group)[2]
	except KeyError,e:
		print "name not find:%s" % e
	
	if R:
		for dirpath,dirs,files in os.walk(path,topdown=True):
			os.chown(dirpath,uid,gid)
			for file in files:
				os.chown(os.path.join(dirpath,file),uid,gid)
	else:
		os.chown(path,uid,gid)
	
def chmod(path,mode,R=False):
	if R:
		for dirpath,dirs,files in os.walk(path,topdown=True):
                        os.chmod(dirpath,mode)
                        for file in files:
                                os.chmod(file,mode)
	else:
		os.chmod(path,mode)

def mkdir(path,mode=755,owner="root",group="root"):
        cmd = "if [ ! -d %s ];then mkdir -p -m %s %s && chown -R %s:%s %s;else exit 0;fi" % (path,mode,path,owner,group,path)
        run = subprocess.Popen(cmd,stdout=subprocess.PIPE,stderr=subprocess.PIPE,shell=True)
        stdout,stderr = run.communicate()
        if run.returncode != 0:
                raise IOError("创建文件夹%s出错,出错代码%s,出错信息:%s" %(path,run.returncode,stderr))

def rm(path,depth=None,expiry=None,rf=False,rm_empty_dir=False):
	'''删除文件和文件夹函数.

	depth为指定的深度(正整数)没有指定为整个深度,expiry为期限(单位为日),即超过限期的文件和文件夹就删除,没有指定不限日期,rf是否删除目录'''

	prohibit = ['/','/*','//*','/selinux', '/media', '/bin', '/lost+found', '/net', '/usr', '/boot', '/etc', '/misc', '/opt', '/cgroup', '/home', '/sbin', '/sys', '/proc', '/.readahead_collect', '/root', '/lib64', '/tmp', '/srv', '/mnt', '/dev', '/lib', '/.autofsck', '/data', '/var', '/selinux/', '/media/', '/bin/', '/lost+found/', '/net/', '/usr/', '/boot/', '/etc/', '/misc/', '/opt/', '/cgroup/', '/home/', '/sbin/', '/sys/', '/proc/', '/.readahead_collect/', '/root/', '/lib64/', '/tmp/', '/srv/', '/mnt/', '/dev/', '/lib/', '/.autofsck/', '/data/', '/var/', '/selinux/*', '/media/*', '/bin/*', '/lost+found/*', '/net/*', '/usr/*', '/boot/*', '/etc/*', '/misc/*', '/opt/*', '/cgroup/*', '/home/*', '/sbin/*', '/sys/*', '/proc/*', '/.readahead_collect/*', '/root/*', '/lib64/*', '/tmp/*', '/srv/*', '/mnt/*', '/dev/*', '/lib/*', '/.autofsck/*', '/data/*', '/var/*', '/selinux//*', '/media//*', '/bin//*', '/lost+found//*', '/net//*', '/usr//*', '/boot//*', '/etc//*', '/misc//*', '/opt//*', '/cgroup//*', '/home//*', '/sbin//*', '/sys//*', '/proc//*', '/.readahead_collect//*', '/root//*', '/lib64//*', '/tmp//*', '/srv//*', '/mnt//*', '/dev//*', '/lib//*', '/.autofsck//*', '/data//*', '/var//*']
	if path in prohibit:
		print "删除%s目录对系统构成破坏,停止执行" % path
		return 1

	if depth:	
		depth = "-mindepth 1 -maxdepth %d" % depth
	else:
		depth = ""

	if expiry:
		expiry = "-mtime +%d" % expiry
	else:
		expiry = ""		
	if rf:
		rf = "-rf"
	else:
		rf = ""
	cmd = "find %s %s %s -exec rm %s {} \;" % (path,depth,expiry,rf)
	if rm_empty_dir:
		cmd = "find %s %s %s -type d -exec rmdir --ignore-fail-on-non-empty {} \;" % (path,depth,expiry)
	result = subprocess.Popen(cmd,stdout=subprocess.PIPE,stderr=subprocess.PIPE,shell=True)
	stdout,stderr = result.communicate()
	return stdout,stderr

def tail(file,n=20):
	'''类似shell当中的tail，获取文件最后n行，返回一个列表'''
	block = 1024
	if os.path.isfile(file):
		f = open(file,"r")
		while True:
			try:
				f.seek(-block,2)
			except IOError:
				f.seek(0,0)
			if f.tell() == 0:
				lines = f.readlines()
				f.close()
				if len(lines) >= n:return lines[-n:]
				return lines
			else:
				lines = f.readlines() 
				if len(lines) >= n:
					f.close()
					return lines[-n:]
			block = block+1024
	else:
		raise IOError("文件%s不存在" % file)
