# Statique Dropbox Version

```bash
docker-compose up -d
```
or

```bash
docker build -t fikrimuhal/statique-dropbox-base -f Dockerfile.base .
docker build -t fikrimuhal/statique-dropbox -f Dockerfile.top .
docker run -d --name statique-dropbox -e WEBHOOK_PATH="/abcd" -e DROPBOX_DOCS_REL_PATH="/docs" -p 3000:3000 fikrimuhal/statique-dropbox
```

Then we will attach to the running container to setup Dropbox.
```bash
docker exec -it $(docker ps | grep -m 1 statique-dropbox | cut -d " " -f 1) /bin/bash
cd /root/.dropbox-dist && ./dropboxd &
```

* Navigate to the link to link your dropbox.
* Exclude folders you don't want to sync.
```bash
python /root/dropbox.py exclude add "/root/Dropbox/folder1"
python /root/dropbox.py exclude add "/root/Dropbox/folder2"
```

* It will take a while for dropbox to download all the files. You may wait to check the sync has been completed.
* Exit the container with "exit".
* inotify-tool will watch for changes in Dropbox. If it finds changes, it will start build.
