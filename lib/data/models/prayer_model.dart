class ProvinceModel {
  final String id;
  final String name;

  ProvinceModel({required this.id, required this.name});

  factory ProvinceModel.fromJson(Map<String, dynamic> json) {
    return ProvinceModel(
      id: json['id']?.toString() ?? '',
      name: json['nama'] ?? json['provinsi'] ?? '',
    );
  }
}

class CityModel {
  final String id;
  final String name;

  CityModel({required this.id, required this.name});

  factory CityModel.fromJson(Map<String, dynamic> json) {
    return CityModel(
      id: json['id']?.toString() ?? '',
      name: json['nama'] ?? json['kabkota'] ?? json['lokasi'] ?? '',
    );
  }
}

class PrayerTimeModel {
  final String tanggal;
  final String imsak;
  final String subuh;
  final String terbit;
  final String dhuha;
  final String dzuhur;
  final String ashar;
  final String maghrib;
  final String isya;

  PrayerTimeModel({
    required this.tanggal,
    required this.imsak,
    required this.subuh,
    required this.terbit,
    required this.dhuha,
    required this.dzuhur,
    required this.ashar,
    required this.maghrib,
    required this.isya,
  });

  factory PrayerTimeModel.fromJson(Map<String, dynamic> json) {
    return PrayerTimeModel(
      tanggal: json['tanggal']?.toString() ?? json['date']?.toString() ?? '',
      imsak: json['imsak']?.toString() ?? '',
      subuh: json['subuh']?.toString() ?? '',
      terbit: json['terbit']?.toString() ?? '',
      dhuha: json['dhuha']?.toString() ?? '',
      dzuhur: json['dzuhur']?.toString() ?? '',
      ashar: json['ashar']?.toString() ?? '',
      maghrib: json['maghrib']?.toString() ?? '',
      isya: json['isya']?.toString() ?? '',
    );
  }

  Map<String, String> toTimeMap() {
    return {
      'Imsak': imsak,
      'Subuh': subuh,
      'Terbit': terbit,
      'Dhuha': dhuha,
      'Dzuhur': dzuhur,
      'Ashar': ashar,
      'Maghrib': maghrib,
      'Isya': isya,
    };
  }

  String? getNextPrayer() {
    final now = DateTime.now();
    final times = {
      'Imsak': imsak,
      'Subuh': subuh,
      'Dhuha': dhuha,
      'Dzuhur': dzuhur,
      'Ashar': ashar,
      'Maghrib': maghrib,
      'Isya': isya,
    };

    for (final entry in times.entries) {
      final parts = entry.value.split(':');
      if (parts.length >= 2) {
        final t = DateTime(now.year, now.month, now.day,
            int.tryParse(parts[0]) ?? 0, int.tryParse(parts[1]) ?? 0);
        if (t.isAfter(now)) {
          return entry.key;
        }
      }
    }
    return 'Imsak';
  }

  String? getNextPrayerTime() {
    final nextPrayer = getNextPrayer();
    final times = toTimeMap();
    return times[nextPrayer];
  }
}
