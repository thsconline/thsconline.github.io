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

    # ---------------------------------------------------------
    # Install npm dependencies.
    # ---------------------------------------------------------

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

    # ---------------------------------------------------------
    # Remove HTML files that have the exact same basename as
    # a JSX file in the same directory.
    #
    # Example:
    #
    #   upload/index.jsx
    #   upload/index.html   <- removed
    #   upload/other.html   <- kept
    #
    # Only the matching HTML file is removed.
    # ---------------------------------------------------------

    echo "Removing HTML files matching JSX files..."

    find "temp-${repo}" \
      -type f \
      -name "*.jsx" \
      -print0 |
    while IFS= read -r -d '' jsx_file; do

      jsx_dir="$(dirname "$jsx_file")"
      jsx_name="$(basename "$jsx_file" .jsx)"
      html_file="${jsx_dir}/${jsx_name}.html"

      if [ -f "$html_file" ]; then
        echo "Removing: $html_file"
        rm -f "$html_file"
      fi

    done

    echo "HTML cleanup complete."


	# ---------------------------------------------------------
	# Remove ALL HTML files from year directories.
	#
	# yr9
	# yr10
	# yr11
	# yr12
	#
	# This happens BEFORE npm run build.
	# ---------------------------------------------------------

	echo "Removing all HTML files from year directories..."

	for year_dir in yr9 yr10 yr11 yr12; do

	  if [ -d "temp-${repo}/${year_dir}" ]; then
		echo "Cleaning HTML from: ${year_dir}/"

		find "temp-${repo}/${year_dir}" \
		  -type f \
		  -name "*.html" \
		  -print \
		  -delete
	  fi

	done

	echo "Year directory HTML cleanup complete."



    # ---------------------------------------------------------
    # Build React/Vite application.
    # ---------------------------------------------------------

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

    # ---------------------------------------------------------
    # Copy repository contents.
    #
    # HTML files are NOT excluded here. The cleanup above has
    # already removed only the HTML files that correspond to
    # JSX files.
    #
    # Exclude:
    # - .git
    # - node_modules
    # - Vite's source dist directory
    # ---------------------------------------------------------

    find "temp-${repo}" \
      -mindepth 1 \
      -maxdepth 1 \
      ! -name ".git" \
      ! -name "node_modules" \
      ! -name "dist" \
      -exec cp -r {} "dist/${repo}/" \;

    # ---------------------------------------------------------
    # Copy Vite build output.
    # ---------------------------------------------------------

    if [ -d "temp-${repo}/dist" ]; then
      echo "Copying Vite build output..."

      cp -r "temp-${repo}/dist/." "dist/${repo}/"
    fi

	# ---------------------------------------------------------
	# Deploy Cloudflare Pages API middleware.
	#
	# api.js is stored in the /s repository, but Cloudflare
	# Pages Functions must live under the Pages project's
	# top-level /functions directory.
	# ---------------------------------------------------------

	if [ -f "temp-${repo}/api.js" ]; then

	  echo "Installing /s API middleware..."

	  mkdir -p "dist/functions/api/v1"

	  cp -f \
		"temp-${repo}/api.js" \
		"dist/functions/api/v1/[[path]].js"

	  echo "API middleware installed:"
	  echo "  temp-${repo}/api.js"
	  echo "  -> dist/functions/api/v1/[[path]].js"

	else

	  echo "WARNING: temp-${repo}/api.js not found."
	  echo "Skipping API middleware installation."

	fi

    # ---------------------------------------------------------
    # header.html is the Cloudflare Pages fallback.
    # ---------------------------------------------------------

    if [ -f "dist/s/header.html" ]; then
      echo "Renaming /s/header.html -> /s/404.html..."

      rm -f "dist/s/404.html"

      mv "dist/s/header.html" "dist/s/404.html"
    fi

  else

    # ---------------------------------------------------------
    # Standard repository deployment.
    # ---------------------------------------------------------

    cp -r "temp-${repo}/." "dist/${repo}/"

    rm -rf "dist/${repo}/.git"

  fi

  echo "Cleaning temporary repository: temp-${repo}"

  rm -rf "temp-${repo}"

done


# -------------------------------------------------------------
# Replace GitHub domain references with Cloudflare domain.
# -------------------------------------------------------------

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