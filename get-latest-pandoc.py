#!/usr/bin/env python3
import requests as req
import json
import sys

def getDeb():
    resp = req.get("https://api.github.com/repos/jgm/pandoc/releases")
    if resp.status_code != 200 :
        sys.exit("Couldn't fetch the latest pandoc release!")
    else:
        data = json.loads(resp.content)
        binary = req.get(data[0]["assets"][0]["browser_download_url"])

        if binary.status_code != 200:
            sys.exit("Couldn't download the latest deb package!")
        else:
            file = open(data[0]["assets"][0]["name"], "xb")
            file.write(binary.content)
            file.close()

            print(data[0]["assets"][0]["name"])

getDeb()
