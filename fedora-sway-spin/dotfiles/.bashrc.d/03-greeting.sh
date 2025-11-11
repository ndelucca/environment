#!/usr/bin/env bash

# Run direnv hooks
eval "$(direnv hook bash)"

/usr/bin/fortune | /usr/bin/cowsay -pn
