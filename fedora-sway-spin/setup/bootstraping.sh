#!/usr/bin/env bash

set -euo pipefail

FROZEN_DIR="${HOME}/environment/fedora-sway-spin/setup"

for file in ${FROZEN_DIR}/0*.sh;
do
  . $file
done

