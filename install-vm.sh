#!/usr/bin/env bash

sudo apt update

# bunch of defaults programs
sudo apt install -q -y htop curl wget gpg ca-certificates apt-transport-https make net-tools screen

# Docker setup
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg
echo \
  "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  "$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt update -q

sudo apt install -q -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin cephadm lvm2 unzip

# docker for my user, this will work AFTER re-login
sudo usermod -aG docker vagrant

# Python defaults to PY3
sudo ln -s /usr/bin/python3 /usr/bin/python

wget https://raw.githubusercontent.com/scopatz/nanorc/master/install.sh -O- | sh

# sudo wget -q https://download.ceph.com/rpm-squid/el9/noarch/cephadm -O /usr/bin/cephadm && sudo chmod +x /usr/bin/cephadm
cephadm add-repo --release squid

# successor to jq
sudo wget -q https://github.com/mikefarah/yq/releases/latest/download/yq_linux_amd64 -O /usr/bin/yq && sudo chmod +x /usr/bin/yq
