fpath=(./completions $fpath)
fpath=(./zsh-completions/src $fpath)
source '/usr/local/Caskroom/google-cloud-sdk/latest/google-cloud-sdk/path.zsh.inc'
source '/usr/local/Caskroom/google-cloud-sdk/latest/google-cloud-sdk/completion.zsh.inc'
source /usr/local/share/zsh/site-functions
autoload -U compinit && compinit
