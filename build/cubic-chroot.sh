#!/usr/bin/env bash
# Sora OS - Cubic chroot içinde ISO build betiği
# Kullanım:
#   1) Bu projeyi Cubic'in "Copy Files" aşamasında /opt/sora olarak chroot içine kopyalayın
#   2) Cubic "chroot çalıştır" (terminal) bölümünde:
#        bash /opt/sora/build/cubic-chroot.sh
set -euo pipefail

SORA_ROOT="/opt/sora"
export SORA_CUBIC=1
export SORA_LOG_FILE=/var/log/sora-build.log

cd "$SORA_ROOT"
source lib/helpers.sh
need_root
require_ubuntu || exit 1
detect_gpu

info "Sora OS ISO build başlıyor (GPU: ${SORA_GPU})"

for m in "$SORA_ROOT"/modules/*.sh; do
  info "==> Modül: ${m##*/}"
  source "$m"
done

tune_grub
info "Not: Cubic sonraki adımda grub ve initramfs'i kendisi günceller."
ok "Sora OS build tamamlandı! Cubic'te önizleyip ISO üretebilirsiniz."
