import 'dart:convert';

class AyahBookmark {
  final int surahNomor;
  final String surahName;
  final String surahNama;
  final int ayahNomor;
  final String arabText;
  final String terjemahan;
  final DateTime timestamp;

  AyahBookmark({
    required this.surahNomor,
    required this.surahName,
    required this.surahNama,
    required this.ayahNomor,
    required this.arabText,
    required this.terjemahan,
    required this.timestamp,
  });

  String get id => '${surahNomor}_$ayahNomor';

  Map<String, dynamic> toJson() => {
        'surahNomor': surahNomor,
        'surahName': surahName,
        'surahNama': surahNama,
        'ayahNomor': ayahNomor,
        'arabText': arabText,
        'terjemahan': terjemahan,
        'timestamp': timestamp.toIso8601String(),
      };

  factory AyahBookmark.fromJson(Map<String, dynamic> json) {
    return AyahBookmark(
      surahNomor: json['surahNomor'] ?? 0,
      surahName: json['surahName'] ?? '',
      surahNama: json['surahNama'] ?? '',
      ayahNomor: json['ayahNomor'] ?? 0,
      arabText: json['arabText'] ?? '',
      terjemahan: json['terjemahan'] ?? '',
      timestamp: DateTime.tryParse(json['timestamp'] ?? '') ?? DateTime.now(),
    );
  }

  static List<AyahBookmark> listFromJson(String jsonStr) {
    try {
      final list = jsonDecode(jsonStr) as List<dynamic>;
      return list.map((e) => AyahBookmark.fromJson(e)).toList();
    } catch (_) {
      return [];
    }
  }

  static String listToJson(List<AyahBookmark> list) {
    return jsonEncode(list.map((e) => e.toJson()).toList());
  }
}

class DoaBookmark {
  final int doaId;
  final String judul;
  final String arab;
  final String terjemahan;
  final DateTime timestamp;

  DoaBookmark({
    required this.doaId,
    required this.judul,
    required this.arab,
    required this.terjemahan,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() => {
        'doaId': doaId,
        'judul': judul,
        'arab': arab,
        'terjemahan': terjemahan,
        'timestamp': timestamp.toIso8601String(),
      };

  factory DoaBookmark.fromJson(Map<String, dynamic> json) {
    return DoaBookmark(
      doaId: json['doaId'] ?? 0,
      judul: json['judul'] ?? '',
      arab: json['arab'] ?? '',
      terjemahan: json['terjemahan'] ?? '',
      timestamp: DateTime.tryParse(json['timestamp'] ?? '') ?? DateTime.now(),
    );
  }

  static List<DoaBookmark> listFromJson(String jsonStr) {
    try {
      final list = jsonDecode(jsonStr) as List<dynamic>;
      return list.map((e) => DoaBookmark.fromJson(e)).toList();
    } catch (_) {
      return [];
    }
  }

  static String listToJson(List<DoaBookmark> list) {
    return jsonEncode(list.map((e) => e.toJson()).toList());
  }
}
