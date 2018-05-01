#!/usr/bin/env bash
# CreateTime: 2016-07-12 19:46:16

PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH
#===============================================================================================
#   System Required:    Debian && Centos 7
#   Description:        Basic system environment configuration
#   Author:             k7zy    
#   Intro:              https://k7zy.com
#===============================================================================================

#// Desktop Env
function package() {
    apt update 
    apt install tmux git curl wget zsh autojump docky htop grc thefuck proxychains4 -y

}

function docker(){
    yum install -y yum-utils device-mapper-persistent-data lvm2
    yum-config-manager \
            --add-repo \
                https://download.docker.com/linux/centos/docker-ce.repo
    yum makecache fast
    yum install docker-ce -y
}

function vim() {
    #function_body
}

function emacs(){


}

function minikube(){
    curl -Lo minikube https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64 && chmod +x minikube && cp -rv minikube /usr/local/bin
    curl -Lo kubectl https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl && chmod +x kubectl && cp -rv kubectl /usr/local/bin

    yum install libvirt-daemon-kvm kvm -y
    useradd -s /bin/bash -m kube
    echo "kube ALL=(ALL:ALL) ALL" >> /etc/sudoers
    usermod -a -G libvirt kube
    newgrp libvirt
}

function dotfile() {
    #function_body
}

function SecurityTool() {
    #function_body
}

function start(){
    package
    docker
    minikube
}

start


#// Service env configure

function gcp(){
    if [ $UID -ne 0 ];then echo "Plase use root exec"; exit 1;fi

    NAME="K7ZY"
    #Add User
    useradd -m -s /bin/bash ${NAME}

    #Update Sudoers NOPASSWD
    sed -i '$i k7zy    ALL=(ALL:ALL) NOPASSWD:ALL' /etc/sudoers

    #SET PUBLICKEY LOGIN

    cat >> /home/${NAME}/.ssh/authorized_keys << EOF
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQC40bmdRFT1ywLEExKW2Er+FzCNvRyn5TtQnDM5HRl6/Q6FJYnhBYD2BCbc9hdjt1maWjy6lw5Ar5+I+KjEnaonXhsprbIaMrHq7wdBXYf0maK+r1v0l6HfqA99P0UFQAEQEIQtG+eQhK5noBqcWwFJRUp5dAM3TErMAW36ybZ7iMHyCs+mU5gw6ApcYAapXc29LgPoMQPhPe27voBAT8mMIRjf6TsdrDxc9DijB7ZsMtSV3wWXu+vr+6ekT3X+xogJgBzZWNtIWSyeae1AoeRTANFdyjIdOwQFZIMvlXGDo2JVXxnpJqxakyj+5D5xS5cUnlJJXbv3Nk0Z4PIv06RMnGaysFl5YEVvzoIZaUG4zAA1SkC+qAiPDpp5cyBlTOgcZtIYiFIcY56M4CDPNX4+3bKSg321LoNUNuNGA+sPeNk6zxAtU9vwA1bz8+tzjJdmUEBU/mDx5I+dHIcoxNOnzNbtwRWO3nVtfU4Gi3hjtWFKT/Trid21dzMcruDuAVJQWO9+gNRriOvY5g/cuWtKc2/A1sgFzK+qzIWAYxrY95HAXDkRQ5gYMo8JAcCRGEtO+24H9A+ZVFq0O/Hz6MvcMqnbz9GZEZy631EMf/H53PsIzMqzORnWv5tGyAT3lCw5fsRj1DlChUNKJ8Yz4Tf2Cau0u5V1j5IJDpCiaA0Xlw== k7zy@gcp-devel-instance-01
    EOF
}
