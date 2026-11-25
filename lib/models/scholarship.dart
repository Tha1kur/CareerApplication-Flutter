class Scholarship {
  const Scholarship({
    required this.id,
    required this.name,
    required this.category,
    this.amount,
    this.deadline,
    this.eligibility,
    this.applyLink,
    this.description,
    this.tags = const [],
  });

  final String id;
  final String name;
  final String category;
  final String? amount;
  final String? deadline;
  final String? eligibility;
  final String? applyLink;
  final String? description;
  final List<String> tags;

  /// Bundled demo dataset entries carry 2025 deadlines which are historical/expired.
  bool get isHistoricalSample => (deadline ?? '').contains('2025');

  factory Scholarship.fromJson(Map<String, dynamic> json) {
    final rawTags = json['tags'];
    final parsedTags = rawTags is List
        ? rawTags.map((e) => e.toString()).toList(growable: false)
        : const <String>[];
    return Scholarship(
      id: (json['id'] as String?) ?? '',
      name: (json['name'] as String?) ?? '',
      category: (json['category'] as String?) ?? '',
      amount: json['amount'] as String?,
      deadline: json['deadline'] as String?,
      eligibility: json['eligibility'] as String?,
      applyLink: json['applyLink'] as String?,
      description: json['description'] as String?,
      tags: parsedTags,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'category': category,
    'amount': amount,
    'deadline': deadline,
    'eligibility': eligibility,
    'applyLink': applyLink,
    'description': description,
    'tags': tags,
  };
}
