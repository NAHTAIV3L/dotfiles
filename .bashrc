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

# turn on infinate history
export HISTSIZE=""

alias ls="ls --color=auto"
alias grep="grep --color=auto"
alias n="ncmpcpp -q"
alias b="bluetoothctl"
alias v="nvim"
alias xi="doas xbps-install"
alias xr="doas xbps-remove"
alias xq="xbps-query"
alias xpkg="xbps-query -Rs '' | fzf"

alias sdwm="cd ~/.dotfiles/suckless/dwm"
alias sst="cd ~/.dotfiles/suckless/st"
alias sslock="cd ~/.dotfiles/suckless/slock"
alias sslstatus="cd ~/.dotfiles/suckless/slstatus"
alias sdmenu="cd ~/.dotfiles/suckless/dmenu"
alias nvimconf="cd ~/.config/nvim ; nvim . ; cd - >/dev/null"
alias regen-mandb="doas makewhatis /usr/share/man"
