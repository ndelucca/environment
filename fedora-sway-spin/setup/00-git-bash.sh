#!/usr/bin/env bash

set -euo pipefail

sudo git config --system user.name "ndelucca"
sudo git config --system user.email "ndelucca@protonmail.com"
sudo git config --system pull.rebase true
sudo git config --system push.default simple
sudo git config --system core.autocrlf false
sudo git config --system core.commentchar ";"
sudo git config --system color.ui true
sudo git config --system alias.st status

echo "Changing .git origin to ssh"
git remote set-url origin "ssh://git@github.com/ndelucca/environment.git"
