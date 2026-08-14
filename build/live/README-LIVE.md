# Sora OS - Otomatik ISO Üretimi

İki yol var: **bulutta otomatik (önerilen)** veya **yerel makinede tek komut**.

## Yol 1: GitHub Actions (önerilen — sana hazır ISO verir)

1. Bu projeyi bir GitHub reposuna yükleyin (`main` dalı).
2. Repoda **Actions** sekmesine girin → **"Sora OS - ISO Build"** → **"Run workflow"** → çalıştırın.
3. Bittiğinde **Actions → iş (job) → Artifacts** bölümünden **Sora-OS-ISO** artefaktını indirin.
   İçinde `live-image-amd64.hybrid.iso` dosyası var — USB'ye yazıp kurun.

Her `push` da otomatik derler; manuel de çalıştırabilirsiniz.

## Yol 2: Yerel makinede derle (Ubuntu 24.04)

```bash
sudo apt update
sudo apt install -y live-build fakeroot debootstrap xorriso squashfs-tools \
  isolinux syslinux-common grub-efi-amd64-bin grub-pc-bin dosfstools mtools

bash build/live/build.sh
```

Çıktı: `build/live/live-image-amd64.hybrid.iso`

## Yol 3: Docker ile (herhangi bir sistem)

```bash
docker run --privileged --rm -v "$PWD:/work" -w /work ubuntu:24.04 bash -c "
  apt-get update &&
  apt-get install -y live-build fakeroot debootstrap xorriso squashfs-tools \
    isolinux syslinux-common grub-efi-amd64-bin grub-pc-bin dosfstools mtools \
    ubuntu-keyring && 
  bash build/live/build.sh"
```

## ISO ne içerir?

- GNOME masaüstü + WhiteSur teması + Sora duvar kağıdı (giriş ekranı dahil)
- Varsayılan kullanıcı: **sora / sora** (otomatik giriş açık)
- Brave Browser, Steam, Lutris, GameMode, Gamescope, MangoHud
- zram + sysctl + governor optimizasyonları, snapd kaldırılmış
- NVIDIA (550) + AMD + Intel desteği, 32-bit oyun katmanları
- Oyun Modu: **Ctrl+Alt+G**

> ISO'yu önce VirtualBox/VMware'de deneyin. Kurulum: canlı oturumda masaüstündeki "Install Sora OS" ile.

> Otomatik girişi kapatmak: `/etc/gdm3/custom.conf` içinde `AutomaticLoginEnable=false` yapın.
