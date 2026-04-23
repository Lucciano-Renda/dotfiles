# If not running interactively, don't do anything (leave this at the top of this file)
[[ $- != *i* ]] && return

# All the default Omarchy aliases and functions
# (don't mess with these directly, just overwrite them here!)
source ~/.local/share/omarchy/default/bash/rc

# Add your own exports, aliases, and functions here.
#
# Make an alias for invoking commands you use constantly
# alias p='python'
#
alias arduino-ide='arduino-ide --no-sandbox --disable-gpu --ozone-platform=x11'

# Función para que Yazi cambie el directorio de la terminal al salir
function y() {
	local tmp="$(mktemp -t "yazi-cwd.XXXXXX")"
	yazi "$@" --cwd-file="$tmp"
	if cwd="$(command cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
		builtin cd -- "$cwd"
	fi
	rm -f -- "$tmp"
}

# rad's aliases
alias diff="diff --color=auto"
alias rm="rm -ri"
alias mv="mv -i"
alias nv="nvim"
alias df='df -h'
alias free='free -m'
alias ls="eza --icons"
alias ll="eza -lh --icons --git"
alias la="eza -lah --icons --git"
alias cat="bat"
alias -- -='cd -'
alias mkd="mkdir -p"
alias fuck="pacman -Rs"
alias cl="clear"
alias cd="z"

# Git Aliases
alias gpush="git push"
alias gpull="git pull --prune"
alias gc="git commit -m"
alias ga="git add ."
alias fixgit-to-ssh='git remote set-url origin git@github.com:$(git remote get-url origin | sed "s/.*github.com[\/:]//;s/\.git$//").git'

#????alias gadog='PAGER="less -F -X" git adog'
#????alias glog='PAGER="less -F -X" git log'

export PATH=$PATH:/home/luchho/.spicetify
