if判断
1:判断mysqld是否在运行，若已运行则输出提示信息，否则重新启动mysqld服务
#!/bin/bash
service mysqld status &> /dev/null
 if [ $? -eq 0]
  then
     echo "mysqld service is running."
  else
     /etc/init.d/mysqld restart
 fi

for循环
1:依次输入3条文字信息，包括一天中的“morning”、“noon”、“evening”字串
#!/bin/bash
 for TM in "morning" "noon" "evening"
   do
    echo "The $TM of the day."
 done
2：对于使用“/bin/bash”作为登陆shell的系统用户，检查他们在“/opt”目录中拥有的子目录或文件数量，如果超过100个，则列出具体的个数及相应的用户账号
#!/bin/bash
DIR="/opt"
LMT=100
ValidUsers='grep "/bin/bash" /etc/passwd | cut -d ":" -f 1'
for UserName in $ValidUsers
  do
    Num='find $DIR -user $UserName | wc -l'
   if[$Num -gt $LMT];then
     echo "$UserName have $Num files."
   fi
done

while循环
1:批量添加20个系统用户账号，依次命名为"user1","user2"……
#!/bin/bash
i=1
while [$i -le 20]
 do
   useradd user$i
   echo "123" | passwd --stdin user$i &> /dev/null
   i='expr $i+1'
 done

case多重分支语句
1>
1：编写脚本文件mydb.sh,用于控制系统服务mysqld
2：当执行./mydb.sh start时，启动mysqld服务
3：当执行./mydb.sh stop时，关闭mysqld服务
4：如果输入其他脚本参数，则显示帮助信息
#!/bin/bash
 case $1 in
   start)
     echo "Start MySQL service"
   ;;
   stop)
     echo "Stop MySQL service"
   ;;
   *)
   echo "Usage: $0 start|stop"
   ;;
esac
2>
提示用户从键盘输入一个字符，判断该字符是否为字母、数字或者其他字符，并输出相应的提示信息
#!/bin/bash
read -p "Press some key,then press Return:" KEY
case "$KEY" in
  [a-z]|[A-Z])
     echo "It's a letter."
   ;;
  [0-9])
     echo "It's s digit."
   ;;
  *)
     echo "It's function keys、Spacebar or other keys."
esac

until循环语句
shift迁移语句
通过命令行参数传递多个整数值，并计算总和
#!/bin/bash
Result=0
while [$# -gt 0]
 do
  Result='expr $Result+$1'
  shift
 done
 echo "The sum is:$Result"

shell函数
在脚本中定义一个加法函数，用于计算两个整数和
调用该函数计算(12+34)、(56+789)的和
#!/bin/bash
adder()
  {
   echo 'expr $1+$2'
  }
adder 12 34
adder 56 789