# ICT IPB Flutter Demo

Mini project Flutter untuk submission posisi developer IPB ICT.

## Fitur Utama

- Autentikasi pengguna dengan Firebase Auth (login, register, logout)
- Manajemen state menggunakan BLoC + Hydrated BLoC
- Pengaturan tema (light/dark) yang tersimpan
- Pengaturan bahasa aplikasi (lokalisasi)
- Halaman profil dan pengaturan
- Integrasi data cuaca dari Open-Meteo API

## Tech Stack

- Flutter (Dart SDK `^3.11.1`)
- Firebase Core + Firebase Auth
- flutter_bloc + hydrated_bloc
- HTTP client (`http`)

## Struktur Folder Inti

```text
lib/
  bloc/         # State management (auth, theme, language, weather)
  pages/        # Halaman UI (login, register, home, profile, setting)
  services/     # Integrasi Firebase Auth & weather API
  models/       # Model data cuaca dan lokasi
  theme/        # Konfigurasi tema aplikasi
  l10n/         # Lokalisasi
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

4. Jalankan aplikasi:

```bash
flutter run
```

## Catatan

- Pastikan Flutter SDK dan platform toolchain (Android/iOS/Web/Desktop) sudah terpasang.
- Data cuaca menggunakan endpoint publik Open-Meteo, sehingga tidak membutuhkan API key.

## Git Remote

Remote `origin` sudah diarahkan ke:

```bash
https://github.com/muhammadfirzakrizki/ict-ipb-flutter-demo.git
```

## Langkah Push Pertama

```bash
git add .
git commit -m "Initial commit: ICT IPB Flutter demo"
git push -u origin main
```
