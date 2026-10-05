# Vidrado

**Desktop yang lebih tenang. Pikiran yang lebih jernih.**

Vidrado adalah app menu bar native untuk macOS yang memburamkan dan meredupkan jendela di latar belakang sambil menjaga jendela aktif tetap jernih. App ini bekerja sepenuhnya di Mac Anda, tanpa akun, langganan, pelacakan, atau perekaman layar.

[Unduh](https://github.com/tonhadaplaces/vidrado/releases) · [Laporkan bug](https://github.com/tonhadaplaces/vidrado/issues/new?template=bug_report.yml) · [Berkontribusi](../../../AGENTS.md)

**Bahasa:** [English](../../../README.md) · [中文](../zh/README.md) · [हिन्दी](../hi/README.md) · [Español](../es/README.md) · [العربية](../ar/README.md) · [Français](../fr/README.md) · [বাংলা](../bn/README.md) · [Português](../pt/README.md) · [Bahasa Indonesia](../id/README.md) · [اردو](../ur/README.md) · [日本語](../ja/README.md) · [한국어](../ko/README.md) · [Русский](../ru/README.md)

## Lihat cara kerjanya

![Kontrol fokus Vidrado](../../../docs/screenshots/focus.png)

| Aturan app | Preferensi |
| --- | --- |
| ![Aturan app dengan ikon asli dalam skala abu-abu](../../../docs/screenshots/apps.png) | ![Preferensi dan perilaku otomatis](../../../docs/screenshots/preferences.png) |

## Fitur

- Pemburaman latar belakang secara langsung, peredupan, atau keduanya, dengan penggeser untuk menyesuaikan intensitas dengan cepat serta tingkat Ringan, Seimbang, dan Mendalam.
- Jendela aktif tetap jernih saat Anda berpindah app dan Spaces.
- Aturan per app: lembutkan jendela latar belakang secara otomatis, jaga suatu app tetap jernih, atau jeda fokus saat app tersebut aktif. Ikon app asli ditampilkan dalam skala abu-abu.
- Terapkan fokus pada semua layar atau hanya layar aktif; pertahankan jendela yang sejajar dan Split View.
- Jeda opsional saat layar penuh, berbagi layar, pengambilan gambar berkelanjutan, atau pencerminan layar.
- Pintasan global yang dapat disesuaikan, gestur menggoyangkan kursor yang opsional, dan peluncuran saat login.
- Preset tersimpan dan preferensi lokal.
- Tiga belas bahasa antarmuka. Vidrado mengikuti bahasa utama sistem Anda dan menggunakan bahasa Inggris jika bahasa tersebut tidak didukung. Bahasa Arab dan Urdu menggunakan tata letak dari kanan ke kiri.

## Instalasi

Memerlukan **macOS 14 atau yang lebih baru**. Unduh DMG dari [Releases](https://github.com/tonhadaplaces/vidrado/releases), buka, lalu seret **Vidrado** ke **Applications**.

Distribusi saat ini menggunakan **tanda tangan ad hoc** dan **belum dinotarisasi oleh Apple**. Jika macOS memblokir pembukaan app Vidrado yang Anda unduh dari repositori ini, hapus atribut karantina hanya dari app tersebut:

```sh
xattr -dr com.apple.quarantine /Applications/Vidrado.app
```

Lalu buka Vidrado kembali. Perintah ini tidak menotarisasi app atau mengubah pengaturan Gatekeeper di seluruh sistem. Anda dapat membangunnya secara lokal jika mau. DMG dari rilis otomatis mendukung **Apple silicon dan Intel**.

## Penggunaan

Klik ikon jendela yang saling tumpang tindih di menu bar untuk membuka kontrol fokus. **⌥⌘B** mengaktifkan atau menonaktifkan fokus dari mana saja. Klik kanan atau klik sambil menekan Option pada ikon menu bar juga akan mengaktifkan atau menonaktifkannya.

Buka preferensi dengan tombol penggeser atau **⌘,**. Pilih app di **Jaga beberapa app tetap jernih**. Penggeser efek tambahan, preset, dan gestur kursor tersedia di **Opsi lainnya**. Tutup jendela pengaturan dengan **⌘W**; Vidrado tetap berjalan di menu bar. **⌘Q** menutup app.

## Membangun dan menguji

Gunakan Xcode atau Command Line Tools dengan Swift 5.9 atau yang lebih baru:

```sh
git clone git@github.com:tonhadaplaces/vidrado.git
cd vidrado
swift run Vidrado --settings
./scripts/build.sh
swift test
./scripts/test.sh
./scripts/package.sh
```

`build.sh` membangun dan menandatangani `dist/Vidrado.app`. `package.sh` menghasilkan `dist/Vidrado.dmg` beserta checksum SHA-256-nya. Build secara default menargetkan arsitektur Mac yang digunakan. Gunakan `VIDRADO_UNIVERSAL=1 ./scripts/package.sh` untuk membangun bagi Apple silicon dan Intel.

`swift test` menjalankan pengujian inti XCTest. Skrip pengujian lengkap juga menjalankan pemeriksaan native dalam konfigurasi debug dan release. Pemeriksaan ini memerlukan sesi grafis yang tidak terkunci, jendela biasa di latar depan, dan Vidrado yang sudah dihentikan. GitHub CI menjalankan pengujian inti dan memverifikasi build app; pemeriksaan grafis dijalankan secara lokal.

Baca [Panduan Repositori](../../../AGENTS.md) dan [Catatan validasi](../../../TESTING.md) sebelum berkontribusi. Gunakan pull request: `main` memerlukan setidaknya satu persetujuan, CI yang lulus, dan semua diskusi peninjauan yang sudah diselesaikan.

## Rilis otomatis

Setelah perubahan yang telah ditinjau digabungkan ke `main`, perbarui `CFBundleShortVersionString` dan `CFBundleVersion` di `Resources/Info.plist` untuk versi baru, lalu push tag yang sesuai:

```sh
git switch main
git pull --ff-only origin main
git tag v1.0.0
git push origin v1.0.0
```

Ganti `1.0.0` dengan versi yang akan dirilis. GitHub Actions menguji kode, membangun app universal, memverifikasi bundel bertanda tangan dan DMG, lalu menerbitkan DMG beserta checksum SHA-256-nya. Alur kerja memeriksa bahwa tag berada di `main` dan cocok dengan versi app. Kredensial Apple Developer berbayar tidak diperlukan; rilis tetap memiliki keterbatasan tanda tangan ad hoc yang dijelaskan di atas.

## Privasi dan batasan teknis

Vidrado membaca metadata jendela dan menempatkan lapisan yang tidak dapat diinteraksikan di bawah jendela aktif. Kompositor macOS menerapkan efek pada konten latar belakang secara langsung. App ini tidak membaca dokumen Anda, mengambil frame layar, atau mengirim data melalui jaringan, dan tidak memerlukan izin Accessibility.

Pemburaman, pemotongan, deteksi berbagi layar, dan metadata Spaces menggunakan fungsi privat SkyLight yang ditemukan saat runtime. Ketersediaannya dapat berubah seiring pembaruan macOS, dan implementasi ini tidak sesuai untuk Mac App Store. Deteksi jendela yang ditata berdampingan menggunakan geometri. Efek ini bersifat visual dan bukan cara untuk menyembunyikan konten sensitif dalam rekaman.

## Lisensi dan kredit

[GNU AGPL-3.0](../../../LICENSE). Dibangun dengan Swift, SwiftUI, dan AppKit; tanpa dependensi runtime eksternal. Inter didistribusikan dengan [SIL Open Font License](../../../Sources/VidradoCore/Resources/Brand/Inter-OFL.txt). Ikon desain Lucide menggunakan lisensi ISC; lihat [Pemberitahuan pihak ketiga](../../../THIRD_PARTY_NOTICES.md).

Terinspirasi oleh [Defocus](https://defocus.me/). Vidrado merupakan implementasi independen dan tidak menggunakan kode sumber Defocus. Sumber antarmuka disertakan dalam repositori sebagai [`design.pen`](../../../design.pen).
