#!/usr/bin/env bash

WORKFLOW_DIR="$HOME/work/scripting/bash/workflows"
workflow="$1"
[[ ! -f "$WORKFLOW_DIR/$workflow.json" ]] && echo "Workflow not found" && exit 1

active_pid=$(hyprctl activewindow -j | jq -r '.pid')
hyprctl clients -j | jq -r --argjson pid "$active_pid" '.[] | select(.pid != $pid) | .pid' | xargs kill

jq -c '.windows[]' "$WORKFLOW_DIR/$workflow.json" | while read -r item; do
    cmd=$(jq -r '.command' <<< "$item")
    args=$(jq -r '.args // empty' <<< "$item")
    workspace=$(jq -r '.workspace // empty' <<< "$item")

    [[ -n "$workspace" ]] && dispatch="[workspace $workspace silent] $cmd"
    [[ -n "$args" ]] && dispatch="$dispatch $args"
    hyprctl dispatch exec "$dispatch"
done

jq -c '.current[]' "$WORKFLOW_DIR/$workflow.json" | while read -r item; do
    cmd=$(jq -r '.command' <<< "$item")
    args=$(jq -r '.args // empty' <<< "$item")

    [[ -n "$args" ]] && cmd="$cmd $args"
    eval "$cmd"
done

wait
