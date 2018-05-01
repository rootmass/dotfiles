#!/usr/bin/env python
# -*- coding: utf-8 -*-
# Copyright©K7zy
# CreateTime: 2017-05-10 14:44:55


import os , uuid, random, shutil, sys
from tqdm import tqdm

try:
    import xml.__etree.cElementTree as ET
except ImportError:
    import xml.__etree.ElementTree as ET


class Virt3k(object):
    def __init__(self, name, memory):
        self.name = name
        self.memory = int(sys.argv[1]) * 1024

    def read_xml_file(self, file):
        root = ET.ElementTree(file='Templaetes.xml')
        self.tree = root.getroot()

    def start(self):
        pass


if __name__ == '__main__':
    run = Virt3k()
    Virt3k.start()
