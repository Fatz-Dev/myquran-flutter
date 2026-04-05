**Product Requirements Document (PRD)**  
**MyQuran – Aplikasi Flutter**  
**Versi 1.0**  
**Tanggal:** 4 April 2026  

### 1. Pendahuluan
**MyQuran** adalah aplikasi mobile berbasis Flutter yang menyediakan tiga fitur utama:  
- **Al-Quran Digital**  
- **Koleksi Doa & Dzikir**  
- **Jadwal Shalat**  

Semua data diambil secara real-time dari API resmi equran.id (tanpa fitur login/authentication). Aplikasi dirancang sederhana, ringan, dan fokus pada kemudahan penggunaan bagi umat Muslim di Indonesia.

**Platform:** Flutter (cross-platform Android & iOS)  
**Base URL API:**  
- Al-Quran → `https://equran.id/api/v2`  
- Doa → `https://equran.id/api/doa`  
- Jadwal Shalat → `https://equran.id/api/v2/shalat`

### 2. Tujuan Produk
- Memberikan akses cepat dan nyaman ke Al-Quran lengkap dengan audio.
- Menyediakan koleksi doa & dzikir sehari-hari dalam bahasa Arab + terjemahan Indonesia.
- Menampilkan jadwal shalat akurat untuk seluruh wilayah Indonesia.
- Tidak ada autentikasi/login agar aplikasi tetap ringan dan privasi pengguna terjaga.
- Target: 100% fungsional dengan data API tanpa ketergantungan akun.

### 3. Target Pengguna
- Umat Muslim di Indonesia (usia 13 tahun ke atas).
- Pemula hingga rutin membaca Quran.
- Pengguna yang menginginkan aplikasi sederhana tanpa fitur sosial/login.

### 4. Fitur Utama (Functional Requirements)

#### 4.1. Modul Al-Quran (Menggunakan https://equran.id/api/v2)
- **Daftar Surat**  
  - Tampilkan 114 surat (GET `/api/v2/surat`).  
  - Informasi: nomor surat, nama Arab, nama Latin, jumlah ayat, tempat turun, arti.  
  - Pencarian lokal (client-side search) berdasarkan nama surat.

- **Detail Surat**  
  - GET `/api/v2/surat/{nomor}` → tampilkan semua ayat.  
  - Tampilan:  
    - Teks Arab  
    - Terjemahan Bahasa Indonesia  
    - Transliterasi Latin (jika tersedia di response)  
  - Fitur audio:  
    - Pilih 6 qari (Abdullah Al-Juhany, Abdul Muhsin Al-Qasim, Abdurrahman As-Sudais, Ibrahim Al-Dossari, Misyari Rasyid Al-Afasy, Yasser Al-Dosari).  
    - Putar audio per ayat atau full surat (MP3 dari CDN).  
    - Player dengan progress bar, tombol play/pause/next/previous.

- **Tafsir**  
  - GET `/api/v2/tafsir/{nomor}` → tampilkan tafsir lengkap surat.

- **Bookmark Ayat** (disimpan lokal via SharedPreferences / Hive).

#### 4.2. Modul Doa & Dzikir (Menggunakan https://equran.id/api/doa)
- **Daftar Doa**  
  - GET `/api/doa` → tampilkan 228 doa.  
  - Filter:  
    - `grup` (kategori)  
    - `tag` (multi-select, contoh: tidur, malam, pagi, dll.)  
  - Pencarian lokal berdasarkan teks Arab / terjemahan.

- **Detail Doa**  
  - GET `/api/doa/{id}`  
  - Tampilan:  
    - Teks Arab lengkap dengan harakat  
    - Transliterasi Latin  
    - Terjemahan Bahasa Indonesia  
    - Referensi sumber hadits  
    - Tombol Share (teks + terjemahan)

#### 4.3. Modul Jadwal Shalat (Menggunakan https://equran.id/api/v2/shalat)
- **Pilih Lokasi** (disimpan lokal)  
  1. Pilih Provinsi → GET `/api/v2/shalat/provinsi`  
  2. Pilih Kabupaten/Kota → POST `/api/v2/shalat/kabkota` (body: `{ "provinsi": "..." }`)

- **Jadwal Harian**  
  - Tampilkan waktu shalat hari ini (Imsak, Subuh, Terbit, Dhuha, Dzuhur, Ashar, Maghrib, Isya).  
  - Hitung waktu tersisa hingga shalat berikutnya (countdown).

- **Jadwal Bulanan**  
  - POST `/api/v2/shalat` → tampilkan jadwal 1 bulan penuh (default bulan & tahun sekarang).  
  - Tampilan kalender atau list tanggal.

- **Default Lokasi**  
  - Saat pertama buka, arahkan ke provinsi & kab/kota terakhir yang dipilih (atau default Batam jika belum pernah pilih).

### 5. Fitur Pendukung (General Features)
| Fitur | Deskripsi | Penyimpanan |
|-------|---------|-------------|
| Bottom Navigation | Home, Quran, Doa, Shalat, Pengaturan | - |
| Home Screen | Quick access: ayat hari ini, doa harian, jadwal shalat hari ini, last read | Lokal |
| Tema | Light & Dark (Islamic green accent) | Lokal |
| Pengaturan | Pilih qari default, notifikasi shalat (optional), tentang aplikasi | Lokal |
| Cache Data | Simpan response API sementara (Hive atau SQLite) agar lebih cepat | Lokal |
| Offline Mode | Tampilkan data cache terakhir (jika tersedia) | Lokal |

### 6. Non-Functional Requirements
- **Performa**: Loading < 2 detik untuk semua screen utama.
- **Ukuran App**: Target < 25 MB (APK/AAB).
- **Bahasa**: Bahasa Indonesia 100%.
- **Aksesibilitas**: Support TalkBack / VoiceOver.
- **Error Handling**: Tampilkan pesan ramah jika API down atau no internet.
- **Notifikasi**: Opsional (local notification untuk waktu shalat menggunakan flutter_local_notifications).
- **Tidak ada**: Login, user account, cloud sync, in-app purchase, iklan.

### 7. Technical Requirements
- **Framework**: Flutter (latest stable).
- **State Management**: Riverpod atau Provider (disarankan).
- **HTTP Client**: dio.
- **Audio Player**: just_audio + audio_session.
- **Local Storage**: Hive (rekomendasi) atau SharedPreferences + sqlite.
- **Routing**: GoRouter.
- **Dependency Injection**: get_it (opsional).
- **API Call**: Semua request menggunakan base URL yang sudah disebutkan.


### 8. Out of Scope (Tidak Termasuk)
- Fitur login / autentikasi.
- Penyimpanan data di cloud.
- Pencarian global Quran (karena API tidak menyediakan endpoint search).
- Deteksi lokasi otomatis via GPS (hanya manual pilih provinsi/kabkota).
- Mode hafalan / tajwid.
- Fitur sosial / komunitas.

### 9. Prioritas Fitur (MVP)
**MVP (Minimal Viable Product)**:
1. Daftar & Detail Surat + Audio
2. Daftar & Detail Doa
3. Pilih lokasi + Jadwal Shalat harian & bulanan
4. Home Screen + Bottom Navigation

**Phase 2** (setelah MVP):
- Bookmark ayat
- Cache offline
- Notifikasi shalat
- Tafsir lengkap
- Player improvement + qari switcher
