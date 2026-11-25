const List<String> kCommunityCategories = [
  'All',
  'Technology',
  'Design',
  'Management',
  'Science',
  'Admissions & Funding',
];

class CommunityAnswer {
  const CommunityAnswer({
    required this.id,
    required this.author,
    this.authorBadge = '',
    this.isVerifiedMentor = false,
    required this.content,
    required this.timestamp,
    this.upvotes = 0,
  });

  final String id;
  final String author;
  final String authorBadge;
  final bool isVerifiedMentor;
  final String content;
  final int timestamp;
  final int upvotes;

  factory CommunityAnswer.fromJson(Map<String, dynamic> json) {
    return CommunityAnswer(
      id: (json['id'] as String?) ?? '',
      author: (json['author'] as String?) ?? '',
      authorBadge: (json['authorBadge'] as String?) ?? '',
      isVerifiedMentor: (json['isVerifiedMentor'] as bool?) ?? false,
      content: (json['content'] as String?) ?? '',
      timestamp: (json['timestamp'] as num?)?.toInt() ?? 0,
      upvotes: (json['upvotes'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'author': author,
    'authorBadge': authorBadge,
    'isVerifiedMentor': isVerifiedMentor,
    'content': content,
    'timestamp': timestamp,
    'upvotes': upvotes,
  };
}

class CommunityQuestion {
  const CommunityQuestion({
    required this.id,
    required this.title,
    required this.author,
    this.authorRole = '',
    required this.category,
    required this.content,
    required this.timestamp,
    this.upvotes = 0,
    this.answers = const [],
    this.tags = const [],
  });

  final String id;
  final String title;
  final String author;
  final String authorRole;
  final String category;
  final String content;
  final int timestamp;
  final int upvotes;
  final List<CommunityAnswer> answers;
  final List<String> tags;

  CommunityQuestion copyWith({
    String? id,
    String? title,
    String? author,
    String? authorRole,
    String? category,
    String? content,
    int? timestamp,
    int? upvotes,
    List<CommunityAnswer>? answers,
    List<String>? tags,
  }) {
    return CommunityQuestion(
      id: id ?? this.id,
      title: title ?? this.title,
      author: author ?? this.author,
      authorRole: authorRole ?? this.authorRole,
      category: category ?? this.category,
      content: content ?? this.content,
      timestamp: timestamp ?? this.timestamp,
      upvotes: upvotes ?? this.upvotes,
      answers: answers ?? this.answers,
      tags: tags ?? this.tags,
    );
  }

  factory CommunityQuestion.fromJson(Map<String, dynamic> json) {
    final rawAnswers = json['answers'];
    final parsedAnswers = rawAnswers is List
        ? rawAnswers
              .whereType<Map<String, dynamic>>()
              .map(CommunityAnswer.fromJson)
              .toList(growable: false)
        : const <CommunityAnswer>[];

    final rawTags = json['tags'];
    final parsedTags = rawTags is List
        ? rawTags.map((e) => e.toString()).toList(growable: false)
        : const <String>[];

    return CommunityQuestion(
      id: (json['id'] as String?) ?? '',
      title: (json['title'] as String?) ?? '',
      author: (json['author'] as String?) ?? '',
      authorRole: (json['authorRole'] as String?) ?? '',
      category: (json['category'] as String?) ?? '',
      content: (json['content'] as String?) ?? '',
      timestamp: (json['timestamp'] as num?)?.toInt() ?? 0,
      upvotes: (json['upvotes'] as num?)?.toInt() ?? 0,
      answers: parsedAnswers,
      tags: parsedTags,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'author': author,
    'authorRole': authorRole,
    'category': category,
    'content': content,
    'timestamp': timestamp,
    'upvotes': upvotes,
    'answers': answers.map((a) => a.toJson()).toList(growable: false),
    'tags': tags,
  };
}
