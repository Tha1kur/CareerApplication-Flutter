class Profile {
  const Profile({this.name = '', this.age = 0, this.goal = ''});

  final String name;
  final int age;
  final String goal;

  bool get isEmpty => name.trim().isEmpty && age <= 0 && goal.trim().isEmpty;

  Profile copyWith({String? name, int? age, String? goal}) {
    return Profile(
      name: name ?? this.name,
      age: age ?? this.age,
      goal: goal ?? this.goal,
    );
  }

  factory Profile.fromJson(Map<String, dynamic> json) {
    return Profile(
      name: (json['name'] as String?) ?? '',
      age: (json['age'] as num?)?.toInt() ?? 0,
      goal: (json['goal'] as String?) ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'name': name, 'age': age, 'goal': goal};
  }
}
