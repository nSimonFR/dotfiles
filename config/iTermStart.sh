#!/bin/sh

osascript &>/dev/null <<EOF
  tell application "iTerm2"
    create window with default profile
  end tell
EOF
