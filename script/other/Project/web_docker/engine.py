#!/usr/bin/env python
#-*- coding: utf-8 -*-
# author: k7zy

from web_docker import *
import docker, json


def connect_db():
    return sqlite3.connect(DATABASE)

def get_connection():
    db = getattr(g, '_db', None)
    if db is None:
        db = g._db = connect_db()
    return db


if __name__ == '__main__':
    c = docker.Client(base_url='unix://var/run/docker.sock')
    images = c.images()
