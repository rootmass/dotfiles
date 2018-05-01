#!/usr/bin/env bash
# CreateTime: 2016-07-12 19:46:16

PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH
#===============================================================================================
#   System Required:    Only Debian
#   Description:        Basic system environment configuration
#   Author:             k7zy    
#   Intro:              https://k7zy.com
#===============================================================================================

function package() {
    yum update 
    yum install vim tmux git curl wget -y

}

function configure(){

}

function start(){
    package
    docker
    configure

}

start
