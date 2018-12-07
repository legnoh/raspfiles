#!/bin/bash

set -e

# install anyenv/ndenv/pyenv
git clone https://github.com/riywo/anyenv ~/.anyenv
echo 'export PATH="$HOME/.anyenv/bin:$PATH"' >> ~/.bashrc
echo 'eval "$(anyenv init -)"' >> ~/.bashrc
exec $SHELL -l

## install node
anyenv install ndenv
exec $SHELL -l
ndenv install v10.14.1
ndenv global v10.14.1
ndenv rehash

## update pip
sudo apt install python-pip

# install homebridge
npm install -g homebridge
npm install -g homebridge-tado-ac
npm install -g homebridge-http-switch
npm install -g https://github.com/paolotremadio/homebridge-minimal-http-blinds

# install fix branch versions homebridge-cec-accessory
cd ~/.anyenv/envs/ndenv/versions/v10.14.1/lib/node_modules
git clone https://github.com/jbree/homebridge-cec-accessory.git
cd homebridge-cec-accessory
git checkout -b branch-timeout-fix origin/branch-timeout-fix
npm install
cd

# make config file
mkdir ~/.homebridge
cp ~/raspfiles/conf/config.json ~/.homebridge/config.json

# prepare SOMA smart blinds
git clone https://github.com/paolotremadio/SOMA-Smart-Shades-HTTP-API.git ~/webshades
sudo apt-get install python-webpy

# https://bbs.archlinux.org/viewtopic.php?id=215080
sudo setcap 'cap_net_raw,cap_net_admin+eip' `which hcitool`
sudo setcap 'cap_net_raw,cap_net_admin+eip' `which hciconfig`

# change permission of homebridge to cec
sudo apt-get install cec-utils
echo hdmi_ignore_cec_init=1 | sudo tee -a /boot/config.txt

# execute in daemon
sudo useradd --system homebridge
sudo usermod -a -G video homebridge
sudo chown -R homebridge:homebridge /usr/bin/cec-client
sudo mkdir /var/homebridge
sudo chown homebridge:homebridge /var/homebridge/
sudo cp ~/raspfiles/conf/etc-default.conf /etc/default/homebridge
sudo cp ~/raspfiles/conf/service-homebridge.ini /etc/systemd/system/homebridge.service
sudo cp ~/raspfiles/conf/service-soma-blinds.ini /etc/systemd/system/somablinds.service
sudo cp ~/raspfiles/conf/service-cec-client.ini /etc/systemd/system/cecclient.service
sudo cp ~/.homebridge/config.json /var/homebridge/
sudo mkdir -r /var/homebridge/persist
sudo chown -R homebridge:homebridge ~/webshades
exec $SHELL -l
sudo chmod -R 0777 /var/homebridge
sudo systemctl daemon-reload
sudo systemctl enable somablinds
sudo systemctl start somablinds
sudo systemctl enable cecclient
sudo systemctl start cecclient
sudo systemctl enable homebridge
sudo systemctl start homebridge

# set crontab
crontab ~/raspfiles/conf/crontab
