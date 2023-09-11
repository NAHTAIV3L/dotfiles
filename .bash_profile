#!/bin/bash

# This file is sourced by bash for login shells.  The following line
# runs your .bashrc and is recommended by the bash info pages.
if [[ -f ~/.bashrc ]] ; then
    . ~/.bashrc
fi

export LESSHISTFILE="-"
export CARGO_HOME="$HOME/.local/share/cargo"
# Custom scripts
export PATH="$PATH:$HOME/.dotfiles/scripts:/opt/zoom:$HOME/.local/share/cargo/bin"
export SUDO_ASKPASS="$HOME/.dotfiles/scripts/dmenupass"

if [ "$(tty)" = "/dev/tty1" ]; then
    read -p "dwm or exwm: " hello
    hello=$(printf %.1s "$hello")
    hello=$(echo "$hello" | tr '[:upper:]' '[:lower:]')
    export WINDOWMANAGER="$hello"
    exec startx
fi
