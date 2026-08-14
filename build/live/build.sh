#!/usr/bin/env bash
# Sora OS - live-build ISO üretim betiği
# Kullanım: bash build/live/build.sh   (Ubuntu 24.04 üzerinde, root yetkisi ister)
set -euo pipefail

cd "$(dirname "${BASH_SOURCE[0]}")"
REPO="$(cd ../.. && pwd)"

echo "Sora OS live-build başlıyor"
echo "Proje: ${REPO}"

rm -rf config
mkdir -p config/includes.chroot/opt/sora config/hooks/normal

cp -a "${REPO}/." config/includes.chroot/opt/sora/
cp hooks/9500-sora-install.chroot config/hooks/normal/9500-sora-install.chroot
chmod +x config/hooks/normal/9500-sora-install.chroot auto/config

sudo lb config
sudo lb build

echo "==> ISO hazır:"
ls -lh live-image-amd64.hybrid.iso
