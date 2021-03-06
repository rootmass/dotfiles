#!/usr/bin/env python3

import os, sys
import psutil, time
import threading, subprocess

def toThreading():
    while True:
        cpu_percentagelist = []
        for i in psutil.pids():
            try:
                pids = psutil.Process(i)
                cpu_percent = pids.cpu_percent(interval=0.01)
                #print(cpu_percent, pids.name(), pids.memory_percent(), pids.gids())
            except psutil.NoSuchProcess:
                continue

            if cpu_percent > 20:
                print("Info: ", cpu_percent, pids.pid, pids.name(), )
                cpu_percentagelist.append(pids.pid)

        if not len(cpu_percentagelist) == 0:
            return cpu_percentagelist


def toProcess(POOD):
    try:
        if sys.platform == "linux2":
            subprocess.Popen("cpulimit -p %d -l 70 >> /dev/null" % int(POOD),
                     shell=True, stdout=subprocess.PIPE).communicate()
        elif sys.platform == "darwin":
            subprocess.Popen("threading -p %d -l 70 >> /dev/null" % int(POOD),
                     shell=True, stdout=subprocess.PIPE).communicate()
    except subprocess.errno:
        return error


def start():
    threads = []
    while True:
        time.sleep(1)
        for i in toThreading():
            old = []
            if i not in old:
                t = threading.Thread(target=toProcess,args=(i,))
                threads.append(t)
                t.start()
        old = start()

if __name__ == "__main__":
    start()
