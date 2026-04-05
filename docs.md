<!-- ## Cara Menjalankan

Workflow `Start application` menjalankan:
```
flutter run -d web-server --web-port=5000 --web-hostname=0.0.0.0
``` -->
# MyQuran - Aplikasi Flutter

Aplikasi mobile Muslim berbasis Flutter yang menyediakan Al-Quran digital, koleksi Doa & Dzikir, dan Jadwal Shalat akurat.


**Catatan**: Aplikasi ini utamanya untuk Android & iOS. Preview web memerlukan WebGL. Untuk pengembangan mobile, gunakan `flutter run` dengan perangkat fisik atau emulator.

## Arsitektur

### Tech Stack
- **Framework**: Flutter 3.32 / Dart 3.8
- **State Management**: Provider
- **HTTP Client**: Dio
- **Audio**: just_audio + audio_session
- **Local Storage**: SharedPreferences
- **Routing**: GoRouter
- **Fonts**: Google Fonts (Poppins + Amiri untuk Arab)
- **Shimmer Loading**: shimmer

### Struktur Folder

```
lib/
  main.dart              # Entry point, Provider setup
  app.dart               # MaterialApp + GoRouter + ShellRoute
  core/
    theme/
      app_colors.dart    # Definisi warna dark/light mode
      app_theme.dart     # ThemeData dark & light
    constants/
      api_constants.dart # Base URLs & qari list
    utils/
      date_helper.dart   # Hijri date, countdown, formatting
  data/
    models/
      surah_model.dart   # SurahModel, AyahModel, SurahDetailModel, TafsirAyahModel
      doa_model.dart     # DoaModel
      prayer_model.dart  # ProvinceModel, CityModel, PrayerTimeModel
    services/
      api_service.dart   # Dio HTTP client wrapper
      quran_service.dart # Quran API calls
      doa_service.dart   # Doa API calls
      prayer_service.dart # Prayer schedule API calls
    local/
      preferences_service.dart # SharedPreferences wrapper
  providers/
    theme_provider.dart  # ThemeMode state
    quran_provider.dart  # Quran state (list, detail, search, tafsir)
    doa_provider.dart    # Doa state (list, detail, filter, search)
    prayer_provider.dart # Prayer state (provinces, cities, schedule)
    audio_provider.dart  # just_audio player state
  screens/
    splash/splash_screen.dart
    home/home_screen.dart
    quran/
      surah_list_screen.dart
      surah_detail_screen.dart
    doa/
      doa_list_screen.dart
      doa_detail_screen.dart
    prayer/prayer_screen.dart
    settings/settings_screen.dart
  widgets/
    common/
      shimmer_loading.dart
      error_state_widget.dart
    quran/
      surah_card.dart
      audio_player_bar.dart
```

## API Sources

- **Al-Quran**: `https://equran.id/api/v2/surat`
- **Doa**: `https://equran.id/api/doa`
- **Jadwal Shalat**: `https://equran.id/api/v2/shalat`

## Fitur MVP yang Diimplementasikan

1. **Al-Quran**
   - Daftar 114 surat dengan pencarian
   - Detail surat dengan teks Arab, transliterasi, terjemahan
   - Audio per ayat & full surat (6 pilihan qari)
   - Tafsir per ayat (toggle)
   - Copy ayat, simpan terakhir dibaca

2. **Doa & Dzikir**
   - Daftar 228+ doa dengan filter kategori & pencarian
   - Detail doa: Arab, Latin, terjemahan, referensi
   - Copy & share doa

3. **Jadwal Shalat**
   - Jadwal harian dengan 8 waktu shalat
   - Countdown shalat berikutnya (real-time)
   - Jadwal bulanan
   - Pilih lokasi (provinsi → kab/kota) via bottom sheet
   - Default: Batam, Kepulauan Riau

4. **Home Screen**
   - Greeting + tanggal Masehi & Hijriah
   - Quick cards: terakhir dibaca, countdown shalat, doa
   - Ayat harian
   - Shortcut menu utama

5. **Pengaturan**
   - Tema: Dark/Light/System
   - Pilih qari default (6 pilihan)
   - Info aplikasi

## Desain

- Dark mode sebagai default utama
- Warna primary: #00A651 (Islamic Green)
- Accent: #F0C12C (Gold)
- Font Arab: Amiri (Google Fonts)
- Font UI: Poppins
- Corner radius: 16px
- Bottom Navigation 5 tab

## Catatan Pengembangan

- SDK: `^3.8.0` (dikurangi dari `^3.10.8` untuk kompatibilitas Flutter 3.32 yang include Dart 3.8)
- `CardThemeData` (bukan `CardTheme`) untuk Flutter 3.32
- Flutter web berfungsi tapi tanpa WebGL akan render lambat; utamanya untuk Android/iOS
