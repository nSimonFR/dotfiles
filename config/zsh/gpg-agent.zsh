# Enable gpg-agent if it is not running
GPG_AGENT_SOCKET="$(gpgconf --list-dirs agent-ssh-socket)"
if [ ! -S $GPG_AGENT_SOCKET ]; then
  gpg-agent --daemon #>/dev/null 2>&1
  export GPG_TTY=$(tty)
fi
