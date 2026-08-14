# Sora OS - GPU Uyumluluk Tablosu

Sora OS, kurulum sırasında `lspci` ile ekran kartını otomatik algılar ve uygun sürücüyü kurar.

## NVIDIA

Sürücü adayları (önce en güncel denenir): `nvidia-driver-575` → `-570` → `-550` → `-535` → `-470`

| Seri | Örnekler | Sürücü |
|---|---|---|
| RTX 50 (Blackwell) | RTX 5070/5080/5090 | 575 |
| RTX 40 (Ada) | RTX 4060/4070/4080/4090 | 575/570 |
| RTX 30 (Ampere) | RTX 3060/3070/3080/3090 | 575/570/550 |
| RTX 20 (Turing) | RTX 2060/2070/2080 | 550 |
| GTX 16 (Turing) | GTX 1650/1660 | 550 |
| GTX 10 (Pascal) | GTX 1050/1060/1080 | 535/470 |
| GTX 9 ve eski | GTX 750/960 | 470 |

Özellikler:
- Wayland: `modeset=1 fbdev=1` ile tam destek
- Gecikme: NVIDIA panelde "Maksimum performans" önerilir
- GameMode: `nv_powermizer_mode=1` otomatik

## AMD

`amdgpu` + Mesa açık kaynak sürücüleri (linux-firmware ile birlikte kurulur)

| Seri | Örnekler |
|---|---|
| RX 7000 (RDNA3) | RX 7600/7700/7800/7900 |
| RX 6000 (RDNA2) | RX 6600/6700/6800/6900 |
| RX 5000 (RDNA1) | RX 5500/5600/5700 |
| RX Vega / Polaris | RX Vega 56/64, RX 580/590 |
| APU (Ryzen G) | 4650G, 5600G, 5800H, 680M, 780M |

## Intel

| Seri | Örnekler |
|---|---|
| Arc (Alchemist) | Arc A310/A380/A580/A750/A770 |
| Arc (Battlemage) | Arc B580/B770 |
| Iris Xe / UHD | 11-14. nesil iGPU'lar |

Medya: `intel-media-va-driver-non-free` ile donanım hızlandırmalı video kod çözme.

## Hybrid Laptoplar (NVIDIA + Intel/AMD)

```bash
prime-select on-demand   # talep üzerine NVIDIA (önerilen)
prime-select nvidia      # her zaman NVIDIA (maksimum performans)
prime-select intel       # sadece iGPU (pil tasarrufu)
```

## Doğrulama

```bash
sora-status              # algılanan GPU + sürücü durumu
vulkaninfo --summary     # Vulkan sürücüsü kontrolü
glxinfo -B               # OpenGL sürücüsü kontrolü
```

## Olası Sorunlar

- **NVIDIA sürücüsü hiç yüklenmiyor**: `sudo apt install nvidia-driver-550` deneyin, ardından `sudo reboot`.
- **AMD ekran donması**: `linux-firmware` güncel değil → `sudo apt install --only-upgrade linux-firmware`.
- **Intel Arc eski çekirdekte yavaş**: çekirdeği Ubuntu LTS-HWE ile güncelleyin (`linux-generic-hwe-24.04`).
