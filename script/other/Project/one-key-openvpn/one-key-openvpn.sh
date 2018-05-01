#!/usr/bin/env bash
#PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
#export PATH

echo "############################################################"
echo "# Install OpenVpn for Debian (32bit/64bit)                  "
echo "# Intro: https://k7zy.com                                   "
echo "#                                                           "
echo "# Author:k7zy                                               "
echo "#                                                           "
echo "############################################################"

# STArt install openvpn
function start_openvpn(){
    rootness
    add_source
    env_init
    add_key
    uninstall_old
    install_docker
    docker_openvpn
}

# Check root users
function rootness(){
    if [[ $EUID -ne 0 ]];then
    echo "Error:This script must be run as root!" 1>&2
    exit 1
    fi
}

#  Init System Env
function env_init(){
    apt update
    apt install -y curl \
        git \
        vim \
        apt-transport-https \
        ca-certificates \
        gnupg2 \
        software-properties-common \
	    tmux \
	    htop 
}

# Uninstall old Version
function uninstall_old(){
    apt  -y remove docker docker-engine docker.io
}

function add_source(){
    cat > /etc/apt/sources.list <<-EOF
           deb  http://deb.debian.org/debian stretch main
           deb-src  http://deb.debian.org/debian stretch main

           deb  http://deb.debian.org/debian stretch-updates main
           deb-src  http://deb.debian.org/debian stretch-updates main

           deb http://security.debian.org/ stretch/updates main
           deb-src http://security.debian.org/ stretch/updates main
EOF
}

# Add Docker’s official GPG key:
function add_key(){

    add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/debian $(lsb_release -cs) stable"
    curl -fsSL https://download.docker.com/linux/debian/gpg | apt-key add -

    apt-key fingerprint 0EBFCD88
}

function install_docker(){
    apt update
    apt install -y docker-ce 
}

function docker_openvpn(){
    iptables -F -t nat
    docker pull kylemanna/openvpn

    rondomPass=$(tr -dc 'a-zA-Z0-9~!@#$%^&*' < /dev/urandom | head -c 18)

    echo "Start configure docker-openvpn"
    OVPN_DATA="/root/openvpn"
    IP=$(hostname -I | awk -F ' ' '{print $1}')
    mkdir ${OVPN_DATA}
    docker run -v ${OVPN_DATA}:/etc/openvpn --rm kylemanna/openvpn ovpn_genconfig -u tcp://${IP}
    docker run -v ${OVPN_DATA}:/etc/openvpn --rm -it kylemanna/openvpn ovpn_initpki
    docker run -v ${OVPN_DATA}:/etc/openvpn --rm -it kylemanna/openvpn easyrsa build-client-full CLIENTNAME nopass
    docker run -v ${OVPN_DATA}:/etc/openvpn --rm kylemanna/openvpn ovpn_getclient CLIENTNAME > ${OVPN_DATA}/CLIENTNAME.ovpn
    docker run --name openvpn -v ${OVPN_DATA}:/etc/openvpn -d -p 44444:1194 --privileged kylemanna/openvpn

    echo "Pass: $rondomPass"
}

start_openvpn
