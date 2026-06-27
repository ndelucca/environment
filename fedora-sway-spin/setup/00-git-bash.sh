#!/usr/bin/env bash

set -euo pipefail

# shellcheck source=../vars.sh
source "$(dirname "${BASH_SOURCE[0]}")/../vars.sh"   # provides REPO_DIR, GIT_NAME, GIT_EMAIL, GITHUB_USER

sudo git config --system user.name "${GIT_NAME}"
sudo git config --system user.email "${GIT_EMAIL}"
sudo git config --system pull.rebase true
sudo git config --system push.default simple
sudo git config --system core.autocrlf false
sudo git config --system core.commentchar ";"
sudo git config --system color.ui true
sudo git config --system alias.st status

echo "Changing .git origin to ssh"
git -C "${REPO_DIR}" remote set-url origin "ssh://git@github.com/${GITHUB_USER}/$(basename "${REPO_DIR}").git"
