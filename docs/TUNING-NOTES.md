# Sora OS - Performans Notları

Bu doküman, Sora OS'ta yapılan tüm optimizasyonların **neden** yapıldığını açıklar.

## Bellek (RAM)

| Ayar | Değer | Neden |
|---|---|---|
| `vm.swappiness` | 100 | zram sıkıştırılmış takas çok hızlıdır; bellek doluşunca disk yerine sıkıştırılmış RAM kullanılır, çökme riski azalır |
| `vm.vfs_cache_pressure` | 50 | dosya sistemi önbellekleri daha uzun tutulur → daha az disk I/O |
| `vm.page-cluster` | 0 | zram üzerinde tek sayfa okuma → sıkıştırma verimi artar |
| `vm.watermark_scale_factor` | 125 | bellek baskısı altında ani takılmaları azaltır (oyunlarda akıcılık) |
| zram | `min(ram/2, 8192)`, zstd | RAM'in yarısına kadar sıkıştırılmış takas alanı; 16 GiB makinede ~8 GiB ek "bellek" |
| `vm.dirty_ratio` / `dirty_background_ratio` | 10 / 5 | kirli sayfaları daha hızlı yaz → ani IO sıkışmaları azalır |
| snapd kaldırma | — | snapd tek başına ~100-200 MB RAM + sürekli arka plan hizmeti tüketir |
| apport / kerneloops / cups-browsed kapatma | — | çökme raporu ve yazıcı keşif daemon'ları boşta CPU/RAM yakar |
| apt periyodik güncellemeler kapalı | — | arka planda apt çalışmaz (manuel güncelleme: `sudo apt upgrade`) |

## CPU

| Ayar | Değer | Neden |
|---|---|---|
| Governor | `schedutil` | modern çekirdekler için en iyi pil/perf dengesi; oyun modunda `performance` |
| `kernel.nmi_watchdog` | 0 | NMI watchdog her CPU'da sürekli sayaç çalıştırır |
| GameMode `desiredgov=performance` | — | oyun açılınca governor otomatik `performance` olur, çıkınca `schedutil` |
| `nowatchdog` (GRUB) | — | çekirdek seviyesinde watchdog kapanır |

## Disk

| Ayar | Neden |
|---|---|
| `noatime` | her okumada `atime` güncellemesini atlar → daha az yazma, daha hızlı erişim |
| `fstrim.timer` | SSD'lerde düzenli TRIM → uzun vadeli performans |
| `sora-clean` | apt + journal + cache temizliği |

## Ağ

| Ayar | Neden |
|---|---|
| `fq` + `tcp_congestion_control=bbr` | Google BBR, gecikmeyi ve paket kaybını düşürür; online oyun/akış için faydalı |

## Oyun

- **GameMode (Feral)**: `/etc/gamemode.ini` — oyun çalışırken CPU governor `performance`, NVIDIA `powermizer mode 1`, ekran koruyucu engellenir.
- **Gamescope**: sınırlı FPS / düşük gecikme / ölçekleme için; Steam'de: `gamescope -W 2560 -H 1440 -- %command%`
- **MangoHud**: FPS/CPU/GPU/RAM göstergesi. Steam başlatma seçeneği: `gamemoderun mangohud %command%`
- **`vm.max_map_count=1048576`**: çok sayıda memory map isteyen oyunlar (modlu/VR oyunlar) için gerekli.
- **32-bit katmanlar**: Steam oyunları için `libgamemode0:i386`, `libmangohud:i386`.
- **fsync**: Steam → Ayarlar → indirmelerde "Shadercache" ve "komut satırı" ile; Proton'un varsayılan `FSYNC=1` desteğiyle düşük gecikme.

### Oyun Modu (Ctrl+Alt+G)

`sora-gamemode toggle` şunları yapar:
1. Tüm CPU'ları `performance` governor'a alır
2. GNOME animasyonlarını kapatır (GPU'yu oyuna ayırır)
3. Kapatınca `schedutil` + animasyonlar geri gelir

> `sudo visudo` altına otomatik eklenen kural, `sora-setgov` komutunun şifresiz çalışmasını sağlar.

## GPU Başarım İpuçları

- **NVIDIA**: Wayland için `modeset=1 fbdev=1` ayarlı. Gecikme için NVIDIA panel → "Görüntü/Yönetici modları"nda "Maksimum performans".
- **AMD**: mesa + Vulkan varsayılan. `RADV_PERFTEST` gerekmez; yeni çekirdeklerde `amdgpu` hazır.
- **Hybrid (NVIDIA+Intel)**: `prime-select on-demand` komutuyla talep üzerine NVIDIA; pil ömrü için önerilir.
- Oyun modu açıkken pil şarjının hızla düştüğünü unutmayın; masaüstü kullanımında `off`.

## Sıkça Sorulan

**RAM kullanımı ne kadar?** Taze oturumda GNOME + Sora ayarlarıyla ~1.2-1.6 GB (snapd'siz). 8 GB'lık makinelerde bile rahat çalışır.

**Güvenlik notu:** `nowatchdog`, `mitigations` gibi ayarlar teori/yük altında performansı artırır ama bazı güvenlik önlemlerini devre dışı bırakabilir. Sora varsayılan olarak yalnızca `nowatchdog` kullanır; `mitigations=off` eklemek için:
```bash
sudo sed -i 's/nowatchdog/nowatchdog mitigations=off/' /etc/default/grub && sudo update-grub
```
