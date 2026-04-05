class SurahModel {
  final int nomor;
  final String nama;
  final String namaLatin;
  final int jumlahAyat;
  final String tempatTurun;
  final String arti;
  final String deskripsi;
  final AudioModel? audioFull;

  SurahModel({
    required this.nomor,
    required this.nama,
    required this.namaLatin,
    required this.jumlahAyat,
    required this.tempatTurun,
    required this.arti,
    required this.deskripsi,
    this.audioFull,
  });

  factory SurahModel.fromJson(Map<String, dynamic> json) {
    return SurahModel(
      nomor: json['nomor'] is int ? json['nomor'] : int.tryParse(json['nomor']?.toString() ?? '') ?? json['number'] ?? 0,
      nama: json['nama'] ?? json['name'] ?? '',
      namaLatin: json['namaLatin'] ?? json['name_latin'] ?? '',
      jumlahAyat: json['jumlahAyat'] is int ? json['jumlahAyat'] : int.tryParse(json['jumlahAyat']?.toString() ?? '') ?? json['numberOfVerses'] ?? 0,
      tempatTurun: json['tempatTurun'] ?? json['revelation'] ?? '',
      arti: json['arti'] ?? json['translation'] ?? '',
      deskripsi: json['deskripsi'] ?? json['description'] ?? '',
      audioFull: json['audioFull'] != null
          ? AudioModel.fromJson(json['audioFull'])
          : null,
    );
  }
}

class AudioModel {
  final String qari01;
  final String qari02;
  final String qari03;
  final String qari04;
  final String qari05;

  AudioModel({
    required this.qari01,
    required this.qari02,
    required this.qari03,
    required this.qari04,
    required this.qari05,
  });

  factory AudioModel.fromJson(Map<String, dynamic> json) {
    return AudioModel(
      qari01: json['01'] ?? '',
      qari02: json['02'] ?? '',
      qari03: json['03'] ?? '',
      qari04: json['04'] ?? '',
      qari05: json['05'] ?? '',
    );
  }

  String getUrlByQari(String qariId) {
    switch (qariId) {
      case '01': return qari01;
      case '02': return qari02;
      case '03': return qari03;
      case '04': return qari04;
      case '05': return qari05;
      default: return qari01;
    }
  }
}

class AyahModel {
  final int nomorAyat;
  final String teksArab;
  final String teksLatin;
  final String teksIndonesia;
  final Map<String, String> audio;

  AyahModel({
    required this.nomorAyat,
    required this.teksArab,
    required this.teksLatin,
    required this.teksIndonesia,
    required this.audio,
  });

  factory AyahModel.fromJson(Map<String, dynamic> json) {
    Map<String, String> audioMap = {};
    if (json['audio'] != null) {
      final audioJson = json['audio'] as Map<String, dynamic>;
      audioJson.forEach((k, v) {
        audioMap[k] = v.toString();
      });
    }
    return AyahModel(
      nomorAyat: json['nomorAyat'] ?? 0,
      teksArab: json['teksArab'] ?? '',
      teksLatin: json['teksLatin'] ?? '',
      teksIndonesia: json['teksIndonesia'] ?? '',
      audio: audioMap,
    );
  }

  String getAudioUrl(String qariId) {
    return audio[qariId] ?? audio['01'] ?? '';
  }
}

class SurahDetailModel {
  final int nomor;
  final String nama;
  final String namaLatin;
  final int jumlahAyat;
  final String tempatTurun;
  final String arti;
  final String deskripsi;
  final List<AyahModel> ayat;
  final AudioModel? audioFull;

  SurahDetailModel({
    required this.nomor,
    required this.nama,
    required this.namaLatin,
    required this.jumlahAyat,
    required this.tempatTurun,
    required this.arti,
    required this.deskripsi,
    required this.ayat,
    this.audioFull,
  });

  factory SurahDetailModel.fromJson(Map<String, dynamic> json) {
    final ayatList = (json['ayat'] as List<dynamic>?)
            ?.map((a) => AyahModel.fromJson(a))
            .toList() ??
        [];
    return SurahDetailModel(
      nomor: json['nomor'] ?? 0,
      nama: json['nama'] ?? '',
      namaLatin: json['namaLatin'] ?? '',
      jumlahAyat: json['jumlahAyat'] ?? 0,
      tempatTurun: json['tempatTurun'] ?? '',
      arti: json['arti'] ?? '',
      deskripsi: json['deskripsi'] ?? '',
      ayat: ayatList,
      audioFull: json['audioFull'] != null
          ? AudioModel.fromJson(json['audioFull'])
          : null,
    );
  }
}

class TafsirAyahModel {
  final int ayat;
  final String teks;

  TafsirAyahModel({required this.ayat, required this.teks});

  factory TafsirAyahModel.fromJson(Map<String, dynamic> json) {
    return TafsirAyahModel(
      ayat: json['ayat'] ?? 0,
      teks: json['teks'] ?? '',
    );
  }
}

class SemanticResultModel {
  final int surah;
  final int ayah;
  final double score;
  final String text;
  final String translation;
  final String surahName;

  SemanticResultModel({
    required this.surah,
    required this.ayah,
    required this.score,
    required this.text,
    required this.translation,
    required this.surahName,
  });

  factory SemanticResultModel.fromJson(Map<String, dynamic> json) {
    final entryData = json['data'] as Map<String, dynamic>? ?? {};
    return SemanticResultModel(
      surah: entryData['id_surat'] ?? 0,
      ayah: entryData['nomor_ayat'] ?? 0,
      score: (json['skor'] ?? 0.0).toDouble(),
      text: entryData['teks_arab'] ?? '',
      translation: entryData['terjemahan_id'] ?? entryData['isi'] ?? '',
      surahName: entryData['nama_surat'] ?? '',
    );
  }
}
