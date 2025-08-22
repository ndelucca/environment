#!/usr/bin/env bash

set -euo pipefail

manage-installers() {
    SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

    for file in "${SCRIPT_DIR}"/system/*.sh;
    do
        if [[ ! "$file" =~ nvim\.sh$ ]]; then
            . "$file"
        fi
    done

    for file in "${SCRIPT_DIR}"/user/*.sh;
    do
        . "$file"
    done
}
manage-installers "$@"
