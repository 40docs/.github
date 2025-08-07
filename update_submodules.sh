#!/usr/bin/env bash
set -euo pipefail

ORG="40docs"
GITMODULES_FILE=".gitmodules"
LOCK_FILE=".gitmodules.lock"

# Determine the current repo name
if [[ -n "${GITHUB_REPOSITORY:-}" ]]; then
  CURRENT_REPO="$(basename "$GITHUB_REPOSITORY")"
else
  if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    CURRENT_REPO=$(basename "$(git remote get-url origin | sed -E 's|\.git$||' | sed -E 's|.*/||')")
  else
    echo "❌ Error: Must be run inside a GitHub Action or a git repository."
    exit 1
  fi
fi

echo "🔁 Generating .gitmodules (excluding: $CURRENT_REPO)"
echo "" > "$GITMODULES_FILE"

# Get all repo names from the org
REPOS=()
while IFS= read -r repo; do
  REPOS+=("$repo")
done < <(gh repo list "$ORG" --limit 1000 --json name -q '.[].name')

# Create .gitmodules entries and submodule adds
for REPO in "${REPOS[@]}"; do
  if [[ "$REPO" == "$CURRENT_REPO" ]]; then
    continue
  fi

  echo "🔗 Adding submodule for $REPO"
  cat >> "$GITMODULES_FILE" <<EOF
[submodule "$REPO"]
	path = $REPO
	url = https://github.com/$ORG/$REPO.git
	branch = main

EOF

  # Add the submodule if not already present
  if [[ ! -d "$REPO/.git" && ! -e "$REPO" ]]; then
    git submodule add -b main "https://github.com/$ORG/$REPO.git" "$REPO" || true
  fi
done

# Sync & update
echo "🔄 Syncing submodules..."
git submodule sync
git submodule update --init --recursive

# Write lock file
date > "$LOCK_FILE"
echo "✅ .gitmodules updated and submodules initialized."

