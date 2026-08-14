#!/usr/bin/env bash
# Sora OS - Modül 06: Brave Browser
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/../lib/helpers.sh"

info "Brave Browser deposu ekleniyor..."
install_gpg_key \
  "https://brave-browser-apt-release.s3.brave.com/brave-browser-archive-keyring.gpg" \
  /etc/apt/keyrings/brave-browser-archive-keyring.gpg
printf 'deb [signed-by=/etc/apt/keyrings/brave-browser-archive-keyring.gpg arch=amd64] https://brave-browser-apt-release.s3.brave.com/ stable main\n' \
  > /etc/apt/sources.list.d/brave-browser-release.list
apt_update
apt_install brave-browser || warn "Brave Browser kurulamadı"
ok "Modül 06 tamam: Brave Browser kuruldu"
