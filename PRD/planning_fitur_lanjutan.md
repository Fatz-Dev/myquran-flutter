# 📋 Rekayasa Perencanaan: MyQuran V5 Lanjutan
**Tanggal Perencanaan:** 4 April 2026
**Fokus Utama:** UX Enhancement, AI Integration, Automation

---

## 📅 Fitur 1: Interactive Hijri/Masehi Calendar
**Tujuan Khusus:** Memberikan pengguna visibilitas sistem penanggalan universal yang sinkron 1:1 antara Gregorian dan Hijriah secara luring *(offline first)*.

### Architecture Design:
*   **Dependency/Package Flutter yang Dibutuhkan:**
    *   `table_calendar` (Untuk merender grid kalender multi-platform)
    *   `hijri` (Untuk algoritma perhitungan tanggal masehi ke hijri secara lokal tanpa delay API internet)
*   **Sistem Navigasi:** 
    *   Menambahkan `<GestureDetector>` / `<InkWell>` pada string teks kalender di `home_screen.dart` agar responsif terhadap sentuhan (menuju URI `/calendar`).
*   **Mekanisme Data:**
    *   Pemrosesan data tanggal murni dilakukan secara algoritmik *(client-side computation)*. Bebas hambatan API.

### Workflow:
1.  Ketuk tanggal Masehi / Hijriah di Beranda.
2.  Route transisi memunculkan *Calendar Screen*.
3.  Scroll/Swipe per bulan akan otomatis memicu update tanggalan Hijriah yang tersinkronasi.

---

## 🤖 Fitur 2: Al-Quran Semantic Search (Natural Language AI)
**Tujuan Khusus:** Meruntuhkan batasan pencarian konvensional (mencari surah harus dengan nama). Pengguna diperbolehkan curhat/mengetikkan perasaan/situasi, dan aplikasi mencari ayat penawar yang sesuai.

### Architecture Design:
*   **Vendor API:** Endpoint Vektor Equran ( `https://equran.id/api/vector` )
*   **Persiapan Core/Lapisan Bawah:**
    *   Penambahan method `searchSemantic(String prompt)` yang membungkus tipe protokol `HTTP POST` pada *class* `ApiService`.
    *   Parsing struktur JSON yang spesifik untuk model vektor (membutuhkan filter kecocokan skoring persentase/probabilitas).

### User Interface Mapping:
*   Refactor / Tata ulang layar "Cari Surat" saat ini menjadi sistem berlapis ganda *(Tabbar)*.
*   **Tab 1 (Konvensional):** *Scroll* ke bawah dan filter secara abjad alfabet.
*   **Tab 2 (Mode ChatGPT):** Ruang kosong dengan kotak pencarian besar di bagian bawah. "Apa yang sedang Anda rasakan hari ini?" -> *Enter* -> Muncul kumpulan kartu ayat yang relevan beserta tombol pemutar audio.

---

## 📍 Fitur 3: GPS Auto-Location untuk Algoritma Shalat
**Tujuan Khusus:** Menghapus beban konfig manual pengguna saat bepergian ke luar kota. Aplikasi menyesuaikan zona waktu shalat secara cerdas mengikuti perpindahan GPS HP.

### Architecture Design:
*   **Dependency/Package Flutter yang Dibutuhkan:**
    *   `geolocator`: Sistem kompas penangkap koordinat dasar darat Latitude/Longitude sistem Handphone.
    *   `geocoding`: Transmiter ke pemetaan Google Maps untuk mengenali "Koordinat X,Y mengarah ke Kota Z".
*   **Modifikasi Permission (Krusial):**
    *   Native Android: Menambahkan `<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />` pada `AndroidManifest.xml`

### Execution System:
1.  **Izin Akses:** Sistem harus mendeteksi apakah izin *location* menyala (Jika denied, biarkan Batam sebaga fallback).
2.  **Reverse Geocoding:** Merubah koordinat numerik menjadi Teks string "Kota XYZ".
3.  **Rekonsiliasi (Sangat Penting):** String "Kota XYZ" dari HP tidak bisa digunakan langsung. Harus disepadankan melalu API myquran `https://api.myquran.com/v2/sholat/kota/cari/{NamaKota}` untuk mendapatkan kunci **ID KOTA (Contoh: 1301 untuk gresik)**.
4.  **Eksekusi Akhir:** ID Kota didapat -> Inject ke method `.loadSchedule(id)` -> Save ID ke `SharedPreferences` (database cache).

---
*Perencanaan ini sudah berstatus "Siap Dikerjakan" (Actionable).*
