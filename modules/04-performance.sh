#!/usr/bin/env bash
# Sora OS - Modül 04: Performans optimizasyonları (RAM/CPU)
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/../lib/helpers.sh"

info "Performans ayarları uygulanıyor..."
apt_install linux-tools-common || warn "cpupower kurulamadı (governor servisi atlanacak)"

apply_config_tree
tune_fstab

if [[ "${SORA_CUBIC}" == "0" ]]; then
  sysctl --system >/dev/null 2>&1 || true
fi

cat > /etc/systemd/system/sora-cpugovernor.service <<'EOF'
[Unit]
Description=Sora OS CPU Governor (schedutil)
After=systemd-modules-load.service

[Service]
Type=oneshot
ExecStart=/usr/bin/cpupower frequency-set -g schedutil
RemainAfterExit=yes

[Install]
WantedBy=multi-user.target
EOF
systemctl enable sora-cpugovernor.service 2>/dev/null || warn "governor servisi etkinleştirilemedi"

if [[ "${SORA_CUBIC}" == "0" ]]; then
  systemctl daemon-reload 2>/dev/null || true
  systemctl start 'systemd-zram-setup@zram0.service' 2>/dev/null || true
  systemctl start sora-cpugovernor.service 2>/dev/null || true
fi

for s in apport.service kerneloops.service cups-browsed.service; do
  systemctl disable "$s" 2>/dev/null || true
  systemctl stop "$s" 2>/dev/null || true
done
systemctl enable fstrim.timer 2>/dev/null || true

printf 'APT::Periodic::Update-Package-Lists "0";\nAPT::Periodic::Download-Upgradeable-Packages "0";\nAPT::Periodic::Unattended-Upgrade "0";\n' > /etc/apt/apt.conf.d/20sora

ok "Modül 04 tamam: zram + sysctl + governor hazır"
