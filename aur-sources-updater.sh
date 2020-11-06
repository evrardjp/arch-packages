#!/usr/bin/env bash

set -e
# Updates oudated packages and builds them in the pkglist order
repoctl down -u -o pkglist
for pkg in $(cat build-order.txt); do
    (
        cd "$pkg"
        makepkg -cs
        repoctl add *.pkg.tar.zst
        cd ..
        rm -rf "$pkg"
    )
done
