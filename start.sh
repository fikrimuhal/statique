#!/bin/bash

nohup sh inotifyrun.sh &
cd /root/.dropbox-dist && ./dropboxd &
/app/statique.bin
