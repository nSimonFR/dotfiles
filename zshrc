export DISPLAY=:0
bootstrap.sh &>> /dev/null

export GOPATH=$HOME/.go
export PATH=/opt/anaconda/bin:$PATH
export GTK2_RC_FILES=~/.themes/Radiations/gtk-2.0/gtkrc

source ~/.config/zsh/zsh-autosuggestions/zsh-autosuggestions.zsh
source ~/.config/zsh/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
source ~/.config/zsh/prompt.zsh

sup() {
	su -c "$*"
}

random_file() {
	find ${*:-.} -type f | shuf | head -n 1
}

cd() {
	builtin cd "$@" && ls
}

mv() {
	if git rev-parse --is-inside-work-tree &>/dev/null; then
		if ! git mv $* 2> /dev/null; then
			/bin/mv $*
		fi
	else
		/bin/mv $*
	fi
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

loki() {
	ssh loki -t "tmux a -t ${1:-'0'} || tmux new -s ${1:-'0'} 'env ZDOTDIR=/etc/zsh zsh'"
}

g() {
	if [ $# -eq 0 ]; then
		git status
	elif [ $1 = "clone" ]; then
		URL=`echo "$2" | sed "s/http.*:\/\/github.com\/\(.*\)/git@github.com:\1/g"`
		echo "Cloning $URL"
		git clone "$URL" $3
	else
		git $*
	fi
}

alias v="nvim"
alias tmux="tmux -2"
alias git="g "
alias sudo="sup"
alias jupy="ssh -L 127.0.0.1:8888:127.0.0.1:8888 nsimon -t -x \"tmux a -t jupyter || tmux new -s jupyter 'jupyter-notebook'\""
alias pipupdate="su -c \"pip freeze --local | grep -v '^\-e' | cut -d = -f 1	| xargs -n1 pip install -U \" "
