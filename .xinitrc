#!/bin/sh
# togglecaps
# xset r rate 300 50
# xbacklight -set 10
# slstatus &
# xss-lock slock &
# dunst &
# restartemacs >/dev/null &
# exec dwm
#exec emacs
togglecaps
xset r rate 300 30
backlightctrl -set 10
gpgconf -K gpg-agent
xss-lock slock &
pipewire &
mpd &
dunst &
if [ -z "$WINDOWMANAGER" ] || [ "$WINDOWMANAGER" = "d" ] ; then
    gpg-agent --daemon
    slstatus &
    restartemacs >/dev/null &
    exec dwm
else
    gpg-agent --options ~/.gnupg/gpg-agent-exwm.conf --daemon
    pkill -x emacs
    exec emacs -mm --debug-init
fi

