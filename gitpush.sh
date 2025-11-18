#!/bin/bash

repo_paths=(
  # "$HOME/scripting/bash"
  "$HOME/gods_plan"
  "$HOME/templates"
)

commit_msg="${1:-Auto-commit $(date +%Y-%m-%d_%H:%M:%S)}"

for repo in "${repo_paths[@]}"; do
  if [[ -d "$repo/.git" ]]; then
    echo "Processing: $repo"
    cd "$repo" || continue
    
    git add -A
    
    if git diff --cached --quiet; then
      echo "  No changes"
    else
      git commit -m "$commit_msg"
      git push
    fi
  else
    echo "Warning: $repo is not a git repository" >&2
  fi
done
