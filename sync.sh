#!/bin/bash
set -e

echo "Creating clean distribution directory..."
mkdir -p dist

# 1. Copy root repository files into 'dist', excluding the script and the dist folder itself
echo "Copying root repository files..."
for item in * .[^.]*; do
  # Avoid copying the build folder, the script itself, or system directory pointers
  if [ "$item" != "dist" ] && [ "$item" != "build-setup.sh" ] && [ "$item" != "." ] && [ "$item" != ".." ] && [ "$item" != ".git" ]; then
    cp -r "$item" dist/
  fi
done

# 2. Split the comma-separated string into an array for external repos
IFS=',' read -r -a repo_array <<< "$SYNCED_REPOS"

for repo in "${repo_array[@]}"; do
  repo=$(echo "$repo" | xargs) # Trim spaces
  
  echo "Cloning external repository: $repo..."
  git clone "https://x-access-token:${GIT_TOKEN}@://github.com{repo}.git" "temp-${repo}"

  # Create the targeted subfolder directly inside our clean 'dist' folder
  echo "Deploying files to public path: /${repo}..."
  mkdir -p "dist/${repo}"
  cp -r temp-${repo}/. "dist/${repo}/"

  # Clean up temporary artifacts
  rm -rf "dist/${repo}/.git"
  rm -rf "temp-${repo}"
done

echo "Build preparation complete! All assets compiled safely inside /dist."
