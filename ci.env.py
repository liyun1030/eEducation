#!/usr/bin/python
# -*- coding: UTF-8 -*-
import re
import os

def main():
    os.system("pod install")

    agoraAppId = ""
    if "AGORA_APP_ID" in os.environ:
        agoraAppId = os.environ["AGORA_APP_ID"]

    f = open("./AgoraEducation/KeyCenter.m", 'r+')
    content = f.read()
    agoraAppIdString = "@\"" + agoraAppId + "\""
    
    contentNew = re.sub(r'<#Your Agora App Id#>', agoraAppIdString, content)
    
    f.seek(0)
    f.write(contentNew)
    f.truncate()


if __name__ == "__main__":
    main()
