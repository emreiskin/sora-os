#!/usr/bin/env bash
# Sora OS - Modül 03: GNOME arayüzü (WhiteSur + Sora görsel kimliği)
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/../lib/helpers.sh"

info "GNOME görsel katmanı kuruluyor (WhiteSur)..."
apply_config_tree
apt_install gnome-shell-extension-dash-to-dock || warn "dash-to-dock kurulamadı"

mkdir -p /opt/sora

install_theme() {
  local name="$1" url="$2"
  if [[ ! -d "/opt/sora/${name}" ]]; then
    git clone --depth 1 "$url" "/opt/sora/${name}" 2>/dev/null || { warn "${name} indirilemedi"; return 1; }
  fi
  return 0
}

install_theme WhiteSur-gtk-theme https://github.com/vinceliuice/WhiteSur-gtk-theme.git \
  && bash /opt/sora/WhiteSur-gtk-theme/install.sh -c dark -d /usr/share/themes \
  && bash /opt/sora/WhiteSur-gtk-theme/tweaks.sh -g -b /usr/share/backgrounds/sora/background.svg \
  || warn "WhiteSur GTK/GDM teması kurulamadı"

install_theme WhiteSur-icon-theme https://github.com/vinceliuice/WhiteSur-icon-theme.git \
  && bash /opt/sora/WhiteSur-icon-theme/install.sh -d /usr/share/icons \
  || warn "WhiteSur ikon seti kurulamadı"

install_theme WhiteSur-cursors https://github.com/vinceliuice/WhiteSur-cursors.git \
  && bash /opt/sora/WhiteSur-cursors/install.sh \
  || warn "WhiteSur imleç seti kurulamadı"

# libadwaita (GTK4) teması yalnızca kullanıcı olarak kurulabilir (root ile çalışmaz)
if [[ "${SORA_CUBIC}" == "0" && -n "${SUDO_USER:-}" && "${SUDO_USER}" != "root" ]]; then
  info "libadwaita teması kullanıcıya uygulanıyor..."
  sudo -u "$SUDO_USER" bash /opt/sora/WhiteSur-gtk-theme/install.sh -l >/dev/null 2>&1 \
    || warn "libadwaita teması uygulanamadı (elle: bash /opt/sora/WhiteSur-gtk-theme/install.sh -l)"
fi

setup_system_dconf
ok "Modül 03 tamam: tema + duvar kağıdı + GNOME ayarları uygulandı"
