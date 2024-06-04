#!/bin/sh

# Install of Rancher on Ubuntu 16.04

# Prepare installation
sudo apt-get remove docker docker.io docker-engine
sudo apt-get update
sudo apt-get install -y apt-transport-https ca-certificates curl software-properties-common

# Install docker (Rancher support and best compatibility for Kubernetes)
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo apt-key fingerprint 0EBFCD88
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
sudo apt-get update
sudo apt-get install -y docker-ce

# Install docker compose
# You can update the release version (https://github.com/docker/compose/releases)
curl -L https://github.com/docker/compose/releases/download/1.19.0/docker-compose-`uname -s`-`uname -m` -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose

# Launch docker on boot
sudo systemctl enable docker

# Install and start the Rancher container
sudo docker run -d --restart=unless-stopped -p 80:8080 rancher/server:stable

# Use `docker logs -f <CONTAINER_ID>` to tail the container logs and see the installation progress
# When the installation is completed, access the Rancher Web interface at http://<SERVER_IP>
