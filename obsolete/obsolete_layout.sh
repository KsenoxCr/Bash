#!/usr/bin/bash

# Check for exactly one argument
if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <fi|us>"
    exit 1
fi

# Use case statement for cleaner code
case "$1" in
    "fi")
        sed -i 's/kb_layout = us/kb_layout = fi/g' ~/.config/hypr/hyprland.conf > /dev/null
        ;;
    "us")
        sed -i 's/kb_layout = fi/kb_layout = us/g' ~/.config/hypr/hyprland.conf > /dev/null
        ;;
    *)
        echo "Error: Invalid argument. Please use 'fi' or 'us'."
        exit 1
        ;;
esac
