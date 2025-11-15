#!/bin/bash

DIR="$HOME/work/ai_prompts"

if [ -z "$ROFI_RETV" ] || [ "$ROFI_RETV" -eq 0 ]; then
    find "$DIR" -type f -printf '%f\n'
    exit 0
fi

FILENAME="$DIR/$1"
if [[ -f "$FILENAME" ]]; then
    cat "$FILENAME" | wl-copy
fi
