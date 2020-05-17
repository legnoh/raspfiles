#!/bin/bash

set -e

# install anyenv/ndenv/pyenv
git clone https://github.com/riywo/anyenv ~/.anyenv
echo 'export PATH="$HOME/.anyenv/bin:$PATH"' >> ~/.bashrc
echo 'eval "$(anyenv init -)"' >> ~/.bashrc
exec $SHELL -l

## install node
anyenv install nodenv
exec $SHELL -l
nodenv install 12.16.3
nodenv global 12.16.3
nodenv rehash

# install ruby
sudo apt install ruby

## install direnv
sudo apt install direnv
echo 'eval "$(direnv hook bash)"' >> ~/.bashrc

# install homebridge
npm install -g homebridge
npm install -g homebridge-sesame
npm install -g paolotremadio/homebridge-minimal-http-blinds

# make config file
git clone https://github.com/legnoh/raspfiles.git ~/raspfiles && cd raspfiles
mkdir ~/.homebridge
direnv allow # get envrc file!
erb ~/raspfiles/conf/config.json.erb > ~/.homebridge/config.json

# prepare SOMA smart blinds
sudo apt install python3-pip

git clone https://github.com/paolotremadio/SOMA-Smart-Shades-HTTP-API.git ~/webshades && cd ~/webshades
pip3 install web.py

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
sudo mkdir -r /var/homebridge/persist
sudo chown -R homebridge:homebridge ~/webshades
exec $SHELL -l
sudo chmod -R 0777 /var/homebridge
sudo systemctl daemon-reload
sudo systemctl enable somablinds
sudo systemctl start somablinds
sudo systemctl enable homebridge
sudo systemctl start homebridge

# set crontab
crontab ~/raspfiles/conf/crontab
