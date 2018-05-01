#!/usr/bin/env python
# -*- coding: utf-8 -*-
# vim:fenc=utf-8
# Copyright © K7zy
# CreateTime: 2016-09-17 12:58:52

import os, uuid, random, shutil, sys
from  tqdm import tqdm

try:
    import xml.etree.cElementTree as ET
except ImportError:
    import xml.etree.ElementTree as ET

def randomac():
    mac = [ 0x52, 0x54, 0x00,
            random.randint(0x00, 0x7f),
            random.randint(0x00, 0xff),
            random.randint(0x00, 0xff)]
    return ':'.join(map(lambda x: "%02x" % x, mac))

def randovncport():
    rb = range(55555,65535)
    return random.sample(rb,1)

def start():
    virtname = raw_input('Please enter name separated by spaces: ').split()
    #Calculate Memory
    memory = int(sys.argv[1]) * 1024

    for name in virtname:
        tree = ET.ElementTree(file='Templates.xml')
        root = tree.getroot()
        root[0].text = name
        root[1].text =  str(uuid.uuid4())
        root[2].text = str(memory)
        root[3].text = str(memory)

        for mac in root.iter('mac'):
            mac.set('address',randomac())

        for vnc in root.iter('graphics'):
            vnc.set('port',str(randovncport()[0]))

        for source in root.iter('source'):
            attrs = source.attrib
            oldPath = str(attrs.get('file'))
            newPath = '/mnt/VirHost/Templates.qcow2'
            if (oldPath == newPath):
                source.set('file', '/mnt/VirHost/'+name+'.qcow2')
            else:
                continue
        tree.write(name +'.xml')
        #for i in tqdm(range(100)):
        #    shutil.copy('/mnt/VirHost/Templates.qcow2','/mnt/VirHost/'+name+'.qcow2')
        cmd = 'sudo virsh define ' + name +'.xml'
        os.system(cmd)

if __name__ == '__main__':
    if len(sys.argv) <2:
        print('Usage:*.py <memory MB>')
        sys.exit(1)
    start()
