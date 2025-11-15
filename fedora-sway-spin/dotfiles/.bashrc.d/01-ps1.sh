#!/usr/bin/env bash

# If not running interactively, don't do anything.
[[ $- != *i* ]] && return

# SHELL OPTIONS
{

    # Prepend cd to directory names automatically.
    shopt -s autocd

    # Correct spelling errors during tab-completion.
    shopt -s dirspell

    # Correct spelling errors in arguments supplied to cd.
    shopt -s cdspell

    # Turn on recursive globbing (enables ** to recurse all directories).
    shopt -s globstar

    # Update window size after every command.
    shopt -s checkwinsize

    # Append to the history file, don't overwrite.
    shopt -s histappend

    # Save multi-line commands as one command in the history.
    shopt -s cmdhist

} &>>/dev/null

# Enable history expansion with space
# E.g. typing !!<space> will replace the !! with your last command.
bind Space:magic-space

# Perform file completion in a case insensitive fashion.
bind "set completion-ignore-case on"

# Display matches for ambiguous patterns at first tab press.
bind "set show-all-if-ambiguous on"
bind "set show-all-if-unmodified on"

# Immediately add a trailing slash when autocompleting symlinks to directories.
bind "set mark-symlinked-directories on"

# Prettier completitions
bind "set colored-stats on"
bind "set colored-completion-prefix on"
bind "set visible-stats on"
# The maximum length in characters of the common prefix of a list of possible completions that is displayed without modification.
bind "set completion-prefix-display-length 7"

# PS1
source "${HOME}/.bashrc.d/git_prompt.sh"

export GIT_PS1_SHOWCOLORHINTS=true
export GIT_PS1_SHOWDIRTYSTATE=true
export GIT_PS1_SHOWSTASHSTATE=true
export GIT_PS1_SHOWUNTRACKEDFILES=true
export GIT_PS1_SHOWUPSTREAM=verbose

T_STYLE=0
T_MAIN_COLOR="38;2;74;157;74"
T_SECONDARY_COLOR="38;2;108;182;108"

C_RUTA="\[\033[${T_STYLE};${T_MAIN_COLOR}m\]"
C_SIMB="\[\033[${T_STYLE};${T_MAIN_COLOR}m\]"
C_GITB="\[\033[${T_STYLE};${T_SECONDARY_COLOR}m\]"
M_END="\[\033[m\]"

RUTA="${C_RUTA}\w${M_END}"
FIRSTLINE="${C_RUTA}>\n${M_END}"
SIMB="${C_SIMB}☯${M_END}"

GITB="${C_GITB}\`__git_ps1\`${M_END}"

export GIT_SSH_COMMAND="ssh -i ~/.ssh/id_rsa"

# Use PROMPT_COMMAND (not PS1) to get color output (see git-prompt.sh for more)
export PROMPT_COMMAND="__git_ps1 \"${RUTA}\" \"${FIRSTLINE}${SIMB} \""
export PS1=''

# HISTORY

# Append to history after finishing any command.
export PROMPT_COMMAND="${PROMPT_COMMAND}; history -a;"

# Automatically trim long paths in the prompt.
export PROMPT_DIRTRIM=2

# Big history.
export HISTSIZE=500000
export HISTFILESIZE=100000

# Avoid duplicate entries.
export HISTCONTROL="erasedups:ignoreboth"

# Don't record some commands.
export HISTIGNORE="exit:ls:history:clear:pwd"

# Use standard ISO 8601 timestamp
# %F equivalent to %Y-%m-%d
# %T equivalent to %H:%M:%S (24-hours format)
export HISTTIMEFORMAT='%F %T '

