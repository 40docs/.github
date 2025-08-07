#!/usr/bin/env bash
set -euo pipefail

echo "🔁 Syncing all submodules to 'main' branch..."

# Loop over each initialized submodule
git submodule foreach '
  echo "🛠 Switching to main in $name"
  git fetch origin main
  if git show-ref --verify --quiet refs/heads/main; then
    git checkout main
  else
    git checkout -b main origin/main
  fi
  git pull origin main
'

echo "✅ All submodules are now on main and updated."

