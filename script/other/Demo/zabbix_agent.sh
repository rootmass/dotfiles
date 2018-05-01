#!/usr/bin/env bash

rpm -ivh http://repo.zabbix.com/zabbix/3.0/rhel/7/x86_64/zabbix-release-3.0-1.el7.noarch.rpm
yum -y install zabbix-agent
sed -i 's/Server=127.0.0.1/Server=172.17.44.196/g' /etc/zabbix/zabbix_agentd.conf

systemctl enable zabbix-agent
systemctl start zabbix-agent
