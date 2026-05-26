#!/bin/bash

# This file is sourced by bash for login shells.  The following line
# runs your .bashrc and is recommended by the bash info pages.
if [[ -f ~/.bashrc ]] ; then
    . ~/.bashrc
fi


export LESSHISTFILE="-"
export CARGO_HOME="$HOME/.local/share/cargo"
export XCURSOR_THEME="Adwaita"
export PASSWORD_STORE_ENABLE_EXTENSIONS=true
export PASSWORD_STORE_EXTENSIONS_DIR=/usr/lib64/password-store/extensions/
export LC_COLLATE="C"
# Custom scripts
export PATH="$PATH:$HOME/.dotfiles/scripts:$HOME/.local/bin"

if [[ -t 0 && $(tty) == /dev/tty1 && ! $DISPLAY ]]; then
    # read -p "hyprland or dwl: "  -t 1 hello
    # hello=$(printf %.1s "$hello")
    # hello=$(echo "$hello" | tr '[:upper:]' '[:lower:]')
    # export WINDOWMANAGER="$hello"

    export _JAVA_AWT_WM_NONREPARENTING=1
    # if [ -z "$WINDOWMANAGER" ] || [ "$WINDOWMANAGER" = "d" ] ; then
    #     exec dbus-launch --exit-with-session dwl
    # else
        export XCURSOR_SIZE=24
        exec dbus-launch --exit-with-session mango
    # fi
fi
