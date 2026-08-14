#!/usr/bin/env bash
# Sora OS - Modül 02: GPU sürücüleri (NVIDIA / AMD / Intel)
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/../lib/helpers.sh"

detect_gpu
info "Tespit edilen GPU: ${SORA_GPU}"
dpkg --add-architecture i386
apt_update

info "Vulkan / Mesa ortak bileşenleri kuruluyor..."
apt_install linux-firmware mesa-utils libvulkan1 libvulkan1:i386 \
  mesa-vulkan-drivers mesa-vulkan-drivers:i386 \
  libgl1-mesa-dri libgl1-mesa-dri:i386 vulkan-tools || {
    warn "Vulkan/Mesa kurulumu kısmen başarısız oldu"
  }

install_nvidia() {
  info "NVIDIA sürücüsü kuruluyor..."
  local drv=""
  local c
  for c in nvidia-driver-575 nvidia-driver-570 nvidia-driver-550 nvidia-driver-535 nvidia-driver-470; do
    if apt-cache policy "$c" 2>/dev/null | grep -q "Candidate: [0-9]"; then
      drv="$c"
      break
    fi
  done
  if [[ -z "$drv" ]]; then
    warn "NVIDIA sürücü paketi bulunamadı"
    return 0
  fi
  apt_install "$drv" nvidia-kernel-common libnvidia-egl-wayland1 || warn "NVIDIA sürücü kurulumu başarısız oldu"
  printf 'options nvidia_drm modeset=1 fbdev=1\n' > /etc/modprobe.d/sora-nvidia.conf
  ok "NVIDIA sürücüsü: ${drv} (Wayland modeset aktif)"
}

install_amd() {
  info "AMD amdgpu kullanılacak (mesa + linux-firmware zaten kuruldu)"
  ok "AMD desteği hazır"
}

install_intel() {
  info "Intel GPU desteği kuruluyor..."
  apt_install vulkan-intel intel-gpu-tools || warn "Intel paketleri kısmen kurulamadı"
  apt_install intel-media-va-driver-non-free 2>/dev/null \
    || apt_install intel-media-va-driver 2>/dev/null \
    || warn "Intel medya sürücüsü kurulamadı (opsiyonel)"
  ok "Intel desteği hazır"
}

case ",${SORA_GPU}," in
  *,nvidia,*) install_nvidia ;;
  *,amd,*)    install_amd ;;
  *,intel,*)  install_intel ;;
  *)          warn "GPU tanınamadı, varsayılan mesa sürücüleri kullanılacak" ;;
esac

ok "Modül 02 tamam: GPU desteği yapılandırıldı"
