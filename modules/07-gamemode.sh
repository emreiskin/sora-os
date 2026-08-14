#!/usr/bin/env bash
# Sora OS - Modül 07: Sora Oyun Modu araçları
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/../lib/helpers.sh"

info "Oyun Modu araçları kuruluyor..."
install_bins

cat > /tmp/sora-sudoers <<'EOF'
ALL ALL=(root) NOPASSWD: /usr/local/bin/sora-setgov
EOF
install -d -m 0755 /etc/sudoers.d
install -m 0440 -o root -g root /tmp/sora-sudoers /etc/sudoers.d/50-sora-gamemode
rm -f /tmp/sora-sudoers

ok "Modül 07 tamam: sora-gamemode (Ctrl+Alt+G), sora-status, sora-clean"
