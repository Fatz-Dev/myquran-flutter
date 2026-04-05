import 'package:flutter/material.dart';
import '../data/models/surah_model.dart';
import '../data/services/quran_service.dart';

class QuranProvider extends ChangeNotifier {
  final QuranService _service;

  List<SurahModel> _suratList = [];
  List<SurahModel> _filteredList = [];
  SurahDetailModel? _currentSurah;
  List<TafsirAyahModel> _tafsirList = [];
  bool _isLoadingList = false;
  bool _isLoadingDetail = false;
  bool _isLoadingTafsir = false;
  String? _errorList;
  String? _errorDetail;
  String _searchQuery = '';
  List<SemanticResultModel> _semanticResults = [];
  bool _isSemanticLoading = false;

  QuranProvider(this._service);

  List<SurahModel> get suratList => _filteredList;
  SurahDetailModel? get currentSurah => _currentSurah;
  List<TafsirAyahModel> get tafsirList => _tafsirList;
  List<SemanticResultModel> get semanticResults => _semanticResults;
  bool get isLoadingList => _isLoadingList;
  bool get isLoadingDetail => _isLoadingDetail;
  bool get isLoadingTafsir => _isLoadingTafsir;
  bool get isSemanticLoading => _isSemanticLoading;
  String? get errorList => _errorList;
  String? get errorDetail => _errorDetail;
  String get searchQuery => _searchQuery;

  Future<void> searchSemantic(String query) async {
    if (query.isEmpty) {
      _semanticResults = [];
      notifyListeners();
      return;
    }
    _isSemanticLoading = true;
    notifyListeners();
    try {
      _semanticResults = await _service.semanticSearch(query);
      debugPrint('AI Search Results: ${_semanticResults.length} found');
      if (_semanticResults.isNotEmpty) {
        debugPrint('First result: ${_semanticResults.first.surahName} ${_semanticResults.first.ayah}');
      }
    } catch (e) {
      debugPrint('AI Search Error: $e');
      _semanticResults = [];
    } finally {
      _isSemanticLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadSuratList() async {
    if (_suratList.isNotEmpty) return;
    _isLoadingList = true;
    _errorList = null;
    notifyListeners();
    try {
      _suratList = await _service.getSuratList();
      _filteredList = List.from(_suratList);
    } catch (e) {
      _errorList = e.toString();
    } finally {
      _isLoadingList = false;
      notifyListeners();
    }
  }

  void search(String query) {
    _searchQuery = query;
    if (query.isEmpty) {
      _filteredList = List.from(_suratList);
    } else {
      final q = query.toLowerCase();
      _filteredList = _suratList.where((s) {
        return s.namaLatin.toLowerCase().contains(q) ||
            s.arti.toLowerCase().contains(q) ||
            s.nomor.toString().contains(q) ||
            s.nama.contains(query);
      }).toList();
    }
    notifyListeners();
  }

  Future<void> loadSurahDetail(int nomor) async {
    _isLoadingDetail = true;
    _errorDetail = null;
    _currentSurah = null;
    notifyListeners();
    try {
      _currentSurah = await _service.getSurahDetail(nomor);
    } catch (e) {
      _errorDetail = e.toString();
    } finally {
      _isLoadingDetail = false;
      notifyListeners();
    }
  }

  /// Ambil teks tafsir untuk satu ayat dari list yang sudah di-load.
  String? getTafsir(int nomorAyat) {
    try {
      return _tafsirList.firstWhere((t) => t.ayat == nomorAyat).teks;
    } catch (_) {
      return null;
    }
  }

  Future<void> loadTafsir(int nomor) async {
    _isLoadingTafsir = true;
    _tafsirList = [];
    notifyListeners();
    try {
      _tafsirList = await _service.getTafsir(nomor);
    } catch (_) {
      _tafsirList = [];
    } finally {
      _isLoadingTafsir = false;
      notifyListeners();
    }
  }
}
