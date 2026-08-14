#!/usr/bin/env bash
# Sora OS - Ubuntu tabanlı kurulum betiği
# Kullanım: sudo bash sora-install.sh [--skip-gaming] [--keep-snap] [--skip-cleanup] [--no-update-grub]
set -euo pipefail

SORA_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SORA_ROOT/lib/helpers.sh"

SKIP_GAMING=0
KEEP_SNAP=0
SKIP_CLEANUP=0
UPDATE_GRUB=1

for a in "$@"; do
  case "$a" in
    --skip-gaming)    SKIP_GAMING=1 ;;
    --keep-snap)      KEEP_SNAP=1 ;;
    --skip-cleanup)   SKIP_CLEANUP=1 ;;
    --no-update-grub) UPDATE_GRUB=0 ;;
    -h|--help)
      echo "Kullanım: sudo bash sora-install.sh [--skip-gaming] [--keep-snap] [--skip-cleanup] [--no-update-grub]"
      exit 0
      ;;
  esac
done

banner() {
  cat <<'EOF'

  ███████╗ ██████╗ ██████╗  █████╗
  ██╔════╝██╔═══██╗██╔══██╗██╔══██╗
  ███████╗██║   ██║██████╔╝███████║
  ╚════██║██║   ██║██╔══██╗██╔══██║
  ███████║╚██████╔╝██║  ██║██║  ██║
  ╚══════╝ ╚═════╝ ╚═╝  ╚═╝╚═╝  ╚═╝
  Ubuntu Tabanlı  •  Performans Canavarı
EOF
}

main() {
  need_root
  require_ubuntu || exit 1
  detect_gpu
  banner
  info "Sora OS v${SORA_VERSION} kurulumu başlıyor (GPU: ${SORA_GPU})"
  info "Dağıtım: ${SORA_DISTRO} ${SORA_VER} (${SORA_CODENAME})"

  for m in 01-base 02-drivers 03-interface 04-performance; do
    info "==> Modül: ${m}"
    source "$SORA_ROOT/modules/${m}.sh"
  done

  if [[ ${SKIP_GAMING} -eq 0 ]]; then
    info "==> Modül: 05-gaming"
    source "$SORA_ROOT/modules/05-gaming.sh"
  fi

  info "==> Modül: 06-brave"
  source "$SORA_ROOT/modules/06-brave.sh"

  info "==> Modül: 07-gamemode"
  source "$SORA_ROOT/modules/07-gamemode.sh"

  info "==> Modül: 09-extras"
  source "$SORA_ROOT/modules/09-extras.sh"

  if [[ ${SKIP_CLEANUP} -eq 0 ]]; then
    info "==> Modül: 08-cleanup"
    source "$SORA_ROOT/modules/08-cleanup.sh"
  fi

  tune_grub
  if [[ ${UPDATE_GRUB} -eq 1 ]] && has_cmd update-grub && [[ "${SORA_CUBIC}" == "0" ]]; then
    update-grub || warn "update-grub başarısız oldu"
  fi

  ok "=============================================="
  ok " Sora OS kurulumu TAMAMLANDI!"
  ok " Yeniden başlatmanız önerilir: sudo reboot"
  ok " Oyun Modu: Ctrl+Alt+G  |  sora-status: durum"
  ok "=============================================="
}

main "$@"
