#!/bin/sh

IMG=`random_file ~/Pictures/Wallpapers/Stalenhag`
echo "Switching to $IMG.."
feh --bg-fill $IMG
schemer2 -format img::xterm -in $IMG -out ~/.Xresources
cat <<EOF >> ~/.Xresources
*font: xft:Hack-Regular:size=9, xft:FontAwesome:pixelsize=9, xft:SauceCodePro NF:pixelsize=9, xft:pango:size=10
URxvt.perl-ext-common: default,clipboard,config-reload
EOF
xrdb ~/.Xresources
i3-msg -s /tmp/i3.sock restart >/dev/null
