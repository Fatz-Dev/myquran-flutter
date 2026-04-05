import '../models/prayer_model.dart';
import 'api_service.dart';

class PrayerService {
  final ApiService _apiService;

  PrayerService(this._apiService);

  Future<List<ProvinceModel>> getProvinces() async {
    // MyQuran API tidak menggunakan provinsi, jadi kita berikan 1 opsi dummy
    // agar flow UI tidak usah banyak dirombak
    return [
      ProvinceModel(id: 'all', name: 'Daftar Semua Kab/Kota'),
    ];
  }

  Future<List<CityModel>> getCities(String provinsiId) async {
    final data = await _apiService.getPrayer('/sholat/kota/semua');
    final list = data['data'] as List<dynamic>? ?? [];
    return list.map((e) => CityModel.fromJson(e)).toList();
  }

  Future<List<PrayerTimeModel>> getMonthlySchedule({
    required String cityId,
    required int year,
    required int month,
  }) async {
    final monthStr = month.toString().padLeft(2, '0');
    final data = await _apiService.getPrayer(
      '/sholat/jadwal/$cityId/$year/$monthStr',
    );
    final scheduleData = data['data']?['jadwal'] as List<dynamic>? ?? [];
    return scheduleData.map((e) => PrayerTimeModel.fromJson(e)).toList();
  }

  Future<CityModel?> searchCityByName(String name) async {
    final data = await _apiService.getPrayer('/sholat/kota/cari/$name');
    final list = data['data'] as List<dynamic>? ?? [];
    if (list.isNotEmpty) {
      return CityModel.fromJson(list.first);
    }
    return null;
  }
}
