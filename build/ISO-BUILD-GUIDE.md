# Sora OS ISO Build Rehberi (Cubic)

Bu rehber, Sora OS'u önyüklenebilir bir Ubuntu ISO'suna dönüştürmenizi sağlar. Tüm özelleştirmeler (tema, oyun modu, Brave, GPU sürücüleri, performans ayarları) ISO'nun içine önceden yüklenir.

## Gereksinimler

- Ubuntu **24.04** veya **25.04** ISO dosyası (desktop)
- Cubic (Ubuntu Customization Kit):
  ```bash
  sudo add-apt-repository ppa:cubic-wizard/release
  sudo apt update && sudo apt install cubic
  ```
- Kurulumu yapacak makinede internet bağlantısı (tema indirme ve apt için)
- En az 30 GB boş disk alanı

## Adımlar

1. **Projeyi Linux ortamına taşıyın**
   Proje klasörünü (ör. USB'den) bir Linux makineye kopyalayın. Windows'tan kopyalandıysa satır sonlarını düzeltin:
   ```bash
   sudo apt install dos2unix
   find /path/to/"Sora OS" -type f \( -name "*.sh" -o -name "sora-*" \) -exec dos2unix {} +
   ```

2. **Cubic'i açın**
   `cubic` komutuyla başlatın, Ubuntu ISO dosyasını seçin ve yeni proje klasörü belirleyin. Proje klasörünün yolunda boşluk olmamasına dikkat edin (ör. `/home/kullanici/sora-cubic`).

3. **ISO'yu açın**
   Cubic ISO'yu `squashfs` olarak çıkardıktan sonra arayüzde ilerleyin.

4. **Dosyaları kopyalayın**
   Cubic'in **"Copy Files"** (Dosya Kopyala) bölümünde:
   - Kaynak: Sora OS proje klasörü
   - Hedef: `/opt/sora`
   Böylece proje chroot içinde `/opt/sora` olarak görünür.

5. **Chroot içinde kurulumu çalıştırın**
   Cubic'in **"Terminal"** bölümünde:
   ```bash
   bash /opt/sora/build/cubic-chroot.sh
   ```
   Bu betik tüm modülleri sırayla çalıştırır:
   - Temel paketler
   - GPU sürücüleri (algılanan donanıma göre)
   - WhiteSur teması + GNOME ayarları + duvar kağıdı
   - zram / sysctl / governor / servis optimizasyonları
   - Steam + GameMode + Gamescope + MangoHud + Lutris
   - Brave Browser
   - Oyun modu araçları + sudoers kuralı
   - snapd kaldırma + sistem temizliği

   Kurulum bittiğinde log: `/var/log/sora-build.log`

6. **Projeyi chroot'tan temizleyin**
   ```bash
   rm -rf /opt/sora
   ```

7. **Cubic'i ilerletin**
   Cubic'te sırasıyla:
   - **Packages** sekmesini atlayabilirsiniz (gerekmedikçe dokunmayın)
   - **Kernel / Bootloader** adımlarını Cubic'in önerdiği gibi ilerletin
   - **Generate** (ISO üret) ile son ISO'yu oluşturun

8. **Test edin**
   Üretilen ISO'yu önce sanal makinede (VirtualBox/VMware/QEMU) deneyin, sonra gerçek donanıma kurun.

## İpuçları

- NVIDIA sistemde kurulum yapacaksanız ISO zaten `nvidia-driver-*` paketlerini içerecek şekilde yapılandırılır; ayrıca her kurulumda otomatik algılama çalışır.
- ISO boyutu Steam ve oyun araçları yüzünden büyük olacaktır (~5-8 GB). Bu normaldir.
- Steam ilk açılışta sözleşmeyi onaylamanızı ister; bu tek seferliktir.
- Kurulum sonrası ilk oturumda temaların tam oturması için oturumu bir kez kapatıp açın.
- GDM (giriş ekranı) Sora duvar kağıdıyla temalı kurulur. GTK4/libadwaita uygulamalarının (Nautilus, Ayarlar) tam temalı görünmesi için her kullanıcı ilk oturumda şunu bir kez çalıştırır:
  ```bash
  bash /opt/sora/WhiteSur-gtk-theme/install.sh -l
  ```
- İsteğe bağlı Flatpak temaları: `bash /opt/sora/WhiteSur-gtk-theme/tweaks.sh -F`
