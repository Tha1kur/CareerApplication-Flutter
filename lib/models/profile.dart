class Profile {
  const Profile({
    this.name = '',
    this.age = 0,
    this.goal = '',
    this.avatarPath = '',
  });

  final String name;
  final int age;
  final String goal;
  final String avatarPath;

  bool get isEmpty => name.trim().isEmpty && age <= 0 && goal.trim().isEmpty;

  Profile copyWith({
    String? name,
    int? age,
    String? goal,
    String? avatarPath,
  }) {
    return Profile(
      name: name ?? this.name,
      age: age ?? this.age,
      goal: goal ?? this.goal,
      avatarPath: avatarPath ?? this.avatarPath,
    );
  }

  factory Profile.fromJson(Map<String, dynamic> json) {
    return Profile(
      name: (json['name'] as String?) ?? '',
      age: (json['age'] as num?)?.toInt() ?? 0,
      goal: (json['goal'] as String?) ?? '',
      avatarPath: (json['avatarPath'] as String?) ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'age': age,
      'goal': goal,
      'avatarPath': avatarPath,
    };
  }
}
