#!/usr/bin/python

import os
import urllib2
import time

APP_LOCATION=os.path.dirname(os.path.abspath(__file__))
APP_PUBLIC=os.path.join(APP_LOCATION, "public")
BUILT_PUBLIC = "/tmp/hugo-public"
DROPBOX_PATH = os.path.join(os.environ.get("HOME"), "Dropbox")
HUGO_SKEL_PATH = os.path.join(DROPBOX_PATH, "hugo-skeleton")
HUGO_PATH = "/tmp/hugo"
HUGO_CONTENT_PATH = os.path.join(HUGO_PATH, "content")
HUGO_MAKEFILE = os.path.join(HUGO_PATH, "Makefile")

print("App path: %s" % APP_LOCATION)
print("Dropbox path: %s" % DROPBOX_PATH)
print("Makefile path: %s" % HUGO_MAKEFILE)

if not os.path.exists(DROPBOX_PATH):
    print("Dropbox folder does not exists. ")
    system.exit(-1)

os.system("rm -rf %(HUGO_PATH)s && cp -rf %(HUGO_SKEL_PATH)s %(HUGO_PATH)s" % locals() )
os.mkdir(HUGO_CONTENT_PATH)
def copy_dropbox_hugo_content(path):
    path = path.strip()
    if path:
        from_path = os.path.join(DROPBOX_PATH, path)
        to_path = os.path.join(HUGO_CONTENT_PATH, path)
        os.system("cp -rf \"%s\" \"%s\"" % (from_path, to_path))

include_paths = os.path.join(HUGO_PATH, "config", "include.txt")
paths = open(include_paths).read().split("\n")
for path in paths:
    copy_dropbox_hugo_content(path)
copy_dropbox_hugo_content("_index.md")

if os.path.exists(HUGO_MAKEFILE):
    print("Makefile found, building...")
    os.system("cd %(HUGO_PATH)s && make clean && make html && rm -rf %(APP_PUBLIC)s && cp -rf %(BUILT_PUBLIC)s %(APP_PUBLIC)s && cp -rf config %(APP_LOCATION)s" % locals())
    print("Build complete. Output is on %s" % BUILT_PUBLIC)
else:
    print("Makefile not found.")
