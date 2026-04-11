# ICT IPB Flutter Demo (Android Only)

Mini project Flutter untuk submission posisi developer IPB ICT dengan target upload khusus Android.

## Fitur Utama

- Autentikasi pengguna dengan Firebase Auth (login, register, logout)
- Manajemen state modern menggunakan Riverpod
- Pengaturan tema (light/dark) yang tersimpan
- Pengaturan bahasa aplikasi (lokalisasi)
- Halaman profil dan pengaturan
- Integrasi data cuaca dari Open-Meteo API

## Tech Stack

- Flutter (Dart SDK `^3.11.1`)
- Firebase Core + Firebase Auth
- flutter_riverpod + shared_preferences
- HTTP client (`http`)

## Struktur Folder Inti

```text
lib/
  core/         # Kode lintas fitur: widgets, theme, l10n, utils
    router/     # GoRouter route constants dan router provider
  features/     # Clean Architecture per fitur
    auth/
      application/  # Riverpod controller/provider
      data/         # Repository implementation dan datasource Firebase
      domain/       # Repository contract dan state
      presentation/ # Pages dan widget UI auth
    settings/
      application/  # Riverpod controller/provider
      data/         # Persistensi SharedPreferences
      domain/       # Entity dan repository contract
      presentation/ # Pages dan widget UI settings
    weather/
      application/  # Riverpod controller/provider
      data/         # Repository implementation dan datasource Open-Meteo
      domain/       # Entity, state, dan repository contract
      presentation/ # Pages dan widget UI weather
```

## Setup Project

1. Clone repository:

```bash
git clone https://github.com/muhammadfirzakrizki/ict-ipb-flutter-demo.git
cd ict-ipb-flutter-demo
```

2. Install dependencies:

```bash
flutter pub get
```

3. Konfigurasi Firebase (jika ingin pakai project Firebase sendiri):

```bash
flutterfire configure
```

4. Jalankan aplikasi Android:

```bash
flutter run
```

## Build APK Release

```bash
flutter build apk --release
```

APK release hasil build tersedia di:

```text
build/app/outputs/apk/release/app-release.apk
```

Untuk upload artifact ke GitHub, file APK juga disalin ke:

```text
releases/app-release.apk
```

## Catatan

- Pastikan Flutter SDK dan Android toolchain sudah terpasang.
- Data cuaca menggunakan endpoint publik Open-Meteo, sehingga tidak membutuhkan API key.
- Folder platform non-Android (`ios`, `web`, `windows`, `macos`, `linux`) diabaikan lewat `.gitignore`.

## Git Remote

Remote `origin` sudah diarahkan ke:

```bash
https://github.com/muhammadfirzakrizki/ict-ipb-flutter-demo.git
```

## Commit dan Push

```bash
git add .
git commit -m "Configure Android-only repo and add release APK"
git push -u origin main
```
