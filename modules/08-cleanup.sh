#!/usr/bin/env bash
# Sora OS - Modül 08: Temizlik (snapd kaldırma + apt temizliği)
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/../lib/helpers.sh"

if [[ "${KEEP_SNAP:-0}" == "1" ]] || ! command -v snap >/dev/null 2>&1; then
  info "snapd korunuyor veya kurulu değil"
else
  info "snapd kaldırılıyor (RAM/CPU kazancı)..."
  snap remove --purge firefox 2>/dev/null || true
  if [[ "${SORA_DISTRO:-ubuntu}" == "ubuntu" ]]; then
    add-apt-repository -y ppa:mozillateam/ppa 2>/dev/null || true
    printf 'Package: firefox*\nPin: release o=LP-PPA-mozillateam\nPin-Priority: 1001\n' > /etc/apt/preferences.d/99sora-firefox
    apt_update
    apt_install firefox || warn "Firefox (PPA) kurulamadı"
  fi
  apt-get purge -y snapd 2>/dev/null || true
  rm -rf /snap /var/snap /var/lib/snapd /root/snap /home/*/snap 2>/dev/null || true
fi

info "Sistem temizleniyor..."
apt-get autoremove --purge -y 2>/dev/null || true
apt-get clean 2>/dev/null || true
ok "Modül 08 tamam: temizlik yapıldı"
