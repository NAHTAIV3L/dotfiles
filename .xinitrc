#!/bin/sh
# togglecaps
# xset r rate 300 50
# xbacklight -set 10
# slstatus & disown
# xss-lock slock & disown
# dunst & disown
# restartemacs >/dev/null & disown
# exec dwm
#exec emacs
#!/bin/bash
togglecaps
xset r rate 300 50
xbacklight -set 10
xss-lock slock & disown
dunst & disown
if [ -z "$WINDOWMANAGER" ] || [ "$WINDOWMANAGER" = "d" ] ; then
    slstatus & disown
    restartemacs >/dev/null & disown
    exec dwm
else
    pkill -x emacs
    exec emacs -mm --debug-init
fi

