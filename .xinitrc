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
#!/bin/bash
togglecaps
# feh --bg-center /home/nahtaiv3l/Downloads/Images/a9011ed3e03219a4c26d62d4aa606a0f-2497059860
# xcompmgr &
xset r rate 300 30
backlightctrl -set 10
gpgconf -K gpg-agent
xss-lock slock &
mpd &
dunst &
echo "1:$1"
echo "2:$2"
echo "3:$3"
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

