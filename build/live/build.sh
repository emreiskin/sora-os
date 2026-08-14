#!/usr/bin/env bash
# Sora OS - live-build ISO üretim betiği
# Kullanım: bash build/live/build.sh   (Ubuntu 24.04 üzerinde, root yetkisi ister)
set -euo pipefail

cd "$(dirname "${BASH_SOURCE[0]}")"
REPO="$(cd ../.. && pwd)"
OUT="$PWD"

echo "Sora OS live-build başlıyor"
echo "Proje: ${REPO}"

BUILD_DIR="$(mktemp -d /tmp/sora-lb.XXXXXX)"
trap 'rm -rf "$BUILD_DIR"' EXIT

mkdir -p "$BUILD_DIR/config/includes.chroot/opt/sora" "$BUILD_DIR/config/hooks/normal"
cp -a "$REPO/build/live/auto" "$BUILD_DIR/auto"
tar --exclude='.git' -C "$REPO" -cf - . | tar -C "$BUILD_DIR/config/includes.chroot/opt/sora" -xf -
cp -a "$REPO/build/live/hooks/9500-sora-install.chroot" "$BUILD_DIR/config/hooks/normal/9500-sora-install.chroot"
chmod +x "$BUILD_DIR/config/hooks/normal/9500-sora-install.chroot" "$BUILD_DIR/auto/config"

cd "$BUILD_DIR"
sudo lb config
sudo lb build

echo "==> ISO hazır:"
ls -lh live-image-amd64.hybrid.iso
cp live-image-amd64.hybrid.iso "$OUT/"
