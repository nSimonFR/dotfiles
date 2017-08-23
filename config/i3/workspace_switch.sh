#!/bin/sh
# By nSimon <nsimon@protonmail.com> - Free to use
# Simple script to launch programs when switching workspace on i3
# You will need i3subscribe, available at:
# https://raw.githubusercontent.com/Airblader/dotfiles-manjaro/master/.i3/i3subscribe

i3subscribe workspace | grep --line-buffered focus | while read -r line; do
  NUMBER=`i3-msg -t get_workspaces | jq '.[] | select(.focused==true).name' | cut -d"\"" -f2 | cut -d":" -f1`
  case $NUMBER in
    "1")
      program="rambox";;
    "2")
      program="firefox";;
    "3")
      program="urxvt";;
    "8")
      program="nautilus";;
    "*")
      continue;;
  esac
  if ! pgrep -x "$program" > /dev/null; then
    exec "$program" &
  fi
done
