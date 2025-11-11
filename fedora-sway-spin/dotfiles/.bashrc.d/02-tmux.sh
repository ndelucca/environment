#!/usr/bin/env bash

# If not running interactively, don't do anything.
[[ $- != *i* ]] && return

# If bash's version is bad don't do anything.
((BASH_VERSINFO[0] < 4)) && return

# Return if not the terminal cannot use colors.
[[ ! "${TERM}" =~ foot ]] && return

if command -v tmux &>>/dev/null \
    && [[ ! "${TERM}" =~ screen ]] \
    && [[ ! "${TERM}" =~ tmux ]] \
    && [[ -z "${TMUX}" ]]; then
    # Tell tmux to assume 256 colors with the -2 option.
    ASSUME_256_COLOR="-2"
    exec tmux ${ASSUME_256_COLOR} new-session -A -s forest
fi
