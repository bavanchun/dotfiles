#!/usr/bin/env bash
# Re-sync this patched PKGBUILD with the official Arch one and check the patch
# still applies. Run it after `pacman -Syu` reports a new noctalia version.
set -euo pipefail
cd "$(dirname "$(readlink -f "$0")")"

PATCH=0001-bluetooth-display-only-pairing-prompts.patch
UPSTREAM_URL=https://gitlab.archlinux.org/archlinux/packaging/packages/noctalia/-/raw/main/PKGBUILD

echo ":: fetching official PKGBUILD"
curl -fsSL "$UPSTREAM_URL" -o PKGBUILD.arch

new_ver=$(sed -n 's/^pkgver=//p' PKGBUILD.arch)
cur_ver=$(sed -n 's/^pkgver=//p' PKGBUILD)
new_sum=$(sed -n "s/^sha256sums=('\([a-f0-9]*\)'.*/\1/p" PKGBUILD.arch)

echo ":: packaged upstream: $new_ver   (this tree: $cur_ver)"

if [[ "$new_ver" != "$cur_ver" ]]; then
  sed -i "s/^pkgver=.*/pkgver=$new_ver/" PKGBUILD
  sed -i "0,/^sha256sums=('[a-f0-9]*'/s//sha256sums=('$new_sum'/" PKGBUILD
  echo ":: bumped PKGBUILD to $new_ver"
fi

echo ":: checking the patch against $new_ver sources"
tmp=$(mktemp -d); trap 'rm -rf "$tmp"' EXIT
tag="v${new_ver//_/-}"
curl -fsSL "https://github.com/noctalia-dev/noctalia/archive/refs/tags/$tag.tar.gz" \
  | tar -xz -C "$tmp"
src="$tmp/noctalia-${new_ver//_/-}"

if patch -d "$src" -p1 --dry-run -i "$PWD/$PATCH" >/dev/null 2>&1; then
  echo ":: patch applies cleanly -- build with:  makepkg -si"
  exit 0
fi

echo
echo "!! the patch NO LONGER APPLIES to $new_ver."
echo "   Most likely upstream reworked or fixed this code. Check first:"
echo "     https://github.com/noctalia-dev/noctalia/blame/$tag/src/dbus/bluetooth/bluetooth_agent.cpp"
echo "   If hasPendingRequest() now accounts for DisplayPasskey, the bug is fixed"
echo "   upstream: run 'sudo pacman -S noctalia' to go back to the stock package"
echo "   and delete this directory."
exit 1
