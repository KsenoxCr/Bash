#!/bin/bash

# Guard against too many arguments
if [[ $# -gt 1 ]]; then
  echo "Usage: nightly_backup.sh [-s](opt)" >&2
  exit 1
fi

# Check for optional -s flag
schedule_shutdown=false
if [[ $# -eq 1 ]]; then
  if [[ "$1" == "-s" ]]; then
    schedule_shutdown=true
  else
    echo "Usage: nightly_backup.sh [-s](opt)" >&2
    exit 1
  fi
fi

push_to_repos() {
  repo_paths=(
    "$HOME/scripting/bash"
    "$HOME/gods_plan"
    "$HOME/templates"
    "$HOME/.dotfiles"
    "$HOME/.config/nvim"
    "$HOME/ai_prompt_library"
  )

  cd "${repo_paths[0]}" || {
    echo "Error: Cannot change directory to ${repo_paths[0]}" >&2
    exit 1
  }

  timeout 10 git ls-remote --exit-code origin HEAD >/dev/null 2>&1

  if [[ $? -ne 0 ]]; then
    echo "Error: Cannot reach remote repository. Exiting." >&2
    exit 1
  fi

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
}

create_system_backup() {
  local backup_dir="$HOME/system_backups"

  if [[ ! -d "$backup_dir" ]]; then
    echo "Creating backup directory: $backup_dir"
    mkdir -p "$backup_dir"
  fi

  local timestamp=$(date +%Y-%m-%d_%H-%M-%S)
  local backup_file="$backup_dir/${timestamp}_system_backup.img"

  echo "Starting filesystem backup to: $backup_file"

  # TODO: find block device path, not root dir

  root_dev_path=$(lsblk -J -o NAME,MOUNTPOINT | jq -r '.blockdevices[] | .children?[] | select(.mountpoint=="/") | .name' 2> /dev/null)

  dd if="${root_dev_path}" of="$backup_file" bs=4M status=progress 2>&1

  if [[ $? -eq 0 ]]; then
    echo "Backup completed successfully: $backup_file"
  else
    echo "Error: Backup failed" >&2
    return 1
  fi
}

cleanup_old_backups() {
  local backup_dir="$HOME/system_backups"
  local max_backups=5

  if [[ ! -d "$backup_dir" ]]; then
    echo "Backup directory does not exist: $backup_dir"
    return 0
  fi

  local file_count=$(find "$backup_dir" -maxdepth 1 -type f -name "*_system_backup.img" | wc -l)

  if [[ $file_count -gt $max_backups ]]; then
    local excess=$((file_count - max_backups))
    echo "Found $file_count backups. Removing $excess oldest files..."

    # WTF?

    find "$backup_dir" -maxdepth 1 -type f -name "*_system_backup.img" -printf '%T@ %p\n' | sort -n | head -n $excess | cut -d' ' -f2- | while read file; do
      echo "Removing: $file"
      rm "$file"
    done
  else
    echo "Backup count is within limits: $file_count/$max_backups"
  fi
}

push_to_repos
create_system_backup
cleanup_old_backups

# Schedule shutdown if -s flag was used
if [[ "$schedule_shutdown" == true ]]; then
  echo "Scheduling system shutdown..."
  shutdown -h +1 "System shutdown scheduled after backup completion"
fi
