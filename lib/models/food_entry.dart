class FoodEntry {
  final int? id;
  final String name;
  final int calories;
  final DateTime dateTime;

  FoodEntry({
    this.id,
    required this.name,
    required this.calories,
    required this.dateTime,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'calories': calories,
      'dateTime': dateTime.toIso8601String(),
    };
  }

  factory FoodEntry.fromMap(Map<String, dynamic> map) {
    return FoodEntry(
      id: map['id'],
      name: map['name'],
      calories: map['calories'],
      dateTime: DateTime.parse(map['dateTime']),
    );
  }

  FoodEntry copyWith({
    int? id,
    String? name,
    int? calories,
    DateTime? dateTime,
  }) {
    return FoodEntry(
      id: id ?? this.id,
      name: name ?? this.name,
      calories: calories ?? this.calories,
      dateTime: dateTime ?? this.dateTime,
    );
  }
}
