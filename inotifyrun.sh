#!/bin/sh

uptodate () {
  # returns 1 if up to date, 0 otherwise.
  python $HOME/dropbox.py status | grep "Up to date" |wc -l
}

build_after_uptodate() {
  # wait until Dropbox folder is up to date.
  while [ "$(uptodate)" != "1" ];  do
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

  echo "Starting build..."
  python build.py
}

build_after_uptodate

WATCHFOR=$HOME/Dropbox${DROPBOX_DOCS_REL_PATH:-}

while true #run indefinitely
do
  if [ -d $WATCHFOR ]; then
    # if Dropbox folder exists, start waiting for any changes. When change detected, start wait&build process.
    inotifywait -r -e modify,attrib,close_write,move,create,delete $WATCHFOR && build_after_uptodate
  fi
done
