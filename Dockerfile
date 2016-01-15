FROM ubuntu:latest

# Crystal
RUN curl http://dist.crystal-lang.org/apt/setup.sh |  bash
RUN apt-key adv --keyserver keys.gnupg.net --recv-keys 09617FD37CC06B54
RUN echo "deb http://dist.crystal-lang.org/apt crystal main" > /etc/apt/sources.list.d/crystal.list
RUN apt-get update && apt-get -y upgrade
RUN apt-get install -y crystal zlib1g-dev libssl-dev libssl-dev openssh-client git
RUN apt-get install -y libyaml-dev
RUN apt-get install -y python make
#RUN apt-get install -y python-dev python-pip


# SSH Keys
#RUN mkdir /keys
#RUN ssh-keygen -q -t rsa -N '' -f /keys/id_rsa

# Hyde
#RUN sudo pip install hyde

ADD https://github.com/spf13/hugo/releases/download/v0.15/hugo_0.15_linux_amd64.tar.gz /tmp
RUN tar xvfz /tmp/hugo*.tar.gz
RUN cp hugo_0.15_linux_amd64/hugo_0.15_linux_amd64 /usr/bin/hugo

# Build app
ADD . /app
RUN cd /app && shards install && crystal build src/statique.cr -o /app/statique.bin --release && crystal build build.cr -o /app/build.bin --release

WORKDIR "/app"
CMD ["./statique.bin"]
