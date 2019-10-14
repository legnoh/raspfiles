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
nodenv install v10.15.1
nodenv global v10.15.1
nodenv rehash

## update pip and install direnv
sudo apt install direnv
echo 'eval "$(direnv hook bash)"' >> ~/.bashrc

# install homebridge
npm install -g homebridge
npm install -g legnoh/homebridge-daikin-air-purifier

# make config file
mkdir ~/.homebridge
direnv allow # get envrc file!
erb ~/raspfiles/conf/config.json.erb > ~/.homebridge/config.json

# install hc-http-switch
wget https://github.com/legnoh/hc-http-switch/releases/download/v1.0.8/hc-http-switch_1.0.8_linux_armv7.tar.gz
tar zxf hc-http-switch_1.0.8_linux_armv7.tar.gz
sudo chown root:staff hc-http-switch
sudo mv hc-http-switch /usr/local/bin/

# execute in daemon
sudo useradd --system homebridge
sudo mkdir /var/homebridge
sudo chown homebridge:homebridge /var/homebridge/
sudo cp ~/raspfiles/conf/etc-default.conf /etc/default/homebridge
sudo cp ~/raspfiles/conf/service-homebridge.ini /etc/systemd/system/homebridge.service
sudo cp ~/raspfiles/conf/service-hc-opengate.ini /etc/systemd/system/opengate.service
sudo cp ~/.homebridge/config.json /var/homebridge/
sudo mkdir -r /var/homebridge/persist
exec $SHELL -l
sudo chmod -R 0777 /var/homebridge
sudo systemctl daemon-reload
sudo systemctl enable opengate
sudo systemctl start opengate
sudo systemctl enable homebridge
sudo systemctl start homebridge

# set crontab
crontab ~/raspfiles/conf/crontab
