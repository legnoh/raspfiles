#!/bin/bash

set -e

# install anyenv/ndenv
git clone https://github.com/riywo/anyenv ~/.anyenv
echo 'export PATH="$HOME/.anyenv/bin:$PATH"' >> ~/.bashrc
echo 'eval "$(anyenv init -)"' >> ~/.bashrc
exec $SHELL -l

# install node
anyenv install ndenv
ndenv install v10.11.0
ndenv global v10.11.0
ndenv rehash

# install homebridge
npm install -g homebridge
npm install -g homebridge-ifttt
npm install -g homebridge-tado-ac
npm install -g https://github.com/paolotremadio/homebridge-minimal-http-blinds

# make config file
mkdir ~/.homebridge
cp conf/config.json ~/.homebridge/config.json

# prepare soma smart blinds
mkdir -p ~/webshades/
git clone https://github.com/paolotremadio/SOMA-Smart-Shades-HTTP-API.git ~/webshades/
sudo hciconfig hci0 up
sudo hcitool lescan
sudo pip install webshades.py

# execute in daemon
sudo useradd --system homebridge
sudo mkdir /var/homebridge
sudo chown homebridge:homebridge /var/homebridge/
sudo cp conf/etc-default.conf /etc/default/homebridge
sudo cp conf/service.ini /etc/systemd/system/homebridge.service
sudo cp ~/.homebridge/config.json /var/homebridge/
sudo cp -r ~/.homebridge/persist /var/homebridge
sudo chmod -R 0777 /var/homebridge
sudo systemctl daemon-reload
sudo systemctl enable homebridge
sudo systemctl start homebridge
