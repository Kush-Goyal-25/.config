#!/usr/bin/env bash

export COLORSCHEME="DoomOne"

### AUTOSTART PROGRAMS ###

lxsession &
picom &
# nm-applet &
sleep 1
blueman-applet &
volctl &

sudo /usr/bin/kanata -c ~/.config/kanata/config.kbd &

### Wallpaper & Display ###
nitrogen --restore &
xrandr --output Virtual-1 --mode 1920x1080 &

firefox &
zen-browser &

feh --bg-scale ~/.config/qtile/wallhaven-q21vkl.jpg
