import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import '../data/models/prayer_model.dart';
import '../data/services/prayer_service.dart';
import '../data/local/preferences_service.dart';
import '../core/utils/date_helper.dart';

class PrayerProvider extends ChangeNotifier {
  final PrayerService _service;
  final PreferencesService _prefs;

  List<ProvinceModel> _provinces = [];
  List<CityModel> _cities = [];
  List<CityModel> _filteredCities = [];
  List<PrayerTimeModel> _monthlySchedule = [];
  PrayerTimeModel? _todaySchedule;

  String _searchCityQuery = '';
  String _selectedProvinceId = '';
  String _selectedProvinceName = '';
  String _selectedCityId = '';
  String _selectedCityName = '';

  bool _isLoadingProvinces = false;
  bool _isLoadingCities = false;
  bool _isLoadingSchedule = false;
  String? _error;

  PrayerProvider(this._service, this._prefs) {
    _selectedProvinceId = _prefs.getProvinceId();
    _selectedProvinceName = _prefs.getProvinceName();
    _selectedCityId = _prefs.getCityId();
    _selectedCityName = _prefs.getCityName();
    if (_selectedCityId.isNotEmpty) {
      loadSchedule();
    }
  }

  List<ProvinceModel> get provinces => _provinces;
  List<CityModel> get cities => _searchCityQuery.isEmpty ? _cities : _filteredCities;
  List<PrayerTimeModel> get monthlySchedule => _monthlySchedule;
  PrayerTimeModel? get todaySchedule => _todaySchedule;
  bool get isLoadingProvinces => _isLoadingProvinces;
  bool get isLoadingCities => _isLoadingCities;
  bool get isLoadingSchedule => _isLoadingSchedule;
  String? get error => _error;
  String get selectedProvinceName => _selectedProvinceName;
  String get selectedCityName => _selectedCityName;
  String get selectedProvinceId => _selectedProvinceId;
  String get selectedCityId => _selectedCityId;

  Future<void> loadProvinces() async {
    _isLoadingProvinces = true;
    _error = null;
    notifyListeners();
    try {
      _provinces = await _service.getProvinces();
    } catch (e) {
      _error = 'Gagal memuat daftar lokasi';
    } finally {
      _isLoadingProvinces = false;
      notifyListeners();
    }
  }

  void searchCity(String query) {
    _searchCityQuery = query;
    if (query.isEmpty) {
      _filteredCities = [];
    } else {
      _filteredCities = _cities
          .where((CityModel c) => c.name.toLowerCase().contains(query.toLowerCase()))
          .toList();
    }
    notifyListeners();
  }

  Future<void> loadCities(String provinceId) async {
    _isLoadingCities = true;
    _cities = [];
    _searchCityQuery = '';
    notifyListeners();
    try {
      _cities = await _service.getCities(provinceId);
    } catch (e) {
      _error = 'Gagal memuat kota';
    } finally {
      _isLoadingCities = false;
      notifyListeners();
    }
  }

  Future<void> selectProvince(ProvinceModel province) async {
    _selectedProvinceId = province.id;
    _selectedProvinceName = province.name;
    _selectedCityId = '';
    _selectedCityName = '';
    notifyListeners();
    await loadCities(province.id);
  }

  Future<void> selectCity(CityModel city) async {
    _selectedCityId = city.id;
    _selectedCityName = city.name;
    await _prefs.setLocation(
      provinceId: _selectedProvinceId,
      provinceName: _selectedProvinceName,
      cityId: city.id,
      cityName: city.name,
    );
    notifyListeners();
    await loadSchedule();
  }

  Future<void> loadSchedule() async {
    if (_selectedCityId.isEmpty) return;
    _isLoadingSchedule = true;
    _error = null;
    notifyListeners();
    try {
      _monthlySchedule = await _service.getMonthlySchedule(
        cityId: _selectedCityId,
        year: DateHelper.getCurrentYear(),
        month: DateHelper.getCurrentMonthNumber(),
      );
      _findTodaySchedule();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoadingSchedule = false;
      notifyListeners();
    }
  }

  void _findTodaySchedule() {
    final today = DateTime.now().day;
    try {
      _todaySchedule = _monthlySchedule.firstWhere(
        (PrayerTimeModel p) {
          final parts = p.tanggal.split('-');
          if (parts.length >= 3) {
            return int.tryParse(parts[2]) == today;
          }
          return false;
        },
      );
    } catch (_) {
      if (_monthlySchedule.isNotEmpty) {
        _todaySchedule = _monthlySchedule[today <= _monthlySchedule.length
            ? today - 1
            : _monthlySchedule.length - 1];
      }
    }
  }

  Future<void> updateLocationFromGPS() async {
    _isLoadingSchedule = true;
    _error = null;
    notifyListeners();

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) throw 'Service lokasi tidak aktif';

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) throw 'Izin lokasi ditolak';
      }

      Position position = await Geolocator.getCurrentPosition();
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        String? cityName = place.subAdministrativeArea ?? place.locality ?? place.administrativeArea;

        if (cityName != null) {
          // Bersihkan nama kota lebih teliti
          String cleanCityName = cityName
              .replaceAll(RegExp(r'Kabupaten|Kota|Kab\.|City', caseSensitive: false), '')
              .trim();
          
          // Lakukan pencarian nama kota ke API
          var city = await _service.searchCityByName(cleanCityName);
          
          // Jika tidak ketemu, coba kata pertama saja (misal: "Jakarta Selatan" -> "Jakarta")
          if (city == null && cleanCityName.contains(' ')) {
             city = await _service.searchCityByName(cleanCityName.split(' ')[0]);
          }

          if (city != null) {
            _selectedCityId = city.id;
            _selectedCityName = city.name;
            await _prefs.setLocation(
              provinceId: 'GPS',
              provinceName: 'Deteksi Otomatis',
              cityId: city.id,
              cityName: city.name,
            );
            await loadSchedule();
          } else {
             _error = 'Lokasi ($cleanCityName) belum terdaftar di API. Silakan pilih kota terdekat secara manual.';
          }
        }
      }
    } catch (e) {
      _error = e.toString().contains('Permintaan data tidak valid') 
          ? e.toString() 
          : 'Gagal mendeteksi lokasi otomatis. Silakan aktifkan GPS atau pilih lokasi manual.';
    } finally {
      _isLoadingSchedule = false;
      notifyListeners();
    }
  }
}
