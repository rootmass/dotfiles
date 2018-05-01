---
title: 'EnvironmentError: mysql_config not found'
date: 2017-03-09 01:27:17
tags: mysql
---

在安装 mysql-python时，会出现：

```
sh: mysql_config: not found
Traceback (most recent call last):
  File "setup.py", line 15, in <module>
    metadata, options = get_config()
  File "/home/zhxia/apps/source/MySQL-python-1.2.3/setup_posix.py", line 43, in get_config
    libs = mysql_config("libs_r")
  File "/home/zhxia/apps/source/MySQL-python-1.2.3/setup_posix.py", line 24, in mysql_config
    raise EnvironmentError("%s not found" % (mysql_config.path,))
EnvironmentError: mysql_config not found
```
原因是没有安装:libmysqlclient-dev
```
sudo apt-get install libmysqlclient-dev
```
找到mysql_config文件的路径
```
sudo updatedb
locate mysql_config
```
mysql_config的位置为：/usr/bin/mysql_config
[StackOverflow](http://stackoverflow.com/questions/7475223/mysql-config-not-found-when-installing-mysqldb-python-interface)
