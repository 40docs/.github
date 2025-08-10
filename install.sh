#!/usr/bin/env bash
set -euo pipefail

ORG="40docs"
TARGET_DIR="$HOME/40docs"
GITMODULES_FILE=".gitmodules"
LOCK_FILE=".gitmodules.lock"

# Function to check if gh is authenticated
check_gh_auth() {
  if command -v gh >/dev/null 2>&1; then
    if gh auth status >/dev/null 2>&1; then
      return 0
    fi
  fi
  return 1
}

# Function to get repos from existing directories as fallback
get_repos_from_directories() {
  local current_repo="$1"
  local repos=()
  
  echo "⚠️  GitHub CLI not authenticated. Using existing directories as fallback..."
  
  # Get all directories that could be submodules (exclude common non-repo dirs)
  while IFS= read -r dir; do
    # Skip current repo, hidden dirs, and common non-repo directories
    if [[ "$dir" != "$current_repo" && "$dir" != .* && "$dir" != "node_modules" ]]; then
      repos+=("$dir")
    fi
  done < <(find . -maxdepth 1 -type d -exec basename {} \; | grep -v '^\.$' | sort)
  
  # If we have few directories, add known repositories from the 40docs organization
  if [[ ${#repos[@]} -lt 10 ]]; then
    echo "ℹ️  Adding known repositories to supplement directory list..."
    local known_repos=(
      "az-decompile"
      "container-security-demo"
      "devcontainer-features"
      "devcontainer-templates"
      "docs-builder"
      "docs-forticnapp-code-security"
      "docs-forticnapp-opal-demo"
      "dotfiles"
      "fortiweb-ingress"
      "helm-charts"
      "hol-fortiappsec"
      "hydration"
      "infrastructure"
      "k8s-utilities"
      "lab-forticnapp-code-security"
      "lab-forticnapp-opal"
      "landing-page"
      "manifests-applications"
      "manifests-infrastructure"
      "mkdocs"
      "pebcak"
      "pptx-extractor-microservice"
      "profile"
      "references"
      "theme"
      "tts-microservices"
      "video-as-code"
      "video-producer-microservice"
      "webhook"
    )
    
    for repo in "${known_repos[@]}"; do
      if [[ "$repo" != "$current_repo" ]] && [[ ! " ${repos[*]} " =~ " $repo " ]]; then
        repos+=("$repo")
      fi
    done
  fi
  
  printf '%s\n' "${repos[@]}"
}

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

# Step 4: Get all repo names from the org (with fallback)
REPOS=()
if check_gh_auth; then
  echo "✅ GitHub CLI authenticated. Fetching repositories from GitHub API..."
  while IFS= read -r repo; do
    REPOS+=("$repo")
  done < <(gh repo list "$ORG" --limit 1000 --json name -q '.[].name')
else
  echo "🔄 Using fallback method to determine repositories..."
  while IFS= read -r repo; do
    REPOS+=("$repo")
  done < <(get_repos_from_directories "$CURRENT_REPO")
fi

# Validate that we have repositories to work with
if [[ ${#REPOS[@]} -eq 0 ]]; then
  echo "❌ Error: No repositories found. Either authenticate with 'gh auth login' or ensure directories exist."
  exit 1
fi

echo "ℹ️  Found ${#REPOS[@]} repositories to process"

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
    echo "➕ Adding new submodule: $REPO"
    if ! git submodule add -b main "https://github.com/$ORG/$REPO.git" "$REPO" 2>/dev/null; then
      echo "⚠️  Could not add submodule $REPO (may not exist or access denied)"
    fi
  fi
done

# Step 6: Sync & update submodules
echo "🔄 Syncing and initializing submodules..."
if ! git submodule sync 2>/dev/null; then
  echo "⚠️  Some submodules failed to sync"
fi

if ! git submodule update --init --recursive 2>/dev/null; then
  echo "⚠️  Some submodules failed to update"
fi

# Step 7: Ensure each submodule is tracking 'main'
for REPO in "${REPOS[@]}"; do
  if [[ "$REPO" == "$CURRENT_REPO" ]]; then
    continue
  fi

  if [[ -d "$REPO/.git" ]]; then
    echo "🛠  Ensuring '$REPO' is on 'main' branch..."
    (
      cd "$REPO"
      if git fetch origin main 2>/dev/null; then
        if git show-ref --verify --quiet refs/heads/main; then
          git checkout main 2>/dev/null || echo "⚠️  Could not checkout main in $REPO"
        else
          git checkout -b main origin/main 2>/dev/null || echo "⚠️  Could not create main branch in $REPO"
        fi
        git pull origin main 2>/dev/null || echo "⚠️  Could not pull main in $REPO"
      else
        echo "⚠️  Could not fetch from origin in $REPO"
      fi
    )
  fi
done

# Step 8: Write lock file
date > "$LOCK_FILE"
echo "✅ .gitmodules updated, submodules initialized, and all are on 'main'."

echo "🔁 Syncing all submodules to 'main' branch..."

# Ensure submodules are synced with the new .gitmodules before foreach
if ! git submodule sync 2>/dev/null; then
  echo "⚠️  Some submodules failed final sync"
fi

# Loop over each initialized submodule with better error handling
if git submodule foreach --quiet 'echo "$name"' >/dev/null 2>&1; then
  git submodule foreach '
    echo "🛠 Switching to main in $name"
    if git fetch origin main 2>/dev/null; then
      if git show-ref --verify --quiet refs/heads/main; then
        git checkout main 2>/dev/null || echo "⚠️  Could not checkout main in $name"
      else
        git checkout -b main origin/main 2>/dev/null || echo "⚠️  Could not create main branch in $name"
      fi
      git pull origin main 2>/dev/null || echo "⚠️  Could not pull main in $name"
    else
      echo "⚠️  Could not fetch from origin in $name"
    fi
  '
else
  echo "⚠️  No initialized submodules found for final sync"
fi

echo "✅ Submodule synchronization completed."

# Display summary
INITIALIZED_COUNT=$(git submodule status 2>/dev/null | wc -l || echo "0")
echo "📊 Summary: $INITIALIZED_COUNT submodules initialized"

if [[ $INITIALIZED_COUNT -gt 0 ]]; then
  echo "🔍 To authenticate with GitHub CLI for better functionality, run: gh auth login"
else
  echo "⚠️  No submodules were initialized. Check authentication or network connectivity."
fi

