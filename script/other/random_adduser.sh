#!/usr/bin/env bash
#set -x
for i in {1..100};do
    user=`tr -dc "a-zA-Z" < /dev/urandom | head -c 4`
    pass=`tr -dc "a-zA-Z0-9" < /dev/urandom | head -c 15`

    echo username:$user and password:$pass
    #if [ $UID -ne 0 ];then
    #    echo "Plase Use Root User"
    #    exit 0
    #else
    #   echo $user >> user.txt && echo $pass >> pass.txt
    #    useradd -m -s /bin/bash $user
    #    passwd $user --stdio $pass
    #fi
    
done
