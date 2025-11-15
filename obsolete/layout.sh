#!/usr/bin/env bash

keyboard_name="moergo-glove81-left-keyboard"

current=$(hyprctl devices -j | jq -r --arg keyboard "$keyboard_name" \
    '.keyboards[] | select(.name == $keyboard) | .active_keymap')

if [[ "$current" == "English (US)" ]]; then
    hyprctl switchxkblayout "$keyboard_name" next
else
    hyprctl switchxkblayout "
    $keyboard_name" 0
fi
