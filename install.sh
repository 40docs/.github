#!/usr/bin/env bash
set -euo pipefail

ORG="40docs"
TARGET_DIR="$HOME/40docs"
GITMODULES_FILE=".gitmodules"
LOCK_FILE=".gitmodules.lock"

# Step 1: Ensure ~/40docs exists and is synced
if [[ -d "$TARGET_DIR/.git" ]]; then
  echo "📁 $TARGET_DIR exists. Updating existing repo..."
  cd "$TARGET_DIR"
  git pull origin main
  git submodule sync
  git submodule update --init --recursive
else
  echo "⬇️ Cloning https://github.com/$ORG/.github.git into $TARGET_DIR..."
  git clone --recurse-submodules "https://github.com/$ORG/.github.git" "$TARGET_DIR"
  cd "$TARGET_DIR"
fi

# Step 2: Determine current repo name
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

# Step 3: Generate .gitmodules
echo "🔁 Generating .gitmodules (excluding: $CURRENT_REPO)"
echo "" > "$GITMODULES_FILE"

# Step 4: Get all repo names from the org
REPOS=()
while IFS= read -r repo; do
  REPOS+=("$repo")
done < <(gh repo list "$ORG" --limit 1000 --json name -q '.[].name')

# Step 5: Add submodules and write to .gitmodules
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

# Step 6: Sync & update submodules
echo "🔄 Syncing and initializing submodules..."
git submodule sync
git submodule update --init --recursive

# Step 7: Ensure each submodule is tracking 'main'
for REPO in "${REPOS[@]}"; do
  if [[ "$REPO" == "$CURRENT_REPO" ]]; then
    continue
  fi

  if [[ -d "$REPO/.git" ]]; then
    echo "🛠  Ensuring '$REPO' is on 'main' branch..."
    (
      cd "$REPO"
      git fetch origin main
      if git show-ref --verify --quiet refs/heads/main; then
        git checkout main
      else
        git checkout -b main origin/main
      fi
      git pull origin main
    )
  fi
done

# Step 8: Write lock file
date > "$LOCK_FILE"
echo "✅ .gitmodules updated, submodules initialized, and all are on 'main'."

echo "🔁 Syncing all submodules to 'main' branch..."

# Ensure submodules are synced with the new .gitmodules before foreach
git submodule sync

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

