import 'package:flutter/material.dart';
import '../data/models/bookmark_model.dart';
import '../data/local/preferences_service.dart';

class BookmarkProvider extends ChangeNotifier {
  final PreferencesService _prefs;

  List<AyahBookmark> _ayahBookmarks = [];
  List<DoaBookmark> _doaBookmarks = [];

  BookmarkProvider(this._prefs) {
    _load();
  }

  List<AyahBookmark> get ayahBookmarks => _ayahBookmarks;
  List<DoaBookmark> get doaBookmarks => _doaBookmarks;
  bool get hasBookmarks => _ayahBookmarks.isNotEmpty || _doaBookmarks.isNotEmpty;

  void _load() {
    _ayahBookmarks = _prefs.getAyahBookmarks();
    _doaBookmarks = _prefs.getDoaBookmarks();
  }

  bool isAyahBookmarked(int surahNomor, int ayahNomor) {
    return _ayahBookmarks
        .any((b) => b.surahNomor == surahNomor && b.ayahNomor == ayahNomor);
  }

  bool isDoaBookmarked(int doaId) {
    return _doaBookmarks.any((b) => b.doaId == doaId);
  }

  Future<void> toggleAyahBookmark(AyahBookmark bookmark) async {
    if (isAyahBookmarked(bookmark.surahNomor, bookmark.ayahNomor)) {
      await _prefs.removeAyahBookmark(bookmark.surahNomor, bookmark.ayahNomor);
    } else {
      await _prefs.addAyahBookmark(bookmark);
    }
    _ayahBookmarks = _prefs.getAyahBookmarks();
    notifyListeners();
  }

  Future<void> removeAyahBookmark(int surahNomor, int ayahNomor) async {
    await _prefs.removeAyahBookmark(surahNomor, ayahNomor);
    _ayahBookmarks = _prefs.getAyahBookmarks();
    notifyListeners();
  }

  Future<void> toggleDoaBookmark(DoaBookmark bookmark) async {
    if (isDoaBookmarked(bookmark.doaId)) {
      await _prefs.removeDoaBookmark(bookmark.doaId);
    } else {
      await _prefs.addDoaBookmark(bookmark);
    }
    _doaBookmarks = _prefs.getDoaBookmarks();
    notifyListeners();
  }

  Future<void> removeDoaBookmark(int doaId) async {
    await _prefs.removeDoaBookmark(doaId);
    _doaBookmarks = _prefs.getDoaBookmarks();
    notifyListeners();
  }
}
