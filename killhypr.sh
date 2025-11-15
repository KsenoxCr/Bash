#!/bin/bash

hyprctl clients -j | jq -r '.[].pid' | xargs kill
