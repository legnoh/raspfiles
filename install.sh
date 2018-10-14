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

## update pip
pip install --upgrade pip

# install homebridge
npm install -g homebridge
npm install -g homebridge-http-switch
npm install -g homebridge-tado-ac
npm install -g https://github.com/paolotremadio/homebridge-minimal-http-blinds

# make config file
mkdir ~/.homebridge
cp ~/raspfiles/conf/config.json ~/.homebridge/config.json

# prepare SOMA smart blinds
git clone https://github.com/paolotremadio/SOMA-Smart-Shades-HTTP-API.git ~/webshades
cd webshades
pip install web.py

# https://bbs.archlinux.org/viewtopic.php?id=215080
sudo setcap 'cap_net_raw,cap_net_admin+eip' `which hcitool`
sudo setcap 'cap_net_raw,cap_net_admin+eip' `which hciconfig`

# execute in daemon
sudo useradd --system homebridge
sudo mkdir /var/homebridge
sudo chown homebridge:homebridge /var/homebridge/
sudo cp ~/raspfiles/conf/etc-default.conf /etc/default/homebridge
sudo cp ~/raspfiles/conf/service-homebridge.ini /etc/systemd/system/homebridge.service
sudo cp ~/raspfiles/conf/service-soma-blinds.ini /etc/systemd/system/somablinds.service
sudo cp ~/.homebridge/config.json /var/homebridge/
sudo cp -r ~/.homebridge/persist /var/homebridge
sudo chmod -R 0777 /var/homebridge
sudo systemctl daemon-reload
sudo systemctl enable somablinds
sudo systemctl start somablinds
sudo systemctl enable homebridge
sudo systemctl start homebridge
