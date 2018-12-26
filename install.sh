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
ndenv install v10.14.2
ndenv global v10.14.2
ndenv rehash

## update pip and install direnv
sudo apt install python-pip python-webpy direnv cec-utils
echo 'eval "$(direnv hook bash)"' >> ~/.bashrc

# install homebridge
npm install -g homebridge
npm install -g homebridge-tado-ac
npm install -g homebridge-http-switch
npm install -g homebridge-cmdswitch2
npm install -g https://github.com/paolotremadio/homebridge-minimal-http-blinds

# make config file
mkdir ~/.homebridge
direnv allow # get envrc file!
erb ~/raspfiles/conf/config.json.erb > ~/.homebridge/config.json

# prepare SOMA smart blinds
git clone https://github.com/paolotremadio/SOMA-Smart-Shades-HTTP-API.git ~/webshades

# https://bbs.archlinux.org/viewtopic.php?id=215080
sudo setcap 'cap_net_raw,cap_net_admin+eip' `which hcitool`
sudo setcap 'cap_net_raw,cap_net_admin+eip' `which hciconfig`

# cec setting
echo hdmi_ignore_cec_init=1 | sudo tee -a /boot/config.txt

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
