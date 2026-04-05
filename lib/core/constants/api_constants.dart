class ApiConstants {
  static const String quranBaseUrl = 'https://equran.id/api/v2';
  static const String doaBaseUrl = 'https://equran.id/api';
  static const String prayerBaseUrl = 'https://equran.id/api/v2';

  // Quran
  static const String suratEndpoint = '/surat';
  static const String tafsirEndpoint = '/tafsir';

  // Doa
  static const String doaEndpoint = '/doa';

  // Shalat
  static const String provincesEndpoint = '/shalat/provinsi';
  static const String citiesEndpoint = '/shalat/kabkota';
  static const String prayerScheduleEndpoint = '/shalat';

  // Qari options
  static const List<Map<String, String>> qariList = [
    {'id': '01', 'name': 'Abdullah Al-Juhany'},
    {'id': '02', 'name': 'Abdul Muhsin Al-Qasim'},
    {'id': '03', 'name': 'Abdurrahman As-Sudais'},
    {'id': '04', 'name': 'Ibrahim Al-Dossari'},
    {'id': '05', 'name': 'Misyari Rasyid Al-Afasy'},
    {'id': '06', 'name': 'Yasser Al-Dosari'},
  ];
}
