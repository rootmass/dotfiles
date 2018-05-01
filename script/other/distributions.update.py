#!/usr/bin/env python
# -*- coding: utf-8 -*-
# Copyright©K7zy
# CreateTime: 2016-08-01 07:05:17

import pip
from subprocess import call

for dist in pip.get_installed_distributions():
    call("pip install --upgrade " + dist.project_name, shell=True)
