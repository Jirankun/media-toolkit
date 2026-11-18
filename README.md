# Media Toolkit

Toolkit terminal untuk mengolah media secara batch: konversi format, kompresi,
perbaikan, ekstraksi audio, dan pemeriksaan media. Antarmukanya adalah TUI
mandiri berbasis bash dan ANSI, bertema hitam dan ungu — tanpa `dialog` maupun
ncurses.

```
╭─ Media Toolkit  2.1.0 ───────────────────────╮
│ source: /home/user/videos                    │
├──────────────────────────────────────────────┤
│  ▸ Convert media      change container/codec │
│    Compress media     smaller target level   │
│    Repair media       fix containers         │
│    Extract audio      video → mp3 · flac     │
│    Media info         codec, resolution      │
│    Setup              install tools          │
│    About              author & license       │
├──────────────────────────────────────────────┤
│ ↑↓ move   ↵ select   1-9 jump   q quit       │
╰──────────────────────────────────────────────╯
```

## Fitur

- **Konversi** — video (mp4, mkv, webm, mov, avi, gif), audio (mp3, wav, flac, ogg, m4a, aac, opus), dan gambar (png, jpg, webp, bmp, tiff, gif).
- **Kompresi** — preset Ringan / Seimbang / Kuat atau persentase pilihan Anda; video ke H.264 + AAC, audio ke MP3, dan gambar dengan pengaturan kualitas.
- **Perbaikan** — remux cepat, enkode ulang penuh, untrunc untuk MP4, penghapusan metadata, dan jpegtran tanpa kehilangan kualitas.
- **Ekstraksi audio** — mengambil trek audio dari video ke mp3, m4a/aac, flac, wav, atau opus.
- **Info media** — durasi, ukuran, kontainer, bitrate, kodek, resolusi, fps, dan tata letak audio.
- **Pengaturan & dependensi** — mendeteksi `apt/dnf/pacman/zypper/apk/brew`, memasang ffmpeg + ImageMagick, dan memasang peluncur `mt`.
- **Tentang** — informasi penulis, lisensi, dan tautan proyek.

## Persyaratan

| Persyaratan                        | Catatan                                          |
| ---------------------------------- | ------------------------------------------------ |
| bash 4+                            | tersedia di hampir semua distribusi              |
| ffmpeg + ffprobe                   | diperlukan untuk video dan audio                 |
| ImageMagick (`magick` / `convert`) | diperlukan untuk gambar                          |
| jpegtran, untrunc                  | opsional, digunakan oleh mode perbaikan tertentu |

Installer dan menu dalam aplikasi **Pengaturan & dependensi → Pasang dependensi**
akan melengkapi komponen yang belum tersedia secara otomatis. Perintah yang digunakan
dipilih berdasarkan pengelola paket yang terdeteksi:

| Keluarga distribusi                         | Pengelola paket | Paket yang dipasang                       |
| ------------------------------------------- | --------------- | ----------------------------------------- |
| Debian, Ubuntu, Mint, Pop!\_OS, Kali        | `apt-get`       | `ffmpeg imagemagick libjpeg-turbo-progs`  |
| Fedora, RHEL, CentOS Stream, Rocky, Alma    | `dnf`           | `ffmpeg ImageMagick libjpeg-turbo-utils`  |
| Arch, Manjaro, EndeavourOS, CachyOS, Garuda | `pacman`        | `ffmpeg imagemagick libjpeg-turbo`        |
| openSUSE Leap / Tumbleweed                  | `zypper`        | `ffmpeg ImageMagick`                      |
| Alpine                                      | `apk`           | `ffmpeg imagemagick`                      |
| macOS, Linuxbrew                            | `brew`          | `ffmpeg imagemagick jpeg-turbo`           |
| lainnya                                     | —               | pasang ffmpeg + ImageMagick secara manual |

Di Fedora dan RHEL, `ffmpeg` berasal dari RPM Fusion; aktifkan repositori tersebut
terlebih dahulu jika paket tidak ditemukan. `jpegtran` dan `untrunc` bersifat
opsional dan hanya digunakan oleh mode perbaikan tertentu.

Jika ada komponen yang belum tersedia, buka **Pengaturan & dependensi → Pasang
dependensi** dan toolkit akan menggunakan pengelola paket Anda.

## Instalasi

### Instalasi cepat

