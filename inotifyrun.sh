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
  if [ -f $HOME/Dropbox/statique/build.py ]; then
    cp $HOME/Dropbox/statique/build.py .
  elif [ -f ./templates/build.py ]; then
    cp ./templates/build.py .
  fi

  if [ -f $HOME/Dropbox/statique/generate_index.py ]; then
    cp $HOME/Dropbox/statique/generate_index.py .
  elif [ -f ./templates/generate_index.py ]; then
    cp ./templates/generate_index.py .
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
