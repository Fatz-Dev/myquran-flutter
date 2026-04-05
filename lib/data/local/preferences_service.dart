import 'package:shared_preferences/shared_preferences.dart';
import '../models/history_model.dart';
import '../models/bookmark_model.dart';

class PreferencesService {
  static const String _themeKey = 'theme_mode';
  static const String _qariKey = 'selected_qari';
  static const String _lastReadSurahKey = 'last_read_surah';
  static const String _lastReadAyahKey = 'last_read_ayah';
  static const String _lastReadNameKey = 'last_read_name';
  static const String _provinceIdKey = 'province_id';
  static const String _provinceNameKey = 'province_name';
  static const String _cityIdKey = 'city_id';
  static const String _cityNameKey = 'city_name';
  static const String _historyKey = 'reading_history';
  static const String _ayahBookmarksKey = 'ayah_bookmarks';
  static const String _doaBookmarksKey = 'doa_bookmarks';
  static const String _notifImsakKey = 'notif_imsak';
  static const String _notifSubuhKey = 'notif_subuh';
  static const String _notifDzuhurKey = 'notif_dzuhur';
  static const String _notifAsharKey = 'notif_ashar';
  static const String _notifMaghribKey = 'notif_maghrib';
  static const String _notifIsyaKey = 'notif_isya';

  final SharedPreferences _prefs;

  PreferencesService(this._prefs);

  static Future<PreferencesService> create() async {
    final prefs = await SharedPreferences.getInstance();
    return PreferencesService(prefs);
  }

  // Theme
  String getThemeMode() => _prefs.getString(_themeKey) ?? 'dark';
  Future<void> setThemeMode(String mode) => _prefs.setString(_themeKey, mode);

  // Qari
  String getSelectedQari() => _prefs.getString(_qariKey) ?? '05';
  Future<void> setSelectedQari(String qariId) =>
      _prefs.setString(_qariKey, qariId);

  // Last Read
  int? getLastReadSurah() => _prefs.getInt(_lastReadSurahKey);
  int? getLastReadAyah() => _prefs.getInt(_lastReadAyahKey);
  String? getLastReadName() => _prefs.getString(_lastReadNameKey);

  Future<void> setLastRead(
      int surahNomor, int ayahNomor, String surahName) async {
    await _prefs.setInt(_lastReadSurahKey, surahNomor);
    await _prefs.setInt(_lastReadAyahKey, ayahNomor);
    await _prefs.setString(_lastReadNameKey, surahName);
  }

  // Location
  String getProvinceId() => _prefs.getString(_provinceIdKey) ?? '9';
  String getProvinceName() =>
      _prefs.getString(_provinceNameKey) ?? 'Kepulauan Riau';
  String getCityId() => _prefs.getString(_cityIdKey) ?? '231';
  String getCityName() => _prefs.getString(_cityNameKey) ?? 'Kota Batam';

  Future<void> setLocation({
    required String provinceId,
    required String provinceName,
    required String cityId,
    required String cityName,
  }) async {
    await _prefs.setString(_provinceIdKey, provinceId);
    await _prefs.setString(_provinceNameKey, provinceName);
    await _prefs.setString(_cityIdKey, cityId);
    await _prefs.setString(_cityNameKey, cityName);
  }

  // ─── Reading History ───────────────────────────────────
  List<ReadingHistory> getHistory() {
    final json = _prefs.getString(_historyKey) ?? '[]';
    return ReadingHistory.listFromJson(json);
  }

  Future<void> addToHistory(ReadingHistory item) async {
    var list = getHistory();
    list.removeWhere((h) => h.nomor == item.nomor);
    list.insert(0, item);
    if (list.length > 10) list = list.sublist(0, 10);
    await _prefs.setString(_historyKey, ReadingHistory.listToJson(list));
  }

