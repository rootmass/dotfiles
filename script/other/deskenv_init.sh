#!/usr/bin/env bash

test -d ~/tmp || mkdir ~/tmp || cd ~/tmp

#Update System
apt-get update && apt-get upgrade -y
apt-get install tmux htop ibus ibus-table-wubi zsh docky dkms linux-headers-`uname -r` build-essential  qemu-kvm docker.io qtcurve kde-style-qtcurve kde-config-gtk-style-preview konsole grc htop conky realpath xtrlock

#Configure VIM
curl http://j.mp/spf13-vim3 -L -o - | sh
#Configure Poweline Fonts
git clone 
#Configure ZSH Shell

#Install VirtualBox
wget -c -v "http://download.virtualbox.org/virtualbox/5.0.16/virtualbox-5.0_5.0.16-105871~Debian~jessie_amd64.deb"
wget -c -v "http://download.virtualbox.org/virtualbox/5.0.16/Oracle_VM_VirtualBox_Extension_Pack-5.0.16-105871.vbox-extpack"

#Wiresark Configure
setcap cap_net_raw,cap_net_admin=eip /usr/bin/dumpcap
