FROM ubuntu:latest

# Crystal
RUN curl http://dist.crystal-lang.org/apt/setup.sh |  bash
RUN apt-key adv --keyserver keys.gnupg.net --recv-keys 09617FD37CC06B54
RUN echo "deb http://dist.crystal-lang.org/apt crystal main" > /etc/apt/sources.list.d/crystal.list
RUN apt-get update \
  && apt-get install -y crystal=0.10.2-1 \
                        zlib1g-dev \
                        libssl-dev \
                        libssl-dev \
                        openssh-client \
                        libyaml-dev \
                        python \
                        make \
                        inotify-tools \
                        wget \
                        git

# == START Dropbox ===

WORKDIR "/root"
RUN wget -O - "https://www.dropbox.com/download?plat=lnx.x86_64" | tar xzf -
RUN wget https://www.dropbox.com/download?dl=packages/dropbox.py -O dropbox.py

# === END DROPBOX ===
ADD https://github.com/spf13/hugo/releases/download/v0.15/hugo_0.15_linux_amd64.tar.gz /tmp
RUN tar xvfz /tmp/hugo*.tar.gz
RUN cp hugo_0.15_linux_amd64/hugo_0.15_linux_amd64 /usr/bin/hugo
RUN rm -rf hugo* /tmp/hugo*ls

# Build app
ADD . /app
RUN cd /app && shards install && crystal build src/statique.cr -o /app/statique.bin --release && crystal build build.cr -o /app/build.bin --release

WORKDIR "/app"
CMD ["sh", "start.sh"]