  Future<void> updateHistoryAyah(int surahNomor, int ayahNomor) async {
    final list = getHistory();
    final idx = list.indexWhere((h) => h.nomor == surahNomor);
    if (idx >= 0) {
      final old = list[idx];
      list[idx] = ReadingHistory(
        nomor: old.nomor,
        namaLatin: old.namaLatin,
        nama: old.nama,
        arti: old.arti,
        lastAyah: ayahNomor,
        jumlahAyat: old.jumlahAyat,
        timestamp: DateTime.now(),
      );
      await _prefs.setString(_historyKey, ReadingHistory.listToJson(list));
    }
  }

  Future<void> clearHistory() async {
    await _prefs.remove(_historyKey);
  }

  // ─── Ayah Bookmarks ────────────────────────────────────
  List<AyahBookmark> getAyahBookmarks() {
    final json = _prefs.getString(_ayahBookmarksKey) ?? '[]';
    return AyahBookmark.listFromJson(json);
  }

  bool isAyahBookmarked(int surahNomor, int ayahNomor) {
    return getAyahBookmarks()
        .any((b) => b.surahNomor == surahNomor && b.ayahNomor == ayahNomor);
  }

  Future<void> addAyahBookmark(AyahBookmark bookmark) async {
    final list = getAyahBookmarks();
    list.removeWhere((b) => b.id == bookmark.id);
    list.insert(0, bookmark);
    await _prefs.setString(_ayahBookmarksKey, AyahBookmark.listToJson(list));
  }

  Future<void> removeAyahBookmark(int surahNomor, int ayahNomor) async {
    final list = getAyahBookmarks();
    list.removeWhere(
        (b) => b.surahNomor == surahNomor && b.ayahNomor == ayahNomor);
    await _prefs.setString(_ayahBookmarksKey, AyahBookmark.listToJson(list));
  }

  // ─── Doa Bookmarks ─────────────────────────────────────
  List<DoaBookmark> getDoaBookmarks() {
    final json = _prefs.getString(_doaBookmarksKey) ?? '[]';
    return DoaBookmark.listFromJson(json);
  }

  bool isDoaBookmarked(int doaId) {
    return getDoaBookmarks().any((b) => b.doaId == doaId);
  }

  Future<void> addDoaBookmark(DoaBookmark bookmark) async {
    final list = getDoaBookmarks();
    list.removeWhere((b) => b.doaId == bookmark.doaId);
    list.insert(0, bookmark);
    await _prefs.setString(_doaBookmarksKey, DoaBookmark.listToJson(list));
  }

  Future<void> removeDoaBookmark(int doaId) async {
    final list = getDoaBookmarks();
    list.removeWhere((b) => b.doaId == doaId);
    await _prefs.setString(_doaBookmarksKey, DoaBookmark.listToJson(list));
  }

  // ─── Notification Settings ─────────────────────────────
  bool getNotifEnabled(String prayer) {
    switch (prayer) {
      case 'Imsak': return _prefs.getBool(_notifImsakKey) ?? false;
      case 'Subuh': return _prefs.getBool(_notifSubuhKey) ?? true;
      case 'Dzuhur': return _prefs.getBool(_notifDzuhurKey) ?? true;
      case 'Ashar': return _prefs.getBool(_notifAsharKey) ?? true;
      case 'Maghrib': return _prefs.getBool(_notifMaghribKey) ?? true;
      case 'Isya': return _prefs.getBool(_notifIsyaKey) ?? false;
      default: return false;
    }
  }

  Future<void> setNotifEnabled(String prayer, bool enabled) async {
    switch (prayer) {
      case 'Imsak': await _prefs.setBool(_notifImsakKey, enabled); break;
      case 'Subuh': await _prefs.setBool(_notifSubuhKey, enabled); break;
      case 'Dzuhur': await _prefs.setBool(_notifDzuhurKey, enabled); break;
      case 'Ashar': await _prefs.setBool(_notifAsharKey, enabled); break;
      case 'Maghrib': await _prefs.setBool(_notifMaghribKey, enabled); break;
      case 'Isya': await _prefs.setBool(_notifIsyaKey, enabled); break;
    }
  }
}
