#!/bin/bash

if [ "$#" -gt 1 ]; then
    echo "Usage: $0 <type>"
    echo "Available types: start, dev"
    exit 1
fi

active_pid=$(hyprctl activewindow -j | jq -r '.pid')

hyprctl clients -j | jq -r --argjson pid "$active_pid" '.[] | select(.pid != $pid) | .pid' | xargs kill

type="$1"

OpenDaysDiary() {
    day=$(date +"%Y-%m-%d")
    kitty nvim ~/Gods_Plan/$day.md &
    sleep 1 && hyprctl dispatch movetoworkspace 3 "kitty"
}

MoveToWorkspace() {
    local count=$1
    local class="$2"
    hyprctl clients -j | jq -r --arg class "$class" '.[] | select(.class==$class) | .address' | head -n $1 | xargs -I{} hyprctl dispatch movetoworkspace 2,address:{}
}

case "$type" in
    # Morning routine
    start)
        OpenDaysDiary
        firefox &
        chromium &
        brave-browser &
        obsidian &
        bitwarden &
        thunderbird &
        MoveToWorkspace 2 kitty
        sleep 0.3 && MoveToWorkspace 1 kitty
        ;;
    # Development setup
    *)
        kitty nvim ~/Gods_Plan/Brain_Ram.md &
        OpenDaysDiary
        firefox &
        waterfox &
        brave &
        obsidian &
        nvim ~/programming
        sleep 0.3 && MoveToWorkspace 2 kitty
        ;;
esac
