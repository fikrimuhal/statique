docker stop statique-dropbox
docker rm statique-dropbox
docker build -t fikrimuhal/statique-dropbox -f Dockerfile.top .
docker run -d --name statique-dropbox -e WEBHOOK_PATH="/abcd" -p 3000:3000 fikrimuhal/statique-dropbox
sleep 1
docker logs statique-dropbox
