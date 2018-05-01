#!/usr/bin/env bash
# Copyright©K7zy
# CreateTime: 2017-09-05 21:45:14

function env_init() {
    apt update && apt install vim wget \
    apt-transport-https \
    ca-certificates \
    curl \
    python-software-properties

    apt-get remove docker docker-engine docker.io

    curl -fsSL  https://download.docker.com/linux/$(. /etc/os-release; echo "$ID")/gpg | apt-key add - && apt-key fingerprint 0EBFCD88

    add-apt-repository \
    "deb [arch=amd64] https://download.docker.com/linux/$(. /etc/os-release; echo "$ID") \
    $(lsb_release -cs) \
    stable"

    apt update && apt-get install docker-ce
}

function pull_docker(){
    docker pull mritd/shadowsocks
}

function start_ss(){
    pass=`tr -dc 'a-zA-Z0-9~!@#$%^&*()_+' < /dev/urandom | head -c 6`
    echo $pass >> PASS
    docker run -dt --name ZERO -p 443:6443 -p 6500:6500/udp mritd/shadowsocks -m "ss-server" -s "-s 0.0.0.0 -p 6443 -m aes-256-cfb -k $pass --fast-open" -x -e "kcpserver" -k "-t 127.0.0.1:6443 -l:6500 -mode fast2"
}

env_init && pull_docker && start_ss
