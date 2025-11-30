#!/usr/bin/env bash

set -euo pipefail

sudo dnf install -y stow age

FROZEN_DIR="${HOME}/environment/fedora-sway-spin/setup"

for file in ${FROZEN_DIR}/0*.sh;
do
  . $file
done

