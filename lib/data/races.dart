class Races {
  int? id;
  final String swimmerName, time, score, champName;

  Races({
    this.id,
    required this.swimmerName,
    required this.time,
    required this.score,
    required this.champName,
  });

  Map<String, dynamic> toMap() {
    return {
      'swimmerName': swimmerName,
      'time': time,
      'score': score,
      'champName': champName,
    };
  }
}
