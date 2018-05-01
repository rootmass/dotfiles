#!/usr/bin/env bash

set +x

if [ $EUID -eq 0 -o $UID -eq 0 ]; then
    echo -e "\033[31m##Displays the current interface## \033[0m"
    hciconfig
    for intface in $(hciconfig | awk '{if ((length($1)>=4 )) print $1}' | sed 's/://g');do
        hciconfig ${intface} up
    done
    
        rm /tmp/rfc 2>/dev/null ; hcitool scan | sed '1d' | awk '{print NR")", $0}' >> /tmp/rfc
        if [ -s /tmp/rfc ];then
            exit 1
        fi 
        cat /tmp/rfc
        read -n 1 -p "Please enter the serial number you want to connect:" number \n
        #rfcomm bind /dev/rfcomm0 $(hcitool scan | sed '1d' | awk 'NR=="'$number'" {print $1}')
        rfcomm bind /dev/rfcomm0 $(cat /tmp/rfc | awk 'NR=="'$number'" {print $2}')
        cat > /dev/rfcomm0
else
   echo "Error:This script must be run as root!" 1>&2
   exit 1
fi
