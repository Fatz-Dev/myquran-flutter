class PerawiModel {
  final int id;
  final String name;
  final String grade;
  final String parents;
  final String spouse;
  final String siblings;
  final String children;
  final String birthDatePlace;
  final String placesOfStay;
  final String deathDatePlace;
  final String teachers;
  final String students;
  final String areaOfInterest;
  final String tags;
  final String books;

  PerawiModel({
    required this.id,
    required this.name,
    required this.grade,
    required this.parents,
    required this.spouse,
    required this.siblings,
    required this.children,
    required this.birthDatePlace,
    required this.placesOfStay,
    required this.deathDatePlace,
    required this.teachers,
    required this.students,
    required this.areaOfInterest,
    required this.tags,
    required this.books,
  });

  factory PerawiModel.fromJson(Map<String, dynamic> json) {
    return PerawiModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      grade: json['grade'] ?? '',
      parents: json['parents'] ?? '-',
      spouse: json['spouse'] ?? '-',
      siblings: json['siblings'] ?? '-',
      children: json['children'] ?? '-',
      birthDatePlace: json['birth_date_place'] ?? '-',
      placesOfStay: json['places_of_stay'] ?? '-',
      deathDatePlace: json['death_date_place'] ?? '-',
      teachers: json['teachers'] ?? '-',
      students: json['students'] ?? '-',
      areaOfInterest: json['area_of_interest'] ?? '-',
      tags: json['tags'] ?? '',
      books: json['books'] ?? '-',
    );
  }
}
