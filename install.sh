#!/bin/sh
# Updated by nSimon

dot_list="bashrc config emacs gitconfig gitignore mozilla msmtprc muttrc slrnrc ssh tmux.conf vimperatorrc vimrc Xdefaults zshrc"

for f in $dot_list; do
  rm -rf "$HOME/.$f"
  ln -s "$AFS_DIR/.confs/$f" "$HOME/.$f"
done

rmdir "$HOME/Desktop" 2>> /dev/null
ln -s "$AFS_DIR/Downloads" "$HOME/Downloads"
