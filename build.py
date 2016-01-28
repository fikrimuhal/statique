#!/usr/bin/python

import os
import urllib2
import time
import subprocess
from generate_index import *

APP_LOCATION=os.path.dirname(os.path.abspath(__file__))
APP_PUBLIC=os.path.join(APP_LOCATION, "public")
APP_CONFIG_PATH=os.path.join(APP_LOCATION, "config")
BUILT_PUBLIC = "/tmp/hugo-public"
DROPBOX_PATH = os.path.join(os.environ.get("HOME"), "Dropbox")
HUGO_SKEL_PATH = os.path.join(DROPBOX_PATH, "hugo-skeleton")
HUGO_PATH = "/tmp/hugo"
HUGO_CONTENT_PATH = os.path.join(HUGO_PATH, "content")
HUGO_MAKEFILE = os.path.join(HUGO_PATH, "Makefile")
HUGO_CONFIG_PATH=os.path.join(HUGO_PATH, "config")

print("App path: %s" % APP_LOCATION)
print("Dropbox path: %s" % DROPBOX_PATH)
print("Makefile path: %s" % HUGO_MAKEFILE)

if not os.path.exists(DROPBOX_PATH):
    print("Dropbox folder does not exists. ")
    system.exit(-1)

subprocess.call(["rm", "-rf", HUGO_PATH])
subprocess.call(["cp", "-rf", HUGO_SKEL_PATH, HUGO_PATH])


if not os.path.exists(HUGO_CONTENT_PATH):
    os.mkdir(HUGO_CONTENT_PATH)

def copy_dropbox_hugo_content(path):
    path = path.strip()
    if path:
        from_path = os.path.join(DROPBOX_PATH, path)
        to_path = os.path.join(HUGO_CONTENT_PATH, path)
        subprocess.call(["cp", "-rf", from_path, to_path])

include_paths = os.path.join(HUGO_PATH, "config", "include.txt")
paths = open(include_paths).read().split("\n")
for path in paths:
    copy_dropbox_hugo_content(path)

subprocess.call(["cp", "-rf", os.path.join(HUGO_SKEL_PATH, "template.html"), os.path.join(APP_LOCATION, "template.html")])


generate_indices()

subprocess.call(["rm","-rf", APP_PUBLIC, APP_CONFIG_PATH])
subprocess.call(["cp","-rf", HUGO_CONTENT_PATH, APP_PUBLIC])
subprocess.call(["cp","-rf", HUGO_CONFIG_PATH, APP_CONFIG_PATH])

print("Build complete. Output is on %s" % BUILT_PUBLIC)
