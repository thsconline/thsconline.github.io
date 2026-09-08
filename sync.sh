#!/bin/bash
set -e

# Check required environment variables
if [ -z "${GIT_TOKEN:-}" ]; then
  echo "ERROR: GIT_TOKEN environment variable is not set."
  exit 1
fi

if [ -z "${SYNCED_REPOS:-}" ]; then
  echo "ERROR: SYNCED_REPOS environment variable is not set."
  exit 1
fi

echo "GIT_TOKEN is set."
echo "SYNCED_REPOS is set."

echo "Creating clean distribution directory..."
mkdir -p dist

# 1. Copy root repository files into 'dist', excluding the script and the dist folder itself
echo "Copying root repository files..."
for item in * .[^.]*; do
  if [ "$item" != "dist" ] && [ "$item" != "sync.sh" ] && [ "$item" != "." ] && [ "$item" != ".." ] && [ "$item" != ".git" ]; then
    cp -r "$item" dist/
  fi
done

# 2. Split the comma-separated string into an array for external repos
IFS=',' read -r -a repo_array <<< "$SYNCED_REPOS"

for repo in "${repo_array[@]}"; do
  # Trim leading and trailing whitespace without xargs
  repo="${repo#"${repo%%[![:space:]]*}"}"
  repo="${repo%"${repo##*[![:space:]]}"}"

  echo "Cloning external repository: $repo..."

  # Safe debug output — token is never exposed
  echo "Git clone URL: https://x-access-token:***@github.com/thsconline/${repo}.git"

  git clone \
    "https://x-access-token:${GIT_TOKEN}@github.com/thsconline/${repo}.git" \
    "temp-${repo}"

  # Create the targeted subfolder directly inside our clean 'dist' folder
  echo "Deploying files to public path: /${repo}..."
  mkdir -p "dist/${repo}"
  cp -r "temp-${repo}/." "dist/${repo}/"

  # Clean up temporary artifacts
  rm -rf "dist/${repo}/.git"
  rm -rf "temp-${repo}"
done

echo "Build preparation complete! All assets compiled."
