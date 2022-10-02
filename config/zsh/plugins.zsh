source ${0:a:h}/setopt.zsh
source ${0:a:h}/exports.zsh
source ${0:a:h}/zsh-autosuggestions/zsh-autosuggestions.zsh
source ${0:a:h}/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
source ${0:a:h}/zsh-history-substring-search.zsh
source ${0:a:h}/prompt.zsh
source ${0:a:h}/z.sh
source ${0:a:h}/dc.zsh
#source ${0:a:h}/ssh-agent.zsh
source ${0:a:h}/gpg-agent.zsh
source ${0:a:h}/docker-agent.zsh
source ${0:a:h}/zsh_hooks.zsh
source ${0:a:h}/colors.zsh
source ${0:a:h}/completion.zsh
source ${0:a:h}/history.zsh
source ${0:a:h}/functions.zsh
source ${0:a:h}/trusk.zsh
source ${0:a:h}/aliases.zsh
source ${0:a:h}/bindkeys.zsh
test -e "${HOME}/.iterm2_shell_integration.zsh" && source "${HOME}/.iterm2_shell_integration.zsh"
[[ -f ~/.config/tabtab/__tabtab.zsh ]] && source ~/.config/tabtab/__tabtab.zsh || true
[ -s ~/.fig/fig.sh ] && source ~/.fig/fig.sh
