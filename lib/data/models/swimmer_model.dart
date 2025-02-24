class Swimmer {
  String id;
  String name;
  int age;
  String level;
  List<Map<String, dynamic>> trainingRecords;
  List<Map<String, dynamic>> competitions;

  Swimmer({
    required this.id,
    required this.name,
    required this.age,
    required this.level,
    required this.trainingRecords,
    required this.competitions,
  });

  // تحويل من JSON إلى Object
  factory Swimmer.fromJson(Map<String, dynamic> json) => Swimmer(
    id: json['id'],
    name: json['name'],
    age: json['age'],
    level: json['level'],
    trainingRecords: List<Map<String, dynamic>>.from(json['trainingRecords']),
    competitions: List<Map<String, dynamic>>.from(json['competitions']),
  );

  // تحويل من Object إلى JSON
  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'age': age,
    'level': level,
    'trainingRecords': trainingRecords,
    'competitions': competitions,
  };
}
