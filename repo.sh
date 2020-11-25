#!/usr/bin/env bash
set -o errexit

# pacman Syu necessary to populate packages db, necessary to build other pkgs using repoctl.
pacman -Syu --noconfirm base base-devel
source ./repo-builder.sh
