#!/usr/bin/env bash

. /usr/share/bash-completion/completions/git

# Run direnv hooks
eval "$(direnv hook bash)"

/usr/bin/fortune | /usr/bin/cowsay -pn
