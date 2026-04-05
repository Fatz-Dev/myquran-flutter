class HadisModel {
  final int id;
  final String textAr;
  final String textId;
  final String grade;
  final String takhrij;
  final String hikmah;

  HadisModel({
    required this.id,
    required this.textAr,
    required this.textId,
    required this.grade,
    required this.takhrij,
    required this.hikmah,
  });

  factory HadisModel.fromJson(Map<String, dynamic> json) {
    String ar = '';
    String id = '';
    
    final textData = json['text'];
    if (textData is Map) {
      ar = textData['ar'] ?? '';
      id = textData['id'] ?? '';
    } else if (textData is String) {
      id = textData;
    }

    return HadisModel(
      id: json['id'] ?? 0,
      textAr: ar,
      textId: id,
      grade: json['grade'] ?? '',
      takhrij: json['takhrij'] ?? '',
      hikmah: json['hikmah'] ?? '',
    );
  }
}
