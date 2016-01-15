# statique

Statique is a static file server written with [Crystal language](http://crystal-lang.org/) and [Kemal Web Framework](http://www.kemalcr.com/).
It pulls [Hugo](https://gohugo.io/) site from a git repository, builds it and then serves as static site.
It provides a hook URL so that it can fetch and rebuild the Markdown files of Hugo project.

## Installation

```bash
docker build -t fikrimuhal/statique .
docker run -d -e WEBHOOK_PATH="/abcd" -e PRIVATE_KEY_URL="https://somehost/id_rsa" -e PUBLIC_KEY_URL="https://somehost/id_rsa.pub" -e GIT_REPO="https://github.com/fikrimuhal/hugo-sample" -p 3000:3000 --name statique fikrimuhal/statique
```
## Usage

Navigate to the server url. For if you are using for the first time, it will fetch markdown and build.

## Development


```bash
shards install
crystal build.cr
crystal src/statique.cr
```

## TODO

* MD5 Hashing for passwords
* Hook Queue

## Contributing

1. Fork it ( https://github.com/fikrimuhal/statique/fork )
2. Create your feature branch (git checkout -b my-new-feature)
3. Commit your changes (git commit -am 'Add some feature')
4. Push to the branch (git push origin my-new-feature)
5. Create a new Pull Request

## Contributors

- [aladagemre](https://github.com/aladagemre) Ahmet Emre Aladağ - creator, maintainer
