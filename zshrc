export PATH=/opt/anaconda/bin:$PATH 

source ~/.config/zsh/zsh-autosuggestions/zsh-autosuggestions.zsh
source ~/.config/zsh/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
source ~/.config/zsh/prompt.zsh

sup() {
	su -c "$*"
}

nsimon() {
	ssh neavend@$(curl -s dev.nsimon.fr/ip.html) -p 26 -i ~/.ssh/neavend_key
}

random_file() {
	find . -type f | shuf | head -n 1
}

cdd() {
	cd "$*" && ls
}

alias v="nvim"
alias tmux="tmux -2"
alias pipupdate="su -c \"pip freeze --local | grep -v '^\-e' | cut -d = -f 1  | xargs -n1 pip install -U\""
alias jupy="ssh -L 127.0.0.1:8888:127.0.0.1:8888 nsimon.fr -t -x 'jupyter-notebook'"
alias nsimon.fr="nsimon"
alias sudo="sup"

