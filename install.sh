#!/bin/bash

set -e

# install ndenv
git clone https://github.com/riywo/ndenv ~/.ndenv
echo 'export PATH="$HOME/.ndenv/bin:$PATH"' >> ~/.bash_profile
echo 'eval "$(ndenv init -)"' >> ~/.bash_profile
exec $SHELL -l

# install node
ndenv install v10.11.0
ndenv global v10.11.0
ndenv rehash

# install homebridge
npm install -g homebridge
npm install -g homebridge-ifttt
npm install -g homebridge-tado-ac
npm install -g https://github.com/paolotremadio/homebridge-minimal-http-blinds

# make config file
touch ~/.homebridge/config.json

# prepare soma smart blinds
mkdir -p /home/pi/webshades/
wget https://github.com/paolotremadio/SOMA-Smart-Shades-HTTP-API/archive/master.zip
unzip -d /home/pi/webshades master.zip
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
