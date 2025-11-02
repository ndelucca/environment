#!/usr/bin/bash

set -e

echo "Installing nginx"
sudo apt update
sudo apt install nginx

echo "Installing mkcert"
sudo apt install libnss3-tools

curl -JLO "https://dl.filippo.io/mkcert/latest?for=linux/amd64"
chmod +x mkcert-v*-linux-amd64
sudo mv mkcert-v*-linux-amd64 /usr/local/bin/mkcert

mkcert -install

echo "Ready to run mkcert localhost"
