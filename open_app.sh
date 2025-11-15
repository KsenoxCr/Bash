#!/bin/bash

declare -A commands=(
    ["dolphin"]="dolphin"
    ["Bitwarden"]="bitwarden-desktop"
    ["obsidian"]="obsidian"
    ["brave-browser"]="brave"
    ["chromium"]="chromium"
    ["firefox"]="firefox https://aistudio.google.com/prompts/new_chat"
    ["thunderbird"]="thunderbird"
    ["org.kde.CrowTranslate"]="crow"
    ["discord"]="discord"
)

class="$1"
[[ -z "$class" ]] && { echo "Usage: $0 <window_class>"; exit 1; }
[[ -z "${commands[$class]}" ]] && { echo "Unknown class: $class"; exit 1; }

open_app=$(hyprctl clients -j | jq -r --arg class "$class" '[.[] | select(.class == $class)] | sort_by(.focusHistoryID) | reverse | .[0].address // empty')

if [[ -n "$open_app" ]]; then
    hyprctl dispatch focuswindow "address:$open_app"
else
    eval "${commands[$class]}" &
fi
