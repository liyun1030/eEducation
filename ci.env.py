#!/usr/bin/python
# -*- coding: UTF-8 -*-
import re
import os
import sys

def main():
    os.system("pod install")

    agoraHost = ""
    
    env = sys.argv[1]
    if (env != "1" and env != "2" and env != "3"):
        env = 1
    if env == 1:
        if "host_debug" in os.environ:
            agoraHost = os.environ["host_debug"]
            agoraHost = agoraHost[:-1]
    if env == 2:
        if "host_pre" in os.environ:
            agoraHost = os.environ["host_pre"]
            agoraHost = agoraHost[:-1]
    if env == 3:
        if "host_release" in os.environ:
            agoraHost = os.environ["host_release"]
            agoraHost = agoraHost[:-1]
    
    f = open("./AgoraEducation/Manager/HTTP/URL.h", 'r+')
    content = f.read()
    agoraHostString = agoraHost
    
    contentNew = re.sub(r'https://api.agora.io', agoraHostString, content)

    f.seek(0)
    f.write(contentNew)
    f.truncate()


if __name__ == "__main__":
    main()
