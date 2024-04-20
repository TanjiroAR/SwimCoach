class Swimmer {
  int? id;
  String name, age, gender;

  Swimmer({
    this.id,
    required this.name,
    required this.age,
    required this.gender,
  });
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'age': age,
      'gender': gender,
    };
  }
}

class Champ {
  int? id;
  final String name, start, end;

  Champ({
    this.id,
    required this.name,
    required this.start,
    required this.end,
  });
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'start': start,
      'end': end,
    };
  }
}
