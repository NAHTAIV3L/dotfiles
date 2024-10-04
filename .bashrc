# /etc/skel/.bashrc
#
# This file is sourced by all *interactive* bash shells on startup,
# including some apparently interactive shells such as scp and rcp
# that can't tolerate any output.  So make sure this doesn't display
# anything or bad things will happen !


# Test for an interactive shell.  There is no need to set anything
# past this point for scp and rcp, and it's important to refrain from
# outputting anything in those cases.
if [[ $- != *i* ]] ; then
    # Shell is non-interactive.  Be done now!
    return
fi

# disable ctrl-s and ctrl-q
stty -ixon

export PS1="[\[\033[00;32m\]\u@\h\[\033[00;36m\] \W\[\033[00m\]]$ "
# turn on infinite history
export HISTSIZE=""

#alias ls="ls --color=auto"
alias ls="eza"
alias grep="grep --color=auto"
alias n="ncmpcpp -q"
alias b="bluetoothctl"
alias e="emacsclient -c -a emacs"
alias emerge-log="doas tail -f /var/log/emerge-fetch.log"
