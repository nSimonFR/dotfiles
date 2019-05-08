# Environment variables
export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8
export ANDROID_HOME=$HOME/Library/Android/sdk
export PATH=/usr/local/opt/python/libexec/bin:$PATH
export PATH=$PATH:$ANDROID_HOME/emulator:$ANDROID_HOME/tools:$ANDROID_HOME/platform-tools
export PATH="$HOME/.yarn/bin:$HOME/.config/yarn/global/node_modules/.bin:$PATH"
export REACT_DEBUGGER="open -g 'rndebugger://set-debugger-loc?port=8081' ||"

# Functions
sup() {
	su -c "$*"
}
random_file() {
	find ${*:-.} -type f | shuf | head -n 1
}
extract () {
	if [ -f $1 ] ; then
		case $1 in
			*.tar.bz2)  tar xjf $1      ;;
			*.tar.gz)   tar xzf $1      ;;
			*.bz2)      bunzip2 $1      ;;
			*.rar)      rar x $1        ;;
			*.gz)       gunzip $1       ;;
			*.tar)      tar xf $1       ;;
			*.tbz2)     tar xjf $1      ;;
			*.tgz)      tar xzf $1      ;;
			*.zip)      unzip $1        ;;
			*.Z)        uncompress $1   ;;
			*)          echo "'$1' cannot be extracted via extract()" ;;
	esac
	else
		echo "'$1' is not a valid file"
	fi
}
g() {
	if [ $# -eq 0 ]; then
		git status
	else
		git $*
	fi
}
clip() {
	echo $* | xclip -selection clipboard
}
retry() {
	until $*; do
		sleep 1
	done
}

# Aliases
alias v="vim"
alias code="vscodium"
alias tmux="tmux -2"
alias pipupdate="su -c \"pip freeze --local | grep -v '^\-e' | cut -d = -f 1	| xargs -n1 pip install -U \" "

# External scripts and configurations
source ~/.config/zsh/plugins.zsh

# history-substring-search
bindkey "^[[A" history-substring-search-up
bindkey "^[[B" history-substring-search-down
bindkey -M vicmd 'k' history-substring-search-up
bindkey -M vicmd 'j' history-substring-search-down

# iterm integration
test -e "${HOME}/.iterm2_shell_integration.zsh" && source "${HOME}/.iterm2_shell_integration.zsh"

# docker machine integration
eval $(docker-machine env local 2&> /dev/null)
