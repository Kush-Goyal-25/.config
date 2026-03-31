#!/usr/bin/env bash

export COLORSCHEME="DoomOne"

### AUTOSTART PROGRAMS ###

lxsession &
# picom &
# nm-applet &
# sleep 1
# blueman-applet &
# volctl &

sudo /usr/bin/kanata -c ~/.config/kanata/config.kbd &

### Wallpaper & Display ###
nitrogen --restore &
# xrandr --output Virtual-1 --mode 1920x1080 &

xrandr --newmode "3840×2160" 243.75 2560 2728 3000 3440 1140 1143 1153 1183 -hsync +vsync &

firefox &
brave &
sleep 1
wezterm &
# sleep 1
# excalidraw &
# flameshot &
sleep 2
ticktick &

feh --bg-scale ~/.config/qtile/wallhaven-q21vkl.jpg
