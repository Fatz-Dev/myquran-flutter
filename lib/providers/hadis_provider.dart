import 'package:flutter/material.dart';
import '../data/models/hadis_model.dart';
import '../data/models/perawi_model.dart';
import '../data/services/api_service.dart';
import '../data/services/hadis_service.dart';

class HadisProvider extends ChangeNotifier {
  final HadisService _hadisService = HadisService(ApiService());

  HadisModel? _randomHadis;
  List<HadisModel> _exploreList = [];
  List<HadisModel> _searchList = [];
  HadisModel? _detailHadis;
  List<PerawiModel> _perawiList = [];
  PerawiModel? _detailPerawi;
  bool _isLoading = false;
  String? _error;

  HadisModel? get randomHadis => _randomHadis;
  List<HadisModel> get exploreList => _exploreList;
  List<HadisModel> get searchList => _searchList;
  HadisModel? get detailHadis => _detailHadis;
  List<PerawiModel> get perawiList => _perawiList;
  PerawiModel? get detailPerawi => _detailPerawi;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadRandomHadis() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _randomHadis = await _hadisService.getRandomHadis();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadExplore() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      // Fetch 5 random hadis in parallel to populate the explore list
      final results = await Future.wait([
        _hadisService.getRandomHadis(),
        _hadisService.getRandomHadis(),
        _hadisService.getRandomHadis(),
        _hadisService.getRandomHadis(),
        _hadisService.getRandomHadis(),
      ]);
      _exploreList = results.whereType<HadisModel>().toList();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> searchKeyword(String keyword) async {
    if (keyword.isEmpty) {
      _searchList = [];
      notifyListeners();
      return;
    }
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _searchList = await _hadisService.searchHadis(keyword);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadDetail(int id) async {
    _isLoading = true;
    _error = null;
    _detailHadis = null;
    notifyListeners();
    try {
      _detailHadis = await _hadisService.getHadisDetail(id);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadPerawiBrowse() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _perawiList = await _hadisService.getPerawiBrowse();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadPerawiDetail(int id) async {
    _isLoading = true;
    _error = null;
    _detailPerawi = null;
    notifyListeners();
    try {
      _detailPerawi = await _hadisService.getPerawiDetail(id);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
