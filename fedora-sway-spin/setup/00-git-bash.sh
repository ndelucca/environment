#!/usr/bin/env bash

set -euo pipefail

sudo git config --system user.name "ndelucca"
sudo git config --system user.email "ndelucca@protonmail.com"
sudo git config --system pull.rebase true
sudo git config --system alias.st status

cat > "${HOME}/.bash_aliases" <<EOF
#!/usr/bin/env bash
for file in "\${HOME}"/.config/bash_aliases/*.sh;
do
  . "\$file"
done
EOF

