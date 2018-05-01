#!/bin/bash
DIR=/mysql/backup/
USER=root
PASSWD=root.com
HOST=localhost
time=`date +"%Y-%m-%d %H:%M:%S"`
[ ! -d $DIR ] && mkdir -pv $DIR || cd "$DIR"
mysql -u$USER -p$PASSWD -e "show databases" | sed '1d'
echo "Begin backup all Single Database........"
for Database in `mysql -u$USER -p$PASSWD -e "show databases" | sed '1d'`
do
        echo "Databases  backup Need wait...."
        mysqldump -u$USER -p$PASSWD -h$HOST $db --lock-all-tables  --flush-logs   > $Database-"$time".sql
done
echo "single database ok............"

echo "Database Full table backup............."
mysql -u$USER -p$PASSWD $Database -e "show tables" | sed '1d'
for db in `mysql -u$USER -p$PASSWD -h$HOST -e "show databases"|sed '1d'`
do
        mkdir $db
        for tables in `mysql -u$USER -p$PASSWD $db -e "show tables"|sed '1d'`
        do
                mysqldump -h$HOST -u$USER -p$PASSWD $db $table > $db/$tables
        done
done

echo "Full databases backup............."
mysqldump -u$USER -p$PASSWD -h$HOST --all-databases --lock-all-tables  --flush-logs --events  > all-"$time".sql
if [[ $? == 0 ]];then
        echo "mysql backup Success"
else
        echo "mysql backup Fail"
fi
