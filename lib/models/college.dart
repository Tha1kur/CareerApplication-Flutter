class College {
  const College({
    required this.id,
    required this.name,
    this.city,
    this.state,
    this.type,
    this.rank,
    this.intake,
    this.avgFees,
    this.description,
    this.courses = const [],
    this.tags = const [],
    this.website,
  });

  final String id;
  final String name;
  final String? city;
  final String? state;
  final String? type;
  final int? rank;
  final String? intake;
  final String? avgFees;
  final String? description;
  final List<String> courses;
  final List<String> tags;
  final String? website;

  String get formattedLocation {
    final parts = [
      if (city != null && city!.trim().isNotEmpty) city!.trim(),
      if (state != null && state!.trim().isNotEmpty) state!.trim(),
    ];
    return parts.isEmpty ? 'Location to be confirmed' : parts.join(', ');
  }

  factory College.fromJson(Map<String, dynamic> json) {
    return College(
      id: (json['id'] as String?) ?? '',
      name: (json['name'] as String?) ?? '',
      city: json['city'] as String?,
      state: json['state'] as String?,
      type: json['type'] as String?,
      rank: (json['rank'] as num?)?.toInt(),
      intake: json['intake']?.toString(),
      avgFees: json['avgFees'] as String?,
      description: json['description'] as String?,
      courses: _stringList(json['courses']),
      tags: _stringList(json['tags']),
      website: json['website'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'city': city,
    'state': state,
    'type': type,
    'rank': rank,
    'intake': intake,
    'avgFees': avgFees,
    'description': description,
    'courses': courses,
    'tags': tags,
    'website': website,
  };

  static List<String> _stringList(Object? raw) {
    if (raw is! List) return const [];
    return raw.map((e) => e.toString()).toList(growable: false);
  }
}
