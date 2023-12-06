#!/bin/sh

function fail_to_run {
    echo "Could not run svelte app" >&2
    exit 1
}

# Ensure create-svelte is installed such that we can autobuild our app
if ! npm list -g --depth 0 | grep create-svelte > /dev/null ; then 
    read -p "Not finding svelte packages. Should we run \`npm install -g create-svelte\`? [Y/n]" confirm_install_svelte
    case "$confirm_install_svelte" in
        [Yy]|[Yy][Ee][Ss]|"")
            npm install -g create-svelte
            ;;
        *)
            fail_to_run
            ;;
    esac
fi

if npm install --dry-run | grep "vulnerabilities"; then
    read -p "Vulnerabilities found in packages described in \`package.json\`. Should we run \`npx npm-force-resolutions\`? [Y/n]" confirm_fix_vulnerabilities
    case "$confirm_fix_vulnerabilities" in
        [Yy]|[Yy][Ee][Ss]|"")
            npx npm-force-resolutions
            ;;
        *)
            fail_to_run
            ;;
    esac

fi

# Ensure appropriate npm packages are installed for svelte app
    # Not 100 percent sure this works as I expect. Have not made time to test.
outdated=$(npm outdated --json)
if echo "$outdated" | jq -e 'map(.current == .wanted) | all' >/dev/null; then # Here we ensure that all packages have matching current and wanted (as declared in package.json) versions.
    echo "All required packages are installed."
else
    read -p "Not finding packages described in \`package.json\`. Should we run \`npm install\`? [Y/n]" confirm_install_pkgs
    case "$confirm_install_pkgs" in
        [Yy]|[Yy][Ee][Ss]|"")
            npm install
            ;;
        *)
            fail_to_run
            ;;
    esac
fi

echo "Running svelte app..."
npm run dev
