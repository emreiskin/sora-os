#!/usr/bin/env bash
# Sora OS - Modül 09: Ekstra görsel katman (ikon teması + yuvarlak köşeler + Sora Widgets)
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/../lib/helpers.sh"

info "Ekstra görsel katman kuruluyor (Papirus + yuvarlak köşeler)..."

# 1) Papirus ikon teması (değiştirme: sora-icon theme Papirus-Dark)
if ! apt_install papirus-icon-theme; then
  warn "papirus-icon-theme kurulamadı"
fi

# 2) Sora Widgets uzantısı config ağacıyla birlikte kuruldu (Modül 03);
#    dconf'a kaydı sora-settings.dconf içinde statik olarak yapıldı.

# 3) rounded-window-corners (EGO pk=9668, GNOME 45-50 destekli)
install_ego_extension() {
  local pk="$1" shell_ver="" info url tmp extdir
  [[ -f /usr/share/gnome-shell/package-version ]] && shell_ver="$(cat /usr/share/gnome-shell/package-version)"
  info="$(curl -fsSL "https://extensions.gnome.org/extension-info/?pk=${pk}&shell_version=${shell_ver}" 2>/dev/null || true)"
  url="$(printf '%s' "$info" | python3 -c 'import json,sys; print(json.load(sys.stdin).get("download_url",""))' 2>/dev/null || true)"
  [[ -n "$url" ]] || { warn "rounded-window-corners indirme bilgisi alınamadı"; return 1; }
  tmp="$(mktemp -d)"
  curl -fsSL "https://extensions.gnome.org${url}" -o "$tmp/ext.zip" || { warn "uzantı zip'i indirilemedi"; rm -rf "$tmp"; return 1; }
  (cd "$tmp" && unzip -q ext.zip -d ext) || { warn "uzantı zip'i açılamadı"; rm -rf "$tmp"; return 1; }
  extdir="$(find "$tmp/ext" -mindepth 1 -maxdepth 1 -type d | head -1)"
  [[ -n "$extdir" ]] || { warn "uzantı arşivi bozuk"; rm -rf "$tmp"; return 1; }
  install -d /usr/share/gnome-shell/extensions
  cp -a "$extdir" /usr/share/gnome-shell/extensions/
  printf '%s\n' "$(basename "$extdir")"
  rm -rf "$tmp"
}

append_extension() {
  # /etc/dconf/db/sora.d/00-sora içindeki enabled-extensions listesine uuid ekler (idempotent)
  local uuid="$1" f=/etc/dconf/db/sora.d/00-sora
  [[ -f "$f" ]] || { warn "dconf dosyası bulunamadı: $f"; return 1; }
  grep -q "$uuid" "$f" && return 0
  if python3 - "$f" "$uuid" <<'PYEOF'
import re, sys
path, uuid = sys.argv[1], sys.argv[2]
src = open(path, encoding="utf-8").read()
new = re.sub(
    r"(enabled-extensions=\[)([^\]\n]*)\]",
    lambda m: m.group(1) + m.group(2) + ("," if m.group(2) else "") + "'" + uuid + "']",
    src, count=1,
)
if new == src:
    sys.exit(1)
open(path, "w", encoding="utf-8").write(new)
PYEOF
  then
    log "Uzantı dconf'a eklendi: $uuid"
  else
    warn "dconf'a uzantı eklenemedi: $uuid (elle ekleyin)"
    return 1
  fi
}

RC_UUID="$(install_ego_extension 9668 || true)"
if [[ -n "$RC_UUID" ]]; then
  if append_extension "$RC_UUID"; then
    has_cmd dconf && dconf update || warn "dconf derlenemedi"
    ok "rounded-window-corners kuruldu ve etkinleştirildi ($RC_UUID)"
  fi
else
  warn "rounded-window-corners kurulamadı (EGO pk=9668) - elle: https://extensions.gnome.org/extension/9668/"
fi

ok "Modül 09 tamam: Papirus ikon teması + yuvarlak köşeler + Sora Widgets"
