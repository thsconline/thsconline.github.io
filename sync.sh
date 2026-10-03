#!/bin/bash
set -e

# Check required environment variables
if [ -z "${GIT_TOKEN:-}" ]; then
  echo "ERROR: GIT_TOKEN environment variable is not set."
  exit 1
fi

echo "GIT_TOKEN is set."

echo "Creating clean distribution directory..."
rm -rf dist
mkdir -p dist

# Always sync the main s repository.
REPOS=("s")

# Add externally configured repositories.
if [ -n "${SYNCED_REPOS:-}" ]; then
  IFS=',' read -r -a synced_array <<< "$SYNCED_REPOS"

  for repo in "${synced_array[@]}"; do
    # Trim leading and trailing whitespace
    repo="${repo#"${repo%%[![:space:]]*}"}"
    repo="${repo%"${repo##*[![:space:]]}"}"

    # Don't clone s twice
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

  # Safe debug output — token is never exposed
  echo "Git clone URL: https://x-access-token:***@github.com/thsconline/${repo}.git"

  git clone \
    "https://x-access-token:${GIT_TOKEN}@github.com/thsconline/${repo}.git" \
    "temp-${repo}"

  echo "Deploying files to public path: /${repo}..."

  mkdir -p "dist/${repo}"

  if [ "$repo" = "s" ]; then

    echo "Applying special /s deployment rules..."

    # Copy everything except HTML files.
    #
    # This preserves:
    #   *.jsx
    #   *.js
    #   *.css
    #   *.json
    #   images/
    #   PDFs
    #   etc.
    #
    # HTML is handled separately below.
    find "temp-${repo}" \
      -mindepth 1 \
      -maxdepth 1 \
      ! -name ".git" \
      ! -name "*.html" \
      -exec cp -r {} "dist/${repo}/" \;

    # Copy ONLY HTML files directly in /s.
    #
    # This means:
    #   s/header.html  -> deployed
    #   s/viewer.html  -> deployed
    #
    # But NOT:
    #   s/yr10/index.html
    #   s/yr11/index.html
    #   s/yr12/physics/trialpapers.html
    #
    find "temp-${repo}" \
      -maxdepth 1 \
      -type f \
      -name "*.html" \
      -exec cp {} "dist/${repo}/" \;

    # header.html is the Cloudflare Pages fallback.
    if [ -f "dist/s/header.html" ]; then
      echo "Renaming /s/header.html -> /s/404.html..."

      rm -f "dist/s/404.html"
      mv "dist/s/header.html" "dist/s/404.html"
    fi

  else

    # Existing behaviour for synced repositories.
    cp -r "temp-${repo}/." "dist/${repo}/"

    # Remove repository metadata.
    rm -rf "dist/${repo}/.git"

  fi

  # Clean up temporary clone.
  rm -rf "temp-${repo}"

done


# Dynamic Domain Replacement Step
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
