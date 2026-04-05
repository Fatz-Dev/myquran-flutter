import 'dart:convert';

class ReadingHistory {
  final int nomor;
  final String namaLatin;
  final String nama;
  final String arti;
  final int lastAyah;
  final int jumlahAyat;
  final DateTime timestamp;

  ReadingHistory({
    required this.nomor,
    required this.namaLatin,
    required this.nama,
    required this.arti,
    required this.lastAyah,
    required this.jumlahAyat,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() => {
        'nomor': nomor,
        'namaLatin': namaLatin,
        'nama': nama,
        'arti': arti,
        'lastAyah': lastAyah,
        'jumlahAyat': jumlahAyat,
        'timestamp': timestamp.toIso8601String(),
      };

  factory ReadingHistory.fromJson(Map<String, dynamic> json) {
    return ReadingHistory(
      nomor: json['nomor'] ?? 0,
      namaLatin: json['namaLatin'] ?? '',
      nama: json['nama'] ?? '',
      arti: json['arti'] ?? '',
      lastAyah: json['lastAyah'] ?? 1,
      jumlahAyat: json['jumlahAyat'] ?? 0,
      timestamp: DateTime.tryParse(json['timestamp'] ?? '') ?? DateTime.now(),
    );
  }

  static List<ReadingHistory> listFromJson(String jsonStr) {
    try {
      final list = jsonDecode(jsonStr) as List<dynamic>;
      return list.map((e) => ReadingHistory.fromJson(e)).toList();
    } catch (_) {
      return [];
    }
  }

  static String listToJson(List<ReadingHistory> list) {
    return jsonEncode(list.map((e) => e.toJson()).toList());
  }

  String get progressText {
    if (jumlahAyat == 0) return 'Ayat $lastAyah';
    final pct = ((lastAyah / jumlahAyat) * 100).round();
    return 'Ayat $lastAyah / $jumlahAyat ($pct%)';
  }

  double get progress {
    if (jumlahAyat == 0) return 0;
    return lastAyah / jumlahAyat;
  }
}
