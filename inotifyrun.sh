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
  echo "Starting build..."
  python build.py
}

WATCHFOR=$HOME/Dropbox${DROPBOX_DOCS_REL_PATH:-}

while true #run indefinitely
do
  if [ -d $WATCHFOR ]; then
    # if Dropbox folder exists, start waiting for any changes. When change detected, start wait&build process.
    inotifywait -r -e modify,attrib,close_write,move,create,delete $WATCHFOR && build_after_uptodate
  fi
done
