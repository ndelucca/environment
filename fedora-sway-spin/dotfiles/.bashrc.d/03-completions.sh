#!/usr/bin/env bash

[[ -f /usr/share/bash-completion/bash_completion ]] &&
    source /usr/share/bash-completion/bash_completion

[[ -f /usr/share/bash-completion/completions/git ]] &&
    source /usr/share/bash-completion/completions/git


# Run direnv hooks
eval "$(direnv hook bash)"

/usr/bin/fortune | /usr/bin/cowsay -pn
