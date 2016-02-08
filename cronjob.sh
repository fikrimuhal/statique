#!/bin/bash

uptodate () {
  # returns 1 if up to date, 0 otherwise.
  local RESULT="$(python $HOME/dropbox.py status | grep "Up to date" |wc -l)"
  #date -u
  echo "Uptodate check: Result =" >> /home/ubuntu/log/statique.log
  echo "$RESULT" >> /home/ubuntu/log/statique.log

  echo "$RESULT"
}

build_after_uptodate() {
  # wait until Dropbox folder is up to date.
  while [ "$(uptodate)" != "1" ];  do
    echo "Sleeping.$(uptodate)."
    sleep 1
  done
  # When it is fully synced, start build.

  DROPBOX_STATIQUE=$HOME/Dropbox/statique
  DEFAULT_FOLDER=./sample_dropbox_folder/statique

  DROPBOX_BUILD=$DROPBOX_STATIQUE/build.py
  DEFAULT_BUILD=$DEFAULT_FOLDER/build.py

  if [ -f $DROPBOX_BUILD ]; then
    cp $DROPBOX_BUILD .
  elif [ -f $DEFAULT_BUILD ]; then
    cp $DEFAULT_BUILD .
  fi

  DROPBOX_GI=$DROPBOX_STATIQUE/generate_index.py
  DEFAULT_GI=$DEFAULT_FOLDER/generate_index.py

  if [ -f $DROPBOX_GI ]; then
    cp $DROPBOX_GI .
  elif [ -f $DEFAULT_GI ]; then
    cp $DEFAULT_GI .
  fi

  DROPBOX_MD2HTML=$DROPBOX_STATIQUE/md2html.sh
  DEFAULT_MD2HTML=$DEFAULT_FOLDER/md2html.sh

  if [ -f $DROPBOX_MD2HTML ]; then
    cp $DROPBOX_MD2HTML .
  elif [ -f $DEFAULT_MD2HTML ]; then
    cp $DEFAULT_MD2HTML .
  fi

  echo "Starting build..." >> /home/ubuntu/log/statique.log
  python build.py
  echo "Build finished." >> /home/ubuntu/log/statique.log
}

python $HOME/dropbox.py start
build_after_uptodate
TIMESTAMP=$(date -u)
echo $TIMESTAMP >> /home/ubuntu/log/cronjob.log
