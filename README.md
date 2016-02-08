# Statique - Static Site Server

* Statique is a static site server written with [Crystal language](http://crystal-lang.org/) and [Kemal Web Framework](http://www.kemalcr.com/).
* It compiles the Markdown content in your Dropbox folder into HTML with pandoc every X minutes.
* (Optional) It watches for changes in your Dropbox folder, then compiles all your Markdown files into HTML with pandoc when any change detected.
* It provides a hook URL so that it can copy and rebuild the Markdown files upon a change in your Dropbox folder.
* Access can be restricted with passwords and permissions.
* Each folder can be assigned special permissions via files in config folder.
* Sample Dropbox folder structure can be seen in *sample_dropbox_folder*.

## Installation

Read [Installation Docs](docs/Installation.md).

### Authentication

Passwords are located on [config/passwords.txt](https://github.com/fikrimuhal/statique/blob/dropbox/sample_dropbox_folder/statique/config/passwords.txt) file of the sample_dropbox_folder/config in the username:password format, one at each line.

### Authorization

Permissions are located on [config/permissions.yml](https://github.com/fikrimuhal/statique/blob/dropbox/sample_dropbox_folder/statique/config/permissions.yml) file of the sample_dropbox_folder/config.

* This file has a tree structure.
* *root* represents path */*.
* Each item may contain *users* and *children* options.
  * *users* option is a list of usernames who has the access to this path and its children.
    * ['\*'] represents anybody can access to this folder.
    * /\_\_kemal\_\_ and paths like /css /js should have **users: ['\*']** so that anyone can use the static assets.
  * *children* option is a list of subpaths underneath that folder.

## Development

If you want to run Statique on your local machine,

* Make sure you have proper Dropbox/statique/config folder.
* Checkout code:

```bash
git clone http://github.com/fikrimuhal/statique && git checkout dropbox && cd statique
shards install
```

Use default build scripts to build your Dropbox repository:
```bash
sh cronjob.sh
```

* When build is complete, you may Ctrl+C to close it.

* Now you can start Statique server:

```bash
crystal src/statique.cr
```

Navigate to [http://localhost:3000](http://localhost:3000) to see the result. You can use admin:admin password to access all the site.


## TODO

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
