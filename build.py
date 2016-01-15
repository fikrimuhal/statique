#!/usr/bin/python

import os
import urllib2
import time

APP_LOCATION=os.path.dirname(os.path.abspath(__file__))
APP_PUBLIC="%s/public" % APP_LOCATION


ENV_GIT_REPO = os.environ.get("GIT_REPO")
if not ENV_GIT_REPO:
    GIT_REPO="https://github.com/fikrimuhal/hugo-sample"
    GITDIR_PATH="/tmp/git_repo"
else:
    GIT_REPO = ENV_GIT_REPO
    GITDIR_PATH="/repo"

    PRIVATE_KEY_URL=os.environ.get("PUBLIC_KEY_URL")
    PUBLIC_KEY_URL=os.environ.get("PRIVATE_KEY_URL")
    if not os.path.exists("/root/.ssh/id_rsa"):
        os.mkdir("/root/.ssh")
        private_key = urllib2.urlopen(PRIVATE_KEY_URL).read()
        public_key = urllib2.urlopen(PUBLIC_KEY_URL).read()
        f = open("/root/.ssh/id_rsa", "w")
        f.write(private_key)
        f.close()
        f = open("/root/.ssh/id_rsa.pub", "w")
        f.write(public_key)
        f.close()
        os.system("chmod 600 /root/.ssh/id_rsa")
        os.system("chmod 600 /root/.ssh/id_rsa.pub")
        os.system('echo "StrictHostKeyChecking no" >> /etc/ssh/ssh_config')
        time.sleep(1)


if os.path.exists(GITDIR_PATH):
    # update
    print "Repo found, updating..."
    os.system("cd %(GITDIR_PATH)s && make clean && git checkout -- . && git pull && make html && rm -rf %(APP_PUBLIC)s && cp -rf public %(APP_PUBLIC)s && cp -rf config %(APP_LOCATION)s/config"" % locals())
    #os.system("cd %(GITDIR_PATH)s && git checkout -- . && git pull && hyde gen && rm -rf %(APP_PUBLIC)s && cp -rf deploy %(APP_PUBLIC)s" % locals())
else:
    print "Repo not found, cloning..."
    os.system("git clone %(GIT_REPO)s %(GITDIR_PATH)s && cd %(GITDIR_PATH)s && make html && rm -rf %(APP_PUBLIC)s && cp -rf public %(APP_PUBLIC)s && cp -rf config %(APP_LOCATION)s/config" % locals())

    #os.system("git clone %(GIT_REPO)s %(GITDIR_PATH)s && cd %(GITDIR_PATH)s && hyde gen && rm -rf %(APP_PUBLIC)s && cp -rf deploy %(APP_PUBLIC)s" % locals())
