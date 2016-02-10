# Ubuntu
## Installation

```bash
sudo apt-get update
sudo apt-get -y upgrade
sudo apt-get install -y \
                        zlib1g-dev \
                        libssl-dev \
                        libssl-dev \
                        openssh-client \
                        libyaml-dev \
                        python \
                        make \
                        inotify-tools \
                        wget \
                        git \
                        curl \
                        pandoc

# Install Crenv
curl -L https://raw.github.com/pine613/crenv/master/install.sh | bash
echo 'export PATH="$HOME/.crenv/bin:$PATH"' >> ~/.bashrc
echo 'eval "$(crenv init -)"' >> ~/.bashrc
exec $SHELL -l
crenv install 0.10.2
crenv global 0.10.2
crenv rehash

# Install Dropbox daemon and client
wget -O - "https://www.dropbox.com/download?plat=lnx.x86_64" | tar xzf -
wget https://www.dropbox.com/download?dl=packages/dropbox.py -O dropbox.py

# Install Statique
git clone https://github.com/fikrimuhal/statique
cd statique
git checkout dropbox
shards install
crystal build src/statique.cr -o statique.bin --release

# Setup upstart (statique and inotify) and profile.d (dropbox) scripts
sudo cp scripts/upstart/* /etc/init
sudo cp scripts/profile.d/* /etc/profile.d/
```

## Configuration


### Dropbox Configuration

Start dropbox daemon and navigate to the link provided to link it with your account:

```bash
cd ~/.dropbox-dist
./dropboxd
```

When linked, hit Ctrl+C to stop it and start with Dropbox client:

```bash
python ~/dropbox.py start
```

Then you can exclude folders you don't want to sync:

```bash
python ~/dropbox.py exclude add "~/Dropbox/folder1"
python ~/dropbox.py exclude add "~/Dropbox/folder2"
```

### Statique Configuration

Copy sample statique folder to your Dropbox:

```bash
cp -rf ./sample_dropbox_folder/statique ~/Dropbox/statique
```

Optionally, you may want to copy sample markdown folders (be careful not to overwrite your files)

```bash
cp -rf ./sample_dropbox_folder/* ~/Dropbox
```

Check out *~/Dropbox/statique*. Modify files under *config*, *engineering*, *management* as you wish.

If you want to use web hook for build-on-demand, you may add an environment variable to upstart configuration:

```bash
echo 'env WEBHOOK_PATH="/abcd"' | sudo tee --append /etc/init/statique.conf
```

### Testing Build

You may try building your Dropbox files with:

```bash
sh cronjob.sh
```

configs, templates and scripts under *~/Dropbox/statique/config* will be used.

### Add cron job

With the following command,
```bash
crontab -e
```

Add the following line to run cronjob.sh (build) every 10 minutes.

```
*/10 * * * * cd /home/ubuntu/statique/&&/home/ubuntu/statique/cronjob.sh
```

cronjob.sh copies build scripts and templates from Dropbox or default folder and then initiates build process.


### Running Statique

```bash
cd ~/statique
./statique.bin -p 3000
```

You can navigate to :3000 of your server to see the web page. It will ask for password, use **admin** as *username*, **admin** as *password*.

### Running with upstart

You may want to use upstart to run Statique (statique.bin) as service:

```bash
sudo service statique start
```

It will run on 80 port.

### Dropbox Watcher (OPTIONAL)

You may watch your Dropbox folder and upon any change, trigger a build: build.py:

```bash
sh inotifyrun.sh
```


You can use **statique-notify** service (which runs inotifyrun.sh).
Note that watching Dropbox folder might require lots of resources depending on the number of files in it.
