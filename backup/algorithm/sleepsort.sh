#!/usr/bin/env bash
# Copyright©K7zy
# CreateTime: 2017-06-08 22:58:59

function f(){
    sleep $1
    echo "$1"
}

while [ -n "$1" ]
do
    f "$1" & 
    shift
done

wait
