#!/usr/bin/env bash

set -e
set -x

export DEBIAN_FRONTEND=noninteractive

sudo apt-get update
sudo DEBIAN_FRONTEND=noninteractive apt-get upgrade -y

# Making sure we don't have any Docker installed here
sudo DEBIAN_FRONTEND=noninteractive apt-get remove -y docker docker-engine docker.io containerd runc || true

# Add Docker repo
sudo DEBIAN_FRONTEND=noninteractive apt-get install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg-agent \
    software-properties-common \
    curl

curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -

sudo add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"

sudo apt-get update
sudo DEBIAN_FRONTEND=noninteractive apt-get install -y docker-ce docker-ce-cli containerd.io
sudo DEBIAN_FRONTEND=noninteractive apt-get install -y nginx

# Clean apt cache
sudo DEBIAN_FRONTEND=noninteractive apt-get autoclean
sudo DEBIAN_FRONTEND=noninteractive apt-get clean

# Set up nginx config
sudo rm -f /etc/nginx/sites-enabled/default
sudo mv /tmp/nginx.conf /etc/nginx/sites-available/jenkins
sudo ln -s /etc/nginx/sites-available/jenkins /etc/nginx/sites-enabled/jenkins

sudo systemctl restart nginx

# set up docker service
sudo mkdir -p /opt/jenkins/data
sudo mv /tmp/docker-compose.yml /opt/jenkins
sudo mv /tmp/Dockerfile /opt/jenkins
sudo chown -R ubuntu:ubuntu /opt/jenkins


# download docker-compose
sudo curl -L https://github.com/docker/compose/releases/download/1.25.4/docker-compose-Linux-x86_64 -o /opt/jenkins/docker-compose
sudo chmod +x /opt/jenkins/docker-compose
