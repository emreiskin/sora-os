#!/usr/bin/env bash
# Sora OS - Modül 01: Temel sistem ve paketler
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/../lib/helpers.sh"

info "Temel paketler güncelleniyor ve kuruluyor..."
apt_update
apt_install curl wget git unzip xz-utils p7zip-full ca-certificates gnupg \
  software-properties-common rsync htop neofetch dconf-editor \
  gnome-tweaks gnome-shell-extensions fonts-inter-variable || {
    warn "Temel paket kurulumu kısmen başarısız oldu"
  }
ok "Modül 01 tamam: temel sistem hazır"
