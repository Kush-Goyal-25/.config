#!/usr/bin/env nu 

COLORSCHEME=DoomOne

### AUTOSTART PROGRAMS ###
lxsession &
picom &
nm-applet &
# $"($env.HOME)/.screenlayout/layout.sh" &
sleep 1
blueman-applet &
volctl &
# conky -c "$HOME"/.config/conky/qtile/01/"$COLORSCHEME".conf || echo "Couldn't start conky."

### UNCOMMENT ONLY ONE OF THE FOLLOWING THREE OPTIONS! ###
# 1. Uncomment to restore last saved wallpaper
# xargs xwallpaper --stretch < ~/.cache/wall &
# 2. Uncomment to set a random wallpaper on login
# find /usr/share/backgrounds/dtos-backgrounds/ -type f | shuf -n 1 | xargs xwallpaper --stretch &
# 3. Uncomment to set wallpaper with nitrogen
nitrogen --restore &
xrandr --output Virtual-1 --mode 1920x1080 &
kanata -c config.kbd &
