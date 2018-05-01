#!/usr/bin/env python

from socket import *
from time import ctime

HOST=''
PORT=4444
ADDR=(HOST, PORT)
BUFSIZ=1024

TcpSock = socket(AF_INET, SOCK_STREAM)
TcpSock.bind(ADDR)
TcpSock.listen(5)

while True:
    print('Wating for connection...')
    tcpCliSock, addr = TcpSock.accept()
    print('...connection from:', addr)

    while True:
        data = tcpCliSock.recv(BUFSIZ)
        if not data:
            break

        tcpCliSock.send('[%s] %s'% (ctime(), data))

        tcpCliSock.close()

TcpSock.close()
