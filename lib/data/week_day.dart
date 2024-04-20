class WeekDay {
  int? id;
  String swimmerName, time, come;

  WeekDay({
    this.id,
    required this.swimmerName,
    required this.time,
    required this.come,
  });

  Map<String, dynamic> toMap() {
    return {
      'swimmerName': swimmerName,
      'time': time,
      'come': come,
    };
  }
}