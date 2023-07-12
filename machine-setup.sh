#!/usr/bin/env bash

RUBY_VERSION=2.3.4

NODEJS_MAJOR_VERSION=16

export HOME=/home/$USER
export TEMP_DIR=$HOME/.tmp

disp() {
    echo
    echo "################################################################"
    echo "$1"
    echo "################################################################"
}

disp "Install dependencies"
sudo apt -y update
sudo apt install -y  \
        apt-transport-https \
        bzip2 \
        ca-certificates \
        curl \
        gnupg2 \
        gosu \
        less \
        nano \
        software-properties-common \
        tar \
        vim \
        wget\
        bash \
        autoconf \
        build-essential \
        g++ \
        gcc \
        git \
        libdb-dev \
        libffi-dev \
        libgdbm-dev \
        libgdbm6 \
        libgmp-dev \
        libncurses5-dev \
        libreadline6-dev \
        libssl-dev \
        libyaml-dev \
        make \
        patch \
        rustc \
        uuid-dev \
        zlib1g-dev \
        ghostscript \
        gstreamer1.0-plugins-base \
        gstreamer1.0-tools gstreamer1.0-x \
        imagemagick \
        libcups2 \
        libcurl4-openssl-dev \
        libgtkmm-3.0-1v5 \
        libicu-dev \
        libicu67 \
        libmagic-dev \
        libnotify4 \
        libqt5webkit5-dev \
        libreoffice-core \
        libsqlite3-dev \
        libxml2-dev \
        libxslt1-dev \
        qtbase5-dev \
        qtchooser \
        xauth \
        xvfb \
        libmariadb-dev\
        graphviz

disp "installing mariadb"
sudo apt-key adv --fetch-keys 'https://mariadb.org/mariadb_release_signing_key.asc'
echo 'deb [arch=arm64] http://mirror.mva-n.net/mariadb/repo/10.6/debian bullseye main' | sudo tee /etc/apt/sources.list.d/mariadb.list
sudo apt update
sudo apt install -y mariadb-server
# We only need the drivers for the mysql2 installation gem and do want the server running in this instance
# as it will cause issues with connecting to the database on 127.0.0.1
sudo systemctl stop mariadb

echo 'export ES_JAVA_HOME=/usr' >> ~/.bashrc

disp "installing openssl"
export CURRENT_DIR=$PWD
mkdir -p "$TEMP_DIR"
wget https://www.openssl.org/source/old/1.0.2/openssl-1.0.2u.tar.gz -O $TEMP_DIR \
&& OPENSSL_CHECKSUM=5c9ca8774bd7b03e5784f26ae9e9e6d749c9da2438545077b6b3d22b4d95c0a2 \
&& echo "$OPENSSL_CHECKSUM  $TEMP_DIR/openssl-1.0.2u.tar.gz" | sha256sum -c \
&& tar xzf "$TEMP_DIR"/openssl-1.0.2u.tar.gz \
&& cd $TEMP_DIR/openssl-1.0.2u \
&& ./config --prefix=/opt/openssl-1.0 shared \
&& make \
&& make install \
&& cd $CURRENT_DIR \
&& rm -rf $TEMP_DIR/openssl-1.0.2* \
&& wget https://curl.se/ca/cacert.pem -O /opt/openssl-1.0/ssl/cert.pem

disp "installing ca certs"
sudo apt update
sudo apt install -y ca-certificates

export SSL_CERT_FILE=/etc/ssl/certs/ca-certificates.crt
export 'SSL_CERT_FILE=/etc/ssl/certs/ca-certificates.crt' >> ~/.bashrc

disp "installing jdk"
sudo apt install -y --no-install-recommends openjdk-17-jre-headless

disp "installing node"
sudo apt update
sudo curl -fsSL https://deb.nodesource.com/setup_$NODEJS_MAJOR_VERSION.x | sudo bash - \
    && sudo apt install -y nodejs

disp "installing npm"
sudo npm install -g npm
mkdir -p ~/.npm-global
npm config set prefix ~/.npm-global
echo 'export PATH=~/.npm-global/bin:$PATH' >> ~/.bashrc
export PATH=~/.npm-global/bin:$PATH


disp "install Ruby"
ruby_version=$(ruby -v 2>/dev/null)
if [ $? -eq 0 ]; then
    echo "Ruby is installed"
    echo "Ruby version: $ruby_version"
else
    echo "Ruby is not installed"
    sudo apt update
    sudo apt install -y rbenv ruby-build

    echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> ~/.bashrc
    echo 'eval "$(rbenv init -)"' >> ~/.bashrc
    eval "$(rbenv init -)"
    source ~/.bashrc

    sudo apt-get install libssl-dev libreadline-dev zlib1g-dev

    rbenv install 2.3.4
    rbenv global 2.3.4
fi

disp "Clean sudo apt packages"
sudo apt -y autoremove \
    && sudo apt -y clean \
    && sudo rm -rf /var/lib/apt/lists/*


disp "install bundler"
gem install bundler --version 1.17.3

