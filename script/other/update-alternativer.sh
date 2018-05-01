#!/usr/bin/env bash
# Copyright©K7zy
# CreateTime: 2017-03-18 13:51:59
# sudo update-java-alternatives -s java-8-oracle

# 手动安装 JDK 1.8
#cat >> ~/.zshrc <<EOF
##set oracle jdk environment
#export JAVA_HOME=/opt/java/jdk1.8.0_121 # 这里要注意目录要换成自己解压的jdk 目录
#export JRE_HOME=${JAVA_HOME}/jre  
#export CLASSPATH=.:${JAVA_HOME}/lib:${JRE_HOME}/lib  
#export PATH=${JAVA_HOME}/bin:$PATH  
#EOF


#设置系统默认JDK
JAVA_HOME=/opt/java/jdk1.8.0_121

sudo update-alternatives --install /usr/bin/java java $JAVA_HOME/bin/java 300  
sudo update-alternatives --install /usr/bin/javac javac $JAVA_HOME/bin/javac 300  
sudo update-alternatives --install /usr/bin/jar jar $JAVA_HOME/bin/jar 300   
sudo update-alternatives --install /usr/bin/javah javah $JAVA_HOME/bin/javah 300   
sudo update-alternatives --install /usr/bin/javap javap $JAVA_HOME/bin/javap 300  

sudo update-alternatives --config java
