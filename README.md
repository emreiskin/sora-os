# Sora OS

**Ubuntu tabanlı, performans ve görünüm odaklı Linux dağıtımı.**

GNOME arayüzü üzerine kurulu; ultra düşük RAM/CPU kullanımı, oyun modu, Brave Browser ve NVIDIA / AMD / Intel GPU desteğiyle kutusundan çıktığı gibi hazır.

---

## Öne Çıkan Özellikler

| Alan | Özellik |
|---|---|
| Arayüz | GNOME + WhiteSur teması, macOS benzeri Dock, koyu tema, özel Sora duvar kağıdı, GDM (giriş ekranı) temalı, yuvarlatılmış pencere köşeleri (rounded-window-corners) |
| Kişiselleştirme | `sora-icon` ile uygulama ikonu değiştirme, Papirus ikon teması, Sora Widgets (MD3 tarzı saat + sistem durumu) |
| RAM | zram (zstd sıkıştırma), agresif bellek yönetimi, snapd kaldırma, gereksiz servisler kapatma |
| CPU | schedutil governor, NMI watchdog kapalı, sürekli arka plan CPU tüketimi en aza indirildi |
| Oyun | Feral GameMode, Gamescope, MangoHud, Steam, Lutris, 32-bit katmanlar, **Ctrl+Alt+G oyun modu** |
| Tarayıcı | Brave Browser kurulu ve güncel depodan takip ediliyor |
| GPU | NVIDIA (470/535/550/570/575), AMD (amdgpu + mesa), Intel (Arc/Iris/UHD) otomatik algılama |
| Disk | noatime, SSD trim (fstrim), BBR ağ yönetimi |

---

## Kurulum Yöntemleri

### A) Hazır ISO (önerilen — hiç iş gerekmez)

Projeyi GitHub'a yükleyin → **Actions** → **"Sora OS - ISO Build"** → **Run workflow** → çıkan **Sora-OS-ISO** artefaktını indirin. Bu gerçek, kurulabilir bir ISO'dur.

Yerel üretim: [`build/live/README-LIVE.md`](build/live/README-LIVE.md)

### B) Mevcut Ubuntu üzerine (hızlı)

```bash
sudo bash sora-install.sh
```

Seçenekler:

```bash
sudo bash sora-install.sh --skip-gaming      # oyun bileşenlerini atla
sudo bash sora-install.sh --keep-snap        # snapd'i kaldırma
sudo bash sora-install.sh --skip-cleanup     # temizlik modülünü atla
sudo bash sora-install.sh --no-update-grub   # GRUB'u güncelleme
```

### C) Kendi ISO'unu üret (Cubic)

Ayrıntılı adım adım rehber: [`build/ISO-BUILD-GUIDE.md`](build/ISO-BUILD-GUIDE.md)

---

## Kullanım

| Komut | Açıklama |
|---|---|
| `sora-gamemode on/off/toggle/status` | Oyun modu aç/kapat (CPU governor + animasyonlar) |
| `Ctrl+Alt+G` | Oyun modunu hızlı aç/kapat |
| `sora-status` | Sistem durumu özeti (GPU, RAM, governor, zram) |
| `sora-clean` | Sistem temizliği (apt, journal, cache) |
| `sora-icon set <uygulama> <ikon>` | Uygulama ikonunu değiştir (dosya yolu veya ikon adı) |
| `sora-icon reset <uygulama>` | Özel ikonu geri al |
| `sora-icon theme <tema>` | İkon temasını değiştir (örn. `Papirus-Dark`) |
| `sora-icon list` / `themes` / `install` / `status` | Kısayol, tema ve özel ikonları yönet |

Steam'de oyun başlatma seçeneğine şunu ekleyerek GameMode + MangoHud alabilirsiniz:

```
gamemoderun mangohud %command%
```

---

## Proje Yapısı

```
Sora OS/
├── sora-install.sh          # Post-install kurulum betiği
├── lib/helpers.sh           # Ortak fonksiyonlar
├── modules/                 # 01-09 kurulum modülleri (09: ekstra görsel katman)
├── config/                  # Kök dosya sistemi ağacı (sysctl, zram, dconf, tema, duvar kağıdı, Sora Widgets)
├── bin/                     # sora-gamemode, sora-setgov, sora-status, sora-clean, sora-icon
├── build/
│   ├── cubic-chroot.sh      # Cubic ISO build girişi
│   ├── ISO-BUILD-GUIDE.md   # Cubic adım adım rehber
│   └── live/                # Otomatik ISO üretimi (live-build + GitHub Actions)
├── .github/workflows/       # ISO'yu bulutta derleyip artefakt verir
└── docs/                    # TUNING-NOTES, GPU-COMPAT
```

---

## Not

- Betikler Linux'ta çalışacak şekilde yazılmıştır. Dosyalar Windows'ta LF satır sonu ile yazıldı; eğer satır sonu sorunu yaşarsanız `sed -i 's/\r$//' <dosya>` veya `dos2unix` uygulayın.
- Tüm ayarların ne işe yaradığı: [`docs/TUNING-NOTES.md`](docs/TUNING-NOTES.md)