```sh
curl -fsSL https://zhyllanfyllah.is-a.dev/media-toolkit/install.sh | bash
```

Setelah itu, buka terminal baru dan jalankan:

```sh
mt
```

Installer juga membuat perintah `media-toolkit`, jadi kedua nama tersebut dapat digunakan.

### Instalasi manual

```sh
git clone https://github.com/jirankun/media-toolkit.git
cd media-toolkit
./install
```

### Jalankan tanpa instalasi

```sh
./media-toolkit
```

### Opsi installer

```sh
./install --repo OWNER/REPO     # gunakan repositori GitHub lain
./install --branch dev          # gunakan cabang lain
./install --prefix DIR          # lokasi kode (default $XDG_DATA_HOME/media-toolkit)
./install --bin DIR             # lokasi perintah (default $XDG_BIN_HOME)
./install --no-path             # jangan ubah berkas rc shell
./install --no-deps             # jangan pasang ffmpeg / ImageMagick
./install --uninstall           # hapus salinan terpasang dan kedua perintah
```

Installer mengunduh arsip repositori dengan `curl` atau `wget`, memasangnya di
`${XDG_DATA_HOME:-~/.local/share}/media-toolkit`, membuat perintah `mt` dan
`media-toolkit` di `${XDG_BIN_HOME:-~/.local/bin}`, memasang dependensi yang belum
tersedia melalui pengelola paket Anda (menggunakan `sudo` bila diperlukan), dan
menambahkan direktori tersebut ke `PATH` bila perlu.

Installer mengikuti tata letak direktori pengguna XDG, sehingga akses root tidak
diperlukan. Untuk memasang bagi seluruh sistem:

```sh
sudo ./install --prefix /usr/local/share/media-toolkit \
               --bin /usr/local/bin --no-path
```

### Deteksi shell

Installer membaca shell login Anda dari `$SHELL` dan menambahkan satu blok
`PATH` di akhir berkas rc shell tersebut:

| Shell   | Berkas                       |
| ------- | ---------------------------- |
| zsh     | `~/.zshrc`                   |
| bash    | `~/.bashrc`                  |
| fish    | `~/.config/fish/config.fish` |
| lainnya | `~/.profile`                 |

Blok ini idempoten (hanya ditambahkan sekali) dan akan dihapus kembali saat
`--uninstall` dijalankan. Gunakan `--no-path` untuk mengelola `PATH` sendiri.

### Menghapus instalasi

```sh
curl -fsSL https://zhyllanfyllah.is-a.dev/media-toolkit/install.sh | bash -s -- --uninstall
```

## Penggunaan

```sh
mt
```

Navigasi: `↑↓` / `j k`, `PgUp` `PgDn`, `Home` `End`, tombol angka `1-9` untuk
lompat, `Enter` untuk memilih, `q` / `Esc` untuk kembali. Dalam daftar berkas:
`Space` memilih atau membatalkan pilihan sebuah berkas, dan `a` memilih atau
membatalkan pilihan semua berkas.

Progres ditampilkan untuk setiap batch dengan bilah persentase yang diperbarui
langsung, dan setiap eksekusi dicatat di `outputs/toolkit.log`.

Hasil disimpan di folder tempat Anda menjalankan toolkit:

```
outputs/
├── convert/
├── compress/
├── repair/
├── extract/
└── toolkit.log
```

Berkas sumber Anda tidak pernah diubah.

## Struktur proyek

```
media-toolkit      titik masuk dan menu utama
install            installer mandiri
lib/ui             tema, menu, daftar pilihan, prompt, pager, bilah progres
lib/core           jalur, pencatatan, deteksi dependensi, utilitas berkas
lib/convert        konversi format
lib/compress       preset kompresi dan perhitungan bitrate
lib/repair         perbaikan kontainer dan stream
lib/extract        ekstraksi audio
lib/info           info media, info sistem, tentang
lib/setup          pemasangan dependensi dan pengelolaan peluncur
README.md
LICENSE
```

Antarmuka menyesuaikan diri dengan terminal: warna 256 dengan fallback 16 warna,
bingkai UTF-8 dengan fallback ASCII, serta mode teks biasa bernomor ketika
keluaran bukan terminal.

## Lisensi

MIT © 2026 Zhyllan Fyllah

- Situs web: <https://zhyllanfyllah.my.id>
- GitHub: [@jirankun](https://github.com/jirankun)
