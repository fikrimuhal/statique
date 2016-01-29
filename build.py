#!/usr/bin/python

import os
import urllib2
import time
import subprocess
import sys
import logging
from generate_index import *
logging.basicConfig(level=logging.INFO,
                    format='[%(asctime)s] [%(levelname)s] %(message)s')
# ====================================

# Won't start if any other build process is running...

def another_process_running():
    return filter(lambda x: "python build.py" in x and int(x.split()[1]) < os.getpid(), os.popen("ps aux | grep build").readlines())

if another_process_running():
    logging.warning("Another build is in progress. Won't start a new one.")
    sys.exit(-1)

# ====================================

# Setup
logging.info("Setting up...")

APP_ROOT_PATH = os.path.dirname(os.path.abspath(__file__))
APP_PUBLIC_PATH = os.path.join(APP_ROOT_PATH, "public")
APP_CONFIG_PATH = os.path.join(APP_ROOT_PATH, "config")
DROPBOX_ROOT = os.path.join(os.environ.get("HOME"), "Dropbox")
DROPBOX_STATIQUE_FOLDER = "statique"
DROPBOX_STATIQUE_PATH = os.path.join(DROPBOX_ROOT, DROPBOX_STATIQUE_FOLDER)
DROPBOX_STATIQUE_CONFIG_PATH = os.path.join(DROPBOX_STATIQUE_PATH, "config")
DROPBOX_STATIQUE_TEMPLATE_PATH = os.path.join(DROPBOX_STATIQUE_PATH, "template.html")
TMP_BUILD_PATH = "/tmp/statique"
TMP_CONTENT_PATH = os.path.join(TMP_BUILD_PATH, "content")
TMP_CONFIG_PATH=os.path.join(TMP_BUILD_PATH, "config")

constants = [
    "APP_ROOT_PATH", "APP_PUBLIC_PATH", "APP_CONFIG_PATH",
    "DROPBOX_ROOT", "DROPBOX_STATIQUE_PATH", "DROPBOX_STATIQUE_CONFIG_PATH", "DROPBOX_STATIQUE_TEMPLATE_PATH",
    "TMP_BUILD_PATH", "TMP_CONFIG_PATH", "TMP_CONTENT_PATH"
]

for constant in constants:
    logging.info("{:<32}:\t{}".format(constant, eval(constant)))

# ====================================
# File check

mandatory_paths = (
    DROPBOX_ROOT,
    DROPBOX_STATIQUE_PATH,
    DROPBOX_STATIQUE_CONFIG_PATH,
    DROPBOX_STATIQUE_TEMPLATE_PATH,
    os.path.join(DROPBOX_STATIQUE_CONFIG_PATH, "permissions.yml"),
    os.path.join(DROPBOX_STATIQUE_CONFIG_PATH, "passwords.txt"),
    os.path.join(DROPBOX_STATIQUE_CONFIG_PATH, "include.txt")
)
for path in mandatory_paths:
    if not os.path.exists(path):
        logging.error("Path doesn't exist: %s\nExiting now." % path)
        system.exit(-1)

# ====================================

# Clean build path and copy files from Dropbox
logging.info("Cleaning build path...")
subprocess.call(["rm", "-rf", TMP_BUILD_PATH])
logging.info("Copying statique files from Dropbox (%s) to build path (%s)... " % (DROPBOX_STATIQUE_PATH, TMP_BUILD_PATH))
subprocess.call(["cp", "-rf", DROPBOX_STATIQUE_PATH, TMP_BUILD_PATH])

# If not exists, create content folder under build path.

if not os.path.exists(TMP_CONTENT_PATH):
    os.mkdir(TMP_CONTENT_PATH)

# function to copy files from dropbox to content folder
def cp_dropbox_to_content(path):
    path = path.strip()
    if path:
        from_path = os.path.join(DROPBOX_ROOT, path)
        to_path = os.path.join(TMP_CONTENT_PATH, path)
        subprocess.call(["cp", "-rf", from_path, to_path])

# Learn which folders to copy for build.
include_paths = os.path.join(TMP_CONFIG_PATH, "include.txt")
paths = filter(lambda x: x.strip(), open(include_paths).read().split("\n"))

logging.info("Copying these folders in Dropbox to content folder: %s" % ", ".join(paths))
# Copy those folders to content folder.
for path in paths:
    cp_dropbox_to_content(path)

# Copy HTML template for index.html
subprocess.call(["cp", "-rf", DROPBOX_STATIQUE_TEMPLATE_PATH, os.path.join(APP_ROOT_PATH, "template.html")])

logging.info("Index.html template copied. Indices are being generated...")
# Generate indices: index.html at each folder.
generate_indices(content_folder = TMP_CONTENT_PATH)

# ====================================
# Deploy generated files to APP_PUBLIC_PATH
logging.info("Deploying generated files to application public.")
subprocess.call(["rm","-rf", APP_PUBLIC_PATH, APP_CONFIG_PATH])
subprocess.call(["mv", TMP_CONTENT_PATH, APP_PUBLIC_PATH])
subprocess.call(["mv", TMP_CONFIG_PATH, APP_CONFIG_PATH])

# ====================================

logging.info("Build complete. Output is on %s" % APP_PUBLIC_PATH)
