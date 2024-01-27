#!/bin/bash

# This file is sourced by bash for login shells.  The following line
# runs your .bashrc and is recommended by the bash info pages.
if [[ -f ~/.bashrc ]] ; then
    . ~/.bashrc
fi

export LESSHISTFILE="-"
export CARGO_HOME="$HOME/.local/share/cargo"
export XCURSOR_THEME="Adwaita"
export LC_COLLATE="C"
# Custom scripts
export PATH="$PATH:$HOME/.dotfiles/scripts:$HOME/.local/share/cargo/bin"
export SUDO_ASKPASS="$HOME/.dotfiles/scripts/dmenupass"
export ANDROID_HOME="$HOME/Android/Sdk"

if [[ -t 0 && $(tty) == /dev/tty1 && ! $DISPLAY ]]; then
    read -p "dwm or exwm: " hello
    hello=$(printf %.1s "$hello")
    hello=$(echo "$hello" | tr '[:upper:]' '[:lower:]')
    export WINDOWMANAGER="$hello"
    exec startx
fi
