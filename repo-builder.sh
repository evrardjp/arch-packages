#!/usr/bin/env bash

set -o errexit

trap 'rm -f "$TMPFILE"' EXIT
TMPFILE=$(mktemp) || exit 1

export REPOCTL_CONFIG=${REPOCTL_CONFIG:-$(pwd)/config.toml}
DELETE_FAILED_PKGS="${DELETE_FAILED_PKGS:-yes}"
echo "loading repoctl config from $REPOCTL_CONFIG"

echo "=> Desired packages"
cat pkglist

echo "=> Checking for invalid package names"
# Do not allow "/" in package names
# That could prevent mistakes of deleting /
cat pkglist | grep -e '/' && (echo "^ invalid names" && exit 1)

echo "=> Current repo packages"
repoctl list > $TMPFILE
cat ${TMPFILE}

echo "=> Downloading new packages"
NEWPKGS=$(cat pkglist | grep -v -f ${TMPFILE})
for pkg in ${NEWPKGS}; do
	repoctl down -r ${pkg}
	echo "- ${pkg} downloaded"
done

echo "=> Packages to upgrade"
repoctl status -a

echo "=> Downloading packages to update"
repoctl down -u -r

echo "=> Building all packages"
# Do not stop on a singular package failure, continue the build.
set +o errexit
failed_pkgs=()
built_pkgs=()
for pkg in $(cat pkglist); do
	if [[ -d $pkg ]]; then
		echo "Building ${pkg}"
		cd "$pkg"
			makepkg -cs && \
			repoctl add *.pkg.tar.zst && \
			built_pkgs+=("$pkg") || failed_pkgs+=("$pkg")
		cd ..
	fi
done

set -o errexit
for goodpkg in "${built_pkgs[@]}"; do
	echo "${goodpkg} successfully built" && rm -rf "${goodpkg}"
done

if [[ "${#failed_pkgs[@]}" != "0" ]]; then
	for badpkg in "${failed_pkgs[@]}"; do
		echo "${badpkg} failed to build"
		if [[ "${DELETE_FAILED_PKGS}" == "yes" ]]; then
			rm -rf "${badpkg}"
		fi
	done
	exit 1
fi
