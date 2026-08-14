#!/usr/bin/env bash
# Sora OS - Modül 05: Oyun desteği (Steam, GameMode, Gamescope, MangoHud, Lutris)
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/../lib/helpers.sh"

info "Oyun bileşenleri kuruluyor..."
add-apt-repository -y multiverse 2>/dev/null || true
dpkg --add-architecture i386
apt_update

apt_install steam-installer lutris gamemode libgamemode0 libgamemodeauto0 \
  mangohud gamescope || warn "Bazı oyun paketleri kurulamadı"

apt_install libgamemode0:i386 libgamemodeauto0:i386 2>/dev/null \
  || warn "32-bit GameMode katmanı kurulamadı (opsiyonel)"
apt_install libmangohud:i386 2>/dev/null || warn "32-bit MangoHud kurulamadı (opsiyonel)"

has_cmd gamemoded && log "gamemoded kurulu"
has_cmd gamescope && log "gamescope kurulu"
has_cmd mangohud && log "mangohud kurulu"

ok "Modül 05 tamam: Steam + GameMode + Gamescope + MangoHud + Lutris"
