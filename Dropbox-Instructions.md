# Statique Dropbox Version


## Dropbox Preparation

* Make sure you have a folder called hugo-skeleton with a Hugo Project with empty content directory and Makefile in it.
* Make sure you have a config/include.txt file with paths (directories) containing Markdown files to include in the build.
* Make sure you have index.md files in each folder and \_index.md file at the root dropbox folder.

## Statique Installation

```bash
docker-compose up -d
```
or

```bash
docker build -t fikrimuhal/statique-dropbox-base -f Dockerfile.base .
docker build -t fikrimuhal/statique-dropbox -f Dockerfile.top .
docker run -d --name statique-dropbox -e WEBHOOK_PATH="/abcd" -p 3000:3000 fikrimuhal/statique-dropbox
```

If a link doesn't appear, you may display the logs via
```bash
docker logs statique-dropbox
```

* Navigate to the link to link your dropbox.
* Attach to the container and exclude folders you don't want to sync.

```bash
docker exec -it statique-dropbox /bin/bash

python /root/dropbox.py exclude add "/root/Dropbox/folder1"
python /root/dropbox.py exclude add "/root/Dropbox/folder2"
```

* It will take a while for dropbox to download all the files. You may wait to check the sync has been completed.
* Exit the container with "exit".
* inotify-tool will watch for changes in Dropbox. If it finds changes, it will start build.
