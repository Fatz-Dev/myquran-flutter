import 'package:flutter/material.dart';
import '../data/models/history_model.dart';
import '../data/local/preferences_service.dart';

class HistoryProvider extends ChangeNotifier {
  final PreferencesService _prefs;
  List<ReadingHistory> _history = [];

  HistoryProvider(this._prefs) {
    _load();
  }

  List<ReadingHistory> get history => _history;
  bool get hasHistory => _history.isNotEmpty;
  ReadingHistory? get lastRead => _history.isNotEmpty ? _history.first : null;

  void _load() {
    _history = _prefs.getHistory();
  }

  Future<void> addOrUpdate({
    required int nomor,
    required String namaLatin,
    required String nama,
    required String arti,
    required int lastAyah,
    required int jumlahAyat,
  }) async {
    final item = ReadingHistory(
      nomor: nomor,
      namaLatin: namaLatin,
      nama: nama,
      arti: arti,
      lastAyah: lastAyah,
      jumlahAyat: jumlahAyat,
      timestamp: DateTime.now(),
    );
    await _prefs.addToHistory(item);
    _history = _prefs.getHistory();
    notifyListeners();
  }

  Future<void> updateLastAyah(int surahNomor, int ayahNomor) async {
    await _prefs.updateHistoryAyah(surahNomor, ayahNomor);
    _history = _prefs.getHistory();
    notifyListeners();
  }

  Future<void> clearHistory() async {
    await _prefs.clearHistory();
    _history = [];
    notifyListeners();
  }
}
