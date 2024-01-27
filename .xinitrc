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
#togglecaps
# setxkbmap -option ctrl:swapcaps
xmodmap $HOME/.dotfiles/kdblayouts/normal
xmodmap $HOME/.dotfiles/kbdlayouts/ctrlcapsswap 
xrdb .Xresources
xset r rate 300 30
backlightctrl -set 10
gpgconf -K gpg-agent
restartsearxng &
xss-lock slock &
pipewire &
mpd &
dunst &
if [ -z "$WINDOWMANAGER" ] || [ "$WINDOWMANAGER" = "d" ] ; then
    gpg-agent --daemon
    slstatus &
    restartemacs >/dev/null &
    exec dbus-run-session dwm
else
    slstatus-bar &
    gpg-agent --options ~/.gnupg/gpg-agent-exwm.conf --daemon
    pkill -x emacs
    exec dbus-run-session emacs -mm --debug-init
fi

