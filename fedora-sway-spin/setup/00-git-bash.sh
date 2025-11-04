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

cat > "${HOME}/.bash_aliases" <<EOF
#!/usr/bin/env bash
for file in "\${HOME}"/.config/bash_aliases/*.sh;
do
  . "\$file"
done
EOF

FROZEN_DIR="${HOME}/environment/fedora-sway-spin/setup/ssh"
SSH_DIR="${HOME}/.ssh"

echo "Setting up SSH keys"

mkdir -p "$SSH_DIR"

if [ ! -f "${SSH_DIR}/id_rsa" ]; then
    cp ${FROZEN_DIR}/id_rsa.pub ${SSH_DIR}/id_rsa.pub
    sudo dnf install -y age
    age --decrypt -o ${SSH_DIR}/id_rsa ${FROZEN_DIR}/id_rsa.age
    chmod 400 ${SSH_DIR}/id_rsa
fi

echo "Changing .git origin to ssh"
git remote set-url origin "ssh://git@github.com/ndelucca/environment.git"
