#!/usr/bin/env bash
# Copyright©K7zy
# CreateTime: 2016-11-30 04:03:51

docker run -d -p 9000:9000 -v /var/run/docker.sock:/var/run/docker.sock portainer/portainer
