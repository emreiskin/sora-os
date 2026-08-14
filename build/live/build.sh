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
trap 'sudo rm -rf "$BUILD_DIR" 2>/dev/null || true' EXIT

mkdir -p "$BUILD_DIR/config/includes.chroot/opt/sora"
cp -a "$REPO/build/live/auto" "$BUILD_DIR/auto"
tar --exclude='.git' -C "$REPO" -cf - . | tar -C "$BUILD_DIR/config/includes.chroot/opt/sora" -xf -

cd "$BUILD_DIR"
sudo lb config

# Hook, lb config sonrasi kopyalanir (lb config config agacini yeniden olusturur)
mkdir -p config/hooks/normal
cp -a "$REPO/build/live/hooks/9500-sora-install.chroot" config/hooks/normal/9500-sora-install.chroot
cp -a "$REPO/build/live/hooks/9500-sora-install.chroot" config/hooks/9500-sora-install.chroot
chmod +x config/hooks/normal/9500-sora-install.chroot config/hooks/9500-sora-install.chroot
echo "==> Hook dosyalari:"
ls -la config/hooks config/hooks/normal

sudo lb build 2>&1 | tee "$OUT/lb-build.log"

echo "==> ISO hazir:"
ls -lh live-image-amd64.hybrid.iso
cp live-image-amd64.hybrid.iso "$OUT/"
