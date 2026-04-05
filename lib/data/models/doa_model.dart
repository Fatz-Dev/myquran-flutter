class DoaModel {
  final int id;
  final String judul;
  final String arab;
  final String latin;
  final String terjemahan;
  final String? referensi;
  final String? grup;
  final String? tag;

  DoaModel({
    required this.id,
    required this.judul,
    required this.arab,
    required this.latin,
    required this.terjemahan,
    this.referensi,
    this.grup,
    this.tag,
  });

  factory DoaModel.fromJson(Map<String, dynamic> json) {
    return DoaModel(
      id: json['id'] ?? 0,
      judul: json['judul'] ?? json['doa'] ?? json['nama'] ?? '',
      arab: json['arab'] ?? json['ar'] ?? '',
      latin: json['latin'] ?? json['transliterasi'] ?? json['tr'] ?? '',
      terjemahan: json['terjemahan'] ?? json['indo'] ?? json['idn'] ?? '',
      referensi: json['referensi']?.toString() ?? json['rawi']?.toString(),
      grup: json['grup']?.toString(),
      tag: json['tag']?.toString(),
    );
  }
}
