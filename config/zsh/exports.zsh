export TERM=xterm-256color
export EDITOR='vim'

export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8

export GPG_TTY=$(tty)
export LC_COLLATE=C

export THEOS=/opt/theos
export THEOS_DEVICE_IP=nphone
export THEOS_DEVICE_PORT=22

export ANDROID_HOME=$HOME/Library/Android/sdk
export REACT_DEBUGGER="open -g 'rndebugger://set-debugger-loc?port=8081' ||"
export LESS='--ignore-case --raw-control-chars'
export PAGER='less'
export VSCODE_CONFIG_DIR="$HOME/Library/Application Support/VSCodium/User"

export HUSKY=0
export CLICOLOR=1
export LSCOLORS=Gxfxcxdxbxegedabagacad
export GREP_OPTIONS='--color=auto'
export GREP_COLOR='3;33'

export ZSH_AUTOSUGGEST_BUFFER_MAX_SIZE=50
export ZSH_AUTOSUGGEST_MANUAL_REBIND=1

export PATH=$PATH:node_modules/.bin
export PATH=$PATH:/usr/local/sbin
export PATH=$PATH:/usr/local/bin
export PATH=$PATH:/usr/local/share/npm/bin
export PATH=$PATH:~/.cabal/bin
export PATH=$PATH:~/.local/bin
export PATH=$PATH:/opt/boxen/homebrew/opt/go/libexec/bin
export PATH=$PATH:/usr/local/opt/yq@3/bin
export PATH=$PATH:/usr/local/opt/ansible@2.9/bin
export PATH=$PATH:/usr/local/opt/gnu-sed/libexec/gnubin
export PATH=$PATH:/usr/local/opt/python/libexec/bin
export PATH=$PATH:$ANDROID_HOME/emulator
export PATH=$PATH:$ANDROID_HOME/tools
export PATH=$PATH:$ANDROID_HOME/platform-tools
export PATH=$PATH:$THEOS/bin
export PATH=$PATH:~/.cargo/bin
export PATH="/usr/local/opt/ansible@2.9/bin:$PATH"
export PYTHONPATH=/usr/local/lib/python2.6/site-packages

export SSH_AUTH_SOCK=~/Library/Group\ Containers/2BUA8C4S2C.com.1password/t/agent.sock
