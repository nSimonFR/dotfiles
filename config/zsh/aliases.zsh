alias ls='ls -GFh'
alias ll='ls -GFhl'

alias chrome='/Applications/Google\ Chrome.app/Contents/MacOS/Google\ Chrome --remote-debugging-port=9222'
alias v="vim"
alias tmux="tmux -2"
alias rake='noglob rake'
alias bower='noglob bower'

alias decrypt='mkdir -vp env/$ENV && rsync -av --delete env.encrypted/$ENV/ env/$ENV && find env/$ENV/ -type f -name "*.env" -exec sops -d -i {} \;'
alias encrypt='mkdir -vp env.encrypted/$ENV && rsync -av --delete env/$ENV/ env.encrypted/$ENV && find env.encrypted/$ENV/ -type f -name "*.env" -exec sops -e -i {} \;'

alias gc="git checkout"
alias greset="gc develop && g fetch && g rebase origin/develop"
alias pipupdate="su -c \"pip freeze --local | grep -v '^\-e' | cut -d = -f 1	| xargs -n1 pip install -U \" "

alias repo="gh repo view --web"
