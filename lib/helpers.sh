#!/usr/bin/env bash
# Sora OS - ortak yardımcı fonksiyonlar
set -euo pipefail

SORA_VERSION="1.0.0"
SORA_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CONFIG_DIR="$SORA_ROOT/config"
BIN_DIR="$SORA_ROOT/bin"
LOG_FILE="${SORA_LOG_FILE:-/var/log/sora-install.log}"
SORA_CUBIC="${SORA_CUBIC:-0}"

install -d "$(dirname "$LOG_FILE")" 2>/dev/null || true
touch "$LOG_FILE" 2>/dev/null || true

log()  { printf '%s\n' "[$(date '+%Y-%m-%d %H:%M:%S')] $*" | tee -a "$LOG_FILE"; }
info() { printf '\033[1;34m[*]\033[0m %s\n' "$*" | tee -a "$LOG_FILE"; }
ok()   { printf '\033[1;32m[+]\033[0m %s\n' "$*" | tee -a "$LOG_FILE"; }
warn() { printf '\033[1;33m[!]\033[0m %s\n' "$*" | tee -a "$LOG_FILE"; }
err()  { printf '\033[1;31m[x]\033[0m %s\n' "$*" | tee -a "$LOG_FILE"; }

need_root() {
  if [[ ${EUID} -ne 0 ]]; then
    err "Bu betik root olarak çalıştırılmalı: sudo $0"
    exit 1
  fi
}

apt_update() {
  apt-get update -o Acquire::Retries=3 -o Acquire::http::Timeout=10 || {
    warn "apt update başarısız, tekrar deneniyor..."
    sleep 3
    apt-get update -o Acquire::Retries=3 || warn "apt update tekrar başarısız!"
  }
}

apt_install() {
  apt-get install -y --no-install-recommends "$@"
}

detect_os() {
  [[ -f /etc/os-release ]] || return 1
  # shellcheck disable=SC1091
  . /etc/os-release
  SORA_DISTRO="${ID:-unknown}"
  SORA_VER="${VERSION_ID:-0}"
  SORA_CODENAME="${VERSION_CODENAME:-}"
}

require_ubuntu() {
  detect_os || { err "os-release okunamadı"; return 1; }
  case "${SORA_DISTRO}" in
    ubuntu)  return 0 ;;
    debian)  warn "Debian tespit edildi - Ubuntu tabanlı olduğunu doğrulayın" ;;
    *)       err "Desteklenmeyen dağıtım: ${SORA_DISTRO} (Ubuntu tabanlı olmalı)" ; return 1 ;;
  esac
}

detect_gpu() {
  local list
  list="$(lspci -nn 2>/dev/null | grep -Ei 'vga|3d|display' || true)"
  SORA_GPU=""
  grep -qi 'nvidia' <<<"$list" && SORA_GPU="${SORA_GPU:+$SORA_GPU,}nvidia"
  grep -qiE 'advanced micro devices|amd/ati|radeon' <<<"$list" && SORA_GPU="${SORA_GPU:+$SORA_GPU,}amd"
  grep -qiE 'intel corporation' <<<"$list" && SORA_GPU="${SORA_GPU:+$SORA_GPU,}intel"
  [[ -n "${SORA_GPU}" ]] || SORA_GPU="unknown"
}

has_cmd() { command -v "$1" >/dev/null 2>&1; }

install_gpg_key() {
  local url="$1" out="$2"
  install -d -m 0755 "$(dirname "$out")"
  curl -fsSL "$url" | gpg --dearmor --yes -o "$out"
}

apply_config_tree() {
  cp -a "$CONFIG_DIR/." /
  log "config/ ağacı / dosya sistemine kopyalandı"
}

install_bins() {
  install -d -m 0755 /usr/local/bin
  for f in "$BIN_DIR"/*; do
    [[ -f "$f" ]] && install -m 0755 "$f" /usr/local/bin/
  done
  log "sora-* araçları /usr/local/bin/ altına kuruldu"
}

setup_system_dconf() {
  install -d /etc/dconf/profile /etc/dconf/db/sora.d /etc/dconf/db/sora
  cp "$CONFIG_DIR/dconf/sora-settings.dconf" /etc/dconf/db/sora.d/00-sora
  if [[ -f /etc/dconf/profile/user ]]; then
    grep -q '^system-db:sora$' /etc/dconf/profile/user || echo 'system-db:sora' >> /etc/dconf/profile/user
  else
    printf 'user-db:user\nsystem-db:local\nsystem-db:sora\n' > /etc/dconf/profile/user
  fi
  if has_cmd dconf; then
    dconf update || warn "dconf derlenemedi"
    log "dconf sistemi derlendi"
  fi
}

tune_fstab() {
  [[ -f /etc/fstab ]] || return 0
  cp /etc/fstab /etc/fstab.sora-bak 2>/dev/null || true
  if ! grep -q 'noatime' /etc/fstab; then
    awk '
      /^[[:space:]]*#/ { print; next }
      $2 == "/" || $2 == "/home" {
        if ($4 !~ /noatime/) $4 = $4 ",noatime"
      }
      { print }
    ' /etc/fstab > /tmp/fstab.sora 2>/dev/null && cp /tmp/fstab.sora /etc/fstab
    log "fstab noatime ile güncellendi"
  fi
}

tune_grub() {
  local f=/etc/default/grub
  [[ -f "$f" ]] || return 0
  grep -q 'nowatchdog' "$f" && return 0
  cp "$f" "$f.sora-bak" 2>/dev/null || true
  sed -i 's/^\(GRUB_CMDLINE_LINUX_DEFAULT="[^"]*\)"/\1 nowatchdog"/' "$f"
  log "GRUB: nowatchdog eklendi"
}

run_root() { if [[ ${EUID} -eq 0 ]]; then "$@"; else sudo "$@"; fi; }

run_user() {
  local u="${SUDO_USER:-${USER:-root}}"
  if [[ -z "$u" || "$u" == "root" ]]; then
    "$@"
  else
    sudo -n -u "$u" "$@" 2>/dev/null || "$@"
  fi
}
