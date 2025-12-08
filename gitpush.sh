#!/bin/bash

# timeout 10 git ls-remote --exit-code origin HEAD >/dev/null 2>&1

if [[ $? -ne 0 ]]; then
  echo "Error: Cannot reach remote repository. Exiting." >&2
  exit 1
fi

repo_paths=(
  "$HOME/scripting/bash"
  "$HOME/gods_plan"
  "$HOME/templates"
  "$HOME/.dotfiles"
  "$HOME/.config/nvim"
  "$HOME/ai_prompt_library"
)

commit_msg="${1:-Auto-commit $(date +%Y-%m-%d_%H:%M:%S)}"

for repo in "${repo_paths[@]}"; do
  if [[ -d "$repo/.git" ]]; then
    echo "Processing: $repo"
    cd "$repo" || continue

    git add -A > /dev/null
 
    if git diff --cached --quiet; then
      echo "  No changes"
    else
      git commit -m "$commit_msg" > /dev/null

      echo "$repo: Pushing changes..."

      git push &> /dev/null

      if [[ $? -eq 0 ]]; then
        echo "  Push successful"
      else
        echo "  Error: Push failed for $repo" >&2
      fi
    fi
  else
    echo "Warning: $repo is not a git repository" >&2
  fi
done
