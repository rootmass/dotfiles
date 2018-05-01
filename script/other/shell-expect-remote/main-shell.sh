#!/usr/bin/env bash
# Copyright©K7zy
# CreateTime: 2017-05-17 13:43:47

for i in `cat config/hosts.txt`
do
        export server=`echo $i | awk -F "|" '{print $1}'`
        export port=`echo $i | awk -F "|" '{print $2}'`
        export user=`echo $i | awk -F "|" '{print $3}'`
        export passwd=`echo $i | awk -F "|" '{print $4}'`
        export rootpasswd=`echo $i | awk -F "|" '{print $5}'`
        
        export cmdfile="config/commands.txt"

        ./expect-run.exp $server $port $user $passwd $rootpasswd $cmdfile
done
