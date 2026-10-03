#!/bin/bash
set -e

if [ -z "${GIT_TOKEN:-}" ]; then
  echo "ERROR: GIT_TOKEN environment variable is not set."
  exit 1
fi

echo "GIT_TOKEN is set."

echo "Creating clean distribution directory..."
rm -rf dist
mkdir -p dist

REPOS=("s")

if [ -n "${SYNCED_REPOS:-}" ]; then
  IFS=',' read -r -a synced_array <<< "$SYNCED_REPOS"

  for repo in "${synced_array[@]}"; do
    repo="${repo#"${repo%%[![:space:]]*}"}"
    repo="${repo%"${repo##*[![:space:]]}"}"

    if [ -n "$repo" ] && [ "$repo" != "s" ]; then
      REPOS+=("$repo")
    fi
  done
fi

echo "Repositories to sync:"
printf ' - %s\n' "${REPOS[@]}"

for repo in "${REPOS[@]}"; do

  echo ""
  echo "Cloning external repository: $repo..."

  echo "Git clone URL: https://x-access-token:***@github.com/thsconline/${repo}.git"

  git clone \
    "https://x-access-token:${GIT_TOKEN}@github.com/thsconline/${repo}.git" \
    "temp-${repo}"

  echo "Deploying files to public path: /${repo}..."

  mkdir -p "dist/${repo}"

  if [ "$repo" = "s" ]; then

    echo "Installing npm dependencies for /s..."
    (
      set -e

      cd "temp-${repo}"

      echo "Working directory: $(pwd)"

      if [ ! -f "vite.package.json" ]; then
        echo "ERROR: vite.package.json not found in $(pwd)"
        exit 1
      fi

      cp -f "vite.package.json" "package.json"

      if [ ! -f "package.json" ]; then
        echo "ERROR: package.json was not created"
        exit 1
      fi

      echo "package.json created successfully"
      npm install
    )

    echo "Building React application for /s..."
    (
      set -e
      cd "temp-${repo}"

      if [ ! -f "package.json" ]; then
        echo "ERROR: package.json not found before build"
        exit 1
      fi

      npm run build
    )

    echo "Applying special /s deployment rules..."


    # Copy everything except HTML files, node_modules and Vite output.
    find "temp-${repo}" \
      -mindepth 1 \
      -maxdepth 1 \
      ! -name ".git" \
      ! -name "*.html" \
      ! -name "node_modules" \
      ! -name "dist" \
      -exec cp -r {} "dist/${repo}/" \;

    # Copy ONLY HTML files directly in /s.
    find "temp-${repo}" \
      -maxdepth 1 \
      -type f \
      -name "*.html" \
      -exec cp {} "dist/${repo}/" \;

    # Copy Vite build output.
    if [ -d "temp-${repo}/dist" ]; then
      echo "Copying Vite build output..."

      cp -r "temp-${repo}/dist/." "dist/${repo}/"
    fi

    # header.html is the Cloudflare Pages fallback.
    if [ -f "dist/s/header.html" ]; then
      echo "Renaming /s/header.html -> /s/404.html..."

      rm -f "dist/s/404.html"
      mv "dist/s/header.html" "dist/s/404.html"
    fi

  else

    cp -r "temp-${repo}/." "dist/${repo}/"

    rm -rf "dist/${repo}/.git"

  fi

  rm -rf "temp-${repo}"

done


if [ -n "$GITHUB_DOMAIN" ] && [ -n "$CF_DOMAIN" ]; then
  echo ""
  echo "Swapping domain dependencies inside JavaScript assets..."
  echo "Replacing '${GITHUB_DOMAIN}' with '${CF_DOMAIN}'..."

  find dist/ \
    -type f \
    -name "*.js" \
    -exec sed -i "s|${GITHUB_DOMAIN}|${CF_DOMAIN}|g" {} +

  echo "Domain migration complete!"
else
  echo ""
  echo "(!) Skipping domain swap: GITHUB_DOMAIN or CF_DOMAIN variables are not set."
fi

echo ""
echo "Build preparation complete!"
