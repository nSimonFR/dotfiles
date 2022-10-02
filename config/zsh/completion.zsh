fpath=(./completions $fpath)
fpath=(./zsh-completions/src $fpath)
FPATH=$(brew --prefix)/share/zsh/site-functions:$FPATH
source /usr/local/opt/git-extras/share/git-extras/git-extras-completion.zsh
source '/usr/local/Caskroom/google-cloud-sdk/latest/google-cloud-sdk/path.zsh.inc'
source '/usr/local/Caskroom/google-cloud-sdk/latest/google-cloud-sdk/completion.zsh.inc'
autoload -Uz compinit
compinit
