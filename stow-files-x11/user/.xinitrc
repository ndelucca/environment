#!/bin/sh

# Merge X resources
if [ -f ~/.Xresources ]; then
    xrdb -merge ~/.Xresources
fi

# Start i3 window manager
exec i3
