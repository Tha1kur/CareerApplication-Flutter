const List<String> kStandardRequiredDocuments = [
  'Academic Mark Sheets & Transcripts',
  'Family Income / EWS Certificate',
  'Government Photo ID (Aadhaar / Voter ID)',
  'Statement of Purpose (SOP)',
  'Letter of Recommendation (LOR)',
];

enum ApplicationStage {
  discovered('DISCOVERED', 'Discovered'),
  docsReady('DOCS_READY', 'Docs Ready'),
  applied('APPLIED', 'Applied'),
  awarded('AWARDED', 'Awarded');

  const ApplicationStage(this.wireName, this.label);

  final String wireName;
  final String label;

  static ApplicationStage fromWireName(String? raw) {
    return ApplicationStage.values.firstWhere(
      (stage) => stage.wireName == raw,
      orElse: () => ApplicationStage.discovered,
    );
  }
}

class TrackedScholarship {
  const TrackedScholarship({
    required this.scholarshipId,
    required this.scholarshipName,
    required this.provider,
    required this.amount,
    required this.deadline,
    this.stage = ApplicationStage.discovered,
    this.completedDocuments = const {},
    this.notes = '',
    this.updatedAt = 0,
  });

  final String scholarshipId;
  final String scholarshipName;
  final String provider;
  final String amount;
  final String deadline;
  final ApplicationStage stage;
  final Set<String> completedDocuments;
  final String notes;
  final int updatedAt;

  int get completedStandardDocsCount => kStandardRequiredDocuments
      .where((doc) => completedDocuments.contains(doc))
      .length;

  double get documentProgressFraction =>
      completedStandardDocsCount / kStandardRequiredDocuments.length;

  TrackedScholarship copyWith({
    String? scholarshipId,
    String? scholarshipName,
    String? provider,
    String? amount,
    String? deadline,
    ApplicationStage? stage,
    Set<String>? completedDocuments,
    String? notes,
    int? updatedAt,
  }) {
    return TrackedScholarship(
      scholarshipId: scholarshipId ?? this.scholarshipId,
      scholarshipName: scholarshipName ?? this.scholarshipName,
      provider: provider ?? this.provider,
      amount: amount ?? this.amount,
      deadline: deadline ?? this.deadline,
      stage: stage ?? this.stage,
      completedDocuments: completedDocuments ?? this.completedDocuments,
      notes: notes ?? this.notes,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  factory TrackedScholarship.fromJson(Map<String, dynamic> json) {
    final rawDocs = json['completedDocuments'];
    final parsedDocs = rawDocs is List
        ? rawDocs.map((e) => e.toString()).toSet()
        : const <String>{};
    return TrackedScholarship(
      scholarshipId: (json['scholarshipId'] as String?) ?? '',
      scholarshipName: (json['scholarshipName'] as String?) ?? '',
      provider: (json['provider'] as String?) ?? '',
      amount: (json['amount'] as String?) ?? 'Varies',
      deadline: (json['deadline'] as String?) ?? 'Rolling',
      stage: ApplicationStage.fromWireName(json['stage'] as String?),
      completedDocuments: Set.unmodifiable(parsedDocs),
      notes: (json['notes'] as String?) ?? '',
      updatedAt: (json['updatedAt'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
    'scholarshipId': scholarshipId,
    'scholarshipName': scholarshipName,
    'provider': provider,
    'amount': amount,
    'deadline': deadline,
    'stage': stage.wireName,
    'completedDocuments': completedDocuments.toList(growable: false),
    'notes': notes,
    'updatedAt': updatedAt,
  };
}
