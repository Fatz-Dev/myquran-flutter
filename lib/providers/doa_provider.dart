import 'package:flutter/material.dart';
import '../data/models/doa_model.dart';
import '../data/services/doa_service.dart';

class DoaProvider extends ChangeNotifier {
  final DoaService _service;

  List<DoaModel> _doaList = [];
  List<DoaModel> _filteredList = [];
  DoaModel? _currentDoa;
  bool _isLoadingList = false;
  bool _isLoadingDetail = false;
  String? _errorList;
  String? _errorDetail;
  String _searchQuery = '';
  String _selectedFilter = 'Semua';

  DoaProvider(this._service);

  List<DoaModel> get doaList => _filteredList;
  DoaModel? get currentDoa => _currentDoa;
  bool get isLoadingList => _isLoadingList;
  bool get isLoadingDetail => _isLoadingDetail;
  String? get errorList => _errorList;
  String? get errorDetail => _errorDetail;
  String get selectedFilter => _selectedFilter;

  List<String> get categories {
    final Set<String> cats = {'Semua'};
    for (final d in _doaList) {
      if (d.grup != null && d.grup!.isNotEmpty) cats.add(d.grup!);
    }
    return cats.toList();
  }

  Future<void> loadDoaList() async {
    if (_doaList.isNotEmpty) return;
    _isLoadingList = true;
    _errorList = null;
    notifyListeners();
    try {
      _doaList = await _service.getDoaList();
      _applyFilter();
    } catch (e) {
      _errorList = e.toString();
    } finally {
      _isLoadingList = false;
      notifyListeners();
    }
  }

  void search(String query) {
    _searchQuery = query;
    _applyFilter();
    notifyListeners();
  }

  void setFilter(String filter) {
    _selectedFilter = filter;
    _applyFilter();
    notifyListeners();
  }

  void _applyFilter() {
    var list = List<DoaModel>.from(_doaList);
    if (_selectedFilter != 'Semua') {
      list = list.where((d) => d.grup == _selectedFilter).toList();
    }
    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      list = list.where((d) {
        return d.judul.toLowerCase().contains(q) ||
            d.terjemahan.toLowerCase().contains(q) ||
            d.arab.contains(_searchQuery);
      }).toList();
    }
    _filteredList = list;
  }

  Future<void> loadDoaDetail(int id) async {
    _isLoadingDetail = true;
    _errorDetail = null;
    notifyListeners();
    try {
      _currentDoa = await _service.getDoaDetail(id);
    } catch (e) {
      _errorDetail = e.toString();
    } finally {
      _isLoadingDetail = false;
      notifyListeners();
    }
  }
}
