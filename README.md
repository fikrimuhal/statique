# statique

* Statique is a static file server written with [Crystal language](http://crystal-lang.org/) and [Kemal Web Framework](http://www.kemalcr.com/).

* It pulls a [Hugo](https://gohugo.io/) site from a git repository, builds it and then serves as a static site.

* It provides a hook URL so that it can fetch and rebuild the Markdown files of Hugo project upon git push.

* Access can be restricted with passwords and permissions.

* Each folder can be assigned special permissions via files in config folder.

* Sample Hugo site source code can be found [here](https://github.com/fikrimuhal/hugo-sample).

## Installation

* Create a public/private key pair: id_rsa and id_rsa.pub.
* Add the public key content to your git repo's Deployment Keys section.
* Add webhook for your git repo (like /abcd)
* We will provide webhook, public key, private key, git repo URLs as environment variables.

```bash
docker build -t fikrimuhal/statique .
docker run -d -e WEBHOOK_PATH="/abcd" -e PRIVATE_KEY_URL="https://somehost/id_rsa" -e PUBLIC_KEY_URL="https://somehost/id_rsa.pub" -e GIT_REPO="https://github.com/fikrimuhal/hugo-sample" -p 3000:3000 --name statique fikrimuhal/statique
```

## Usage

Navigate to the server URL. If you are using for the first time, it will fetch git repo, build it and start displaying.
Sample repo can be navigated starting from the root (/) with admin:admin credentials.

### Authentication

Passwords are located on [config/passwords.txt](https://github.com/fikrimuhal/hugo-sample/blob/master/config/passwords.txt) file of the hugo project in the username:password format, one at each line.

### Authorization

Permissions are located on [config/permissions.yml](https://github.com/fikrimuhal/hugo-sample/blob/master/config/permissions.yml) file of the hugo project.

* This file has a tree structure.
* *root* represents path */*.
* Each item may contain *users* and *children* options.
  * *users* option is a list of usernames who has the access to this path and its children.
    * ['\*'] represents anybody can access to this folder.
    * /\_\_kemal\_\_ and paths like /css /js should have **users: ['\*']** so that anyone can use the static assets.
  * *children* option is a list of subpaths underneath that folder.

## Development

If you want to run Statique on your local machine:

```bash
git clone http://github.com/fikrimuhal/statique && cd statique
shards install
crystal build.cr
crystal src/statique.cr
```

Navigate to http://localhost:3000 to see the result. You can use admin:admin password to access all the site.


## TODO

* Webhook / build for the first time doesn't work on local development.
* MD5 Hashing for passwords
* Hook Queue: if another build request comes, do not reject it but put it into the queue. If multiple requests are come, use the last one.

## Contributing

1. Fork it ( https://github.com/fikrimuhal/statique/fork )
2. Create your feature branch (git checkout -b my-new-feature)
3. Commit your changes (git commit -am 'Add some feature')
4. Push to the branch (git push origin my-new-feature)
5. Create a new Pull Request

## Contributors

- [aladagemre](https://github.com/aladagemre) Ahmet Emre Aladağ - creator, maintainer
