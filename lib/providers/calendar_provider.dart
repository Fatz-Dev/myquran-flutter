import 'package:flutter/material.dart';
import '../data/services/api_service.dart';
import '../core/utils/date_helper.dart';

class CalendarProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();

  bool _isLoading = false;
  String? _error;
  
  final Map<DateTime, List<String>> _holidays = {};
  final Map<DateTime, String> _hijriDates = {};

  bool get isLoading => _isLoading;
  String? get error => _error;

  List<String> getHolidaysForDay(DateTime day) {
    final normalized = DateTime(day.year, day.month, day.day);
    return _holidays[normalized] ?? [];
  }

  String getHijriDateForDay(DateTime day) {
    final normalized = DateTime(day.year, day.month, day.day);
    return _hijriDates[normalized] ?? DateHelper.getHijriDateFor(normalized);
  }

  Future<void> loadMonthData(int month, int year) async {
    // Hindari pemanggilan ganda jika bulan tersebut sudah ada
    if (_hijriDates.containsKey(DateTime(year, month, 1))) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Jalankan pengambilan data secara paralel
      await Future.wait([
        _fetchHijriData(month, year),
        _fetchHolidays(month, year),
      ]);
    } catch (e) {
      _error = 'Gagal memuat kalender: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _fetchHijriData(int month, int year) async {
    try {
      final response = await _apiService
          .getPrayer('/sholat/jadwal/1301/$year/$month');
      if (response['status'] == true) {
        final List<dynamic> dataList = response['data']['jadwal'];
        for (var item in dataList) {
          final String dateStr = item['date']; // YYYY-MM-DD
          final String hijriStr = item['hijri'];

          final parsedDate = DateTime.parse(dateStr);
          final normalized =
              DateTime(parsedDate.year, parsedDate.month, parsedDate.day);

          _hijriDates[normalized] = hijriStr;
        }
      }
    } catch (e) {
      debugPrint('Error fetching Hijri: $e');
    }
  }

  Future<void> _fetchHolidays(int month, int year) async {
    try {
      // API Hari Libur Indonesia
      final url = 'https://api-harilibur.vercel.app/api?year=$year&month=$month';
      final response = await _apiService.getRaw(url);
      
      if (response is List) {
        for (var item in response) {
          final String dateStr = item['holiday_date'];
          final String name = item['holiday_name'];
          
          final date = DateTime.parse(dateStr);
          final normalized = DateTime(date.year, date.month, date.day);

          if (_holidays[normalized] == null) {
            _holidays[normalized] = [];
          }
          if (!_holidays[normalized]!.contains(name)) {
            _holidays[normalized]!.add(name);
          }
        }
      }
    } catch (e) {
      debugPrint('Error fetching holidays: $e');
    }
  }
}
