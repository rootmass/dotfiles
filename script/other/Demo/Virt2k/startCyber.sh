#!/usr/bin/env bash

for i in `sudo brctl show | awk '{print $1}'`
do
    if [ $i == "Cyberbr0" ]
    then
        echo $i
    else
        virsh net-define /etc/libvirt/qemu/network/Cyberbr0.xml
        virsh net-autostart Cyberbr0
    fi
done
