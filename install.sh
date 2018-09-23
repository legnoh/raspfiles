#!/bin/bash

set -e

# install anyenv/ndenv/pyenv
git clone https://github.com/riywo/anyenv ~/.anyenv
echo 'export PATH="$HOME/.anyenv/bin:$PATH"' >> ~/.bashrc
echo 'eval "$(anyenv init -)"' >> ~/.bashrc
exec $SHELL -l

## install node
anyenv install ndenv
ndenv install v10.11.0
ndenv global v10.11.0
ndenv rehash

## install python
sudo apt-get install -y make build-essential libssl-dev zlib1g-dev libbz2-dev \
libreadline-dev libsqlite3-dev wget curl llvm libncurses5-dev libncursesw5-dev \
xz-utils tk-dev libffi-dev liblzma-dev
anyenv install pyenv
pyenv install 3.7.0
pyenv global 3.7.0
pyenv rehash

# install homebridge
npm install -g homebridge
npm install -g homebridge-ifttt
npm install -g homebridge-tado-ac
npm install -g https://github.com/paolotremadio/homebridge-minimal-http-blinds

# make config file
mkdir ~/.homebridge
cp conf/config.json ~/.homebridge/config.json

# prepare SOMA smart blinds
git clone https://github.com/paolotremadio/SOMA-Smart-Shades-HTTP-API.git ~/webshades
cd webshades
sudo pip install webshades.py

# execute in daemon
sudo useradd --system homebridge
sudo mkdir /var/homebridge
sudo chown homebridge:homebridge /var/homebridge/
sudo cp conf/etc-default.conf /etc/default/homebridge
sudo cp conf/service-homebridge.ini /etc/systemd/system/homebridge.service
sudo cp conf/service-soma-blinds.ini /etc/systemd/system/somablinds.service
sudo cp ~/.homebridge/config.json /var/homebridge/
sudo cp -r ~/.homebridge/persist /var/homebridge
sudo chmod -R 0777 /var/homebridge
sudo systemctl daemon-reload
sudo systemctl enable somablinds
sudo systemctl start somablinds
sudo systemctl enable homebridge
sudo systemctl start homebridge
