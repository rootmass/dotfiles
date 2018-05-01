#!/usr/bin/env python

from socket import *

HOST = '127.0.0.1'
PORT = 4444
ADDR = (HOST, PORT)
BUFSIZ = 1024

tcpCliSock = socket(AF_INET, SOCK_STREAM)
tcpCliSock.connect_ex(ADDR)

while True:
    data = raw_input('> ')
    if not data:
        break

    tcpCliSock.send(data)
    data = tcpCliSock.recv(BUFSIZ)
    if not data:
        break
    print (data)


tcpCliSock.close()
