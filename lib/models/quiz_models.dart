class QuizOption {
  const QuizOption({required this.value, required this.label});

  final String value;
  final String label;

  factory QuizOption.fromJson(Map<String, dynamic> json) {
    return QuizOption(
      value: (json['value'] as String?) ?? '',
      label: (json['label'] as String?) ?? '',
    );
  }

  Map<String, dynamic> toJson() => {'value': value, 'label': label};
}

class QuizQuestion {
  const QuizQuestion({
    required this.id,
    required this.question,
    required this.options,
  });

  final String id;
  final String question;
  final List<QuizOption> options;

  factory QuizQuestion.fromJson(Map<String, dynamic> json) {
    final rawOptions = (json['options'] as List<dynamic>?) ?? const [];
    return QuizQuestion(
      id: (json['id'] as String?) ?? '',
      question: (json['question'] as String?) ?? '',
      options: rawOptions
          .whereType<Map<String, dynamic>>()
          .map(QuizOption.fromJson)
          .toList(growable: false),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'question': question,
    'options': options.map((o) => o.toJson()).toList(growable: false),
  };
}

class QuizAnswers {
  const QuizAnswers({
    this.favoriteSubject = '',
    this.handsOnWork = '',
    this.jobPreference = '',
    this.workEnvironment = '',
    this.leadership = '',
    this.problemSolving = '',
    this.creativity = '',
    this.communication = '',
  });

  final String favoriteSubject;
  final String handsOnWork;
  final String jobPreference;
  final String workEnvironment;
  final String leadership;
  final String problemSolving;
  final String creativity;
  final String communication;

  factory QuizAnswers.fromAnswerMap(Map<String, String> map) {
    return QuizAnswers(
      favoriteSubject: map['favoriteSubject'] ?? '',
      handsOnWork: map['handsOnWork'] ?? '',
      jobPreference: map['jobPreference'] ?? '',
      workEnvironment: map['workEnvironment'] ?? '',
      leadership: map['leadership'] ?? '',
      problemSolving: map['problemSolving'] ?? '',
      creativity: map['creativity'] ?? '',
      communication: map['communication'] ?? '',
    );
  }

  Map<String, String> toAnswerMap() {
    return {
      if (favoriteSubject.isNotEmpty) 'favoriteSubject': favoriteSubject,
      if (handsOnWork.isNotEmpty) 'handsOnWork': handsOnWork,
      if (jobPreference.isNotEmpty) 'jobPreference': jobPreference,
      if (workEnvironment.isNotEmpty) 'workEnvironment': workEnvironment,
      if (leadership.isNotEmpty) 'leadership': leadership,
      if (problemSolving.isNotEmpty) 'problemSolving': problemSolving,
      if (creativity.isNotEmpty) 'creativity': creativity,
      if (communication.isNotEmpty) 'communication': communication,
    };
  }

  QuizAnswers copyWith({
    String? favoriteSubject,
    String? handsOnWork,
    String? jobPreference,
    String? workEnvironment,
    String? leadership,
    String? problemSolving,
    String? creativity,
    String? communication,
  }) {
    return QuizAnswers(
      favoriteSubject: favoriteSubject ?? this.favoriteSubject,
      handsOnWork: handsOnWork ?? this.handsOnWork,
      jobPreference: jobPreference ?? this.jobPreference,
      workEnvironment: workEnvironment ?? this.workEnvironment,
      leadership: leadership ?? this.leadership,
      problemSolving: problemSolving ?? this.problemSolving,
      creativity: creativity ?? this.creativity,
      communication: communication ?? this.communication,
    );
  }

  factory QuizAnswers.fromJson(Map<String, dynamic> json) {
    return QuizAnswers(
      favoriteSubject: (json['favoriteSubject'] as String?) ?? '',
      handsOnWork: (json['handsOnWork'] as String?) ?? '',
      jobPreference: (json['jobPreference'] as String?) ?? '',
      workEnvironment: (json['workEnvironment'] as String?) ?? '',
      leadership: (json['leadership'] as String?) ?? '',
      problemSolving: (json['problemSolving'] as String?) ?? '',
      creativity: (json['creativity'] as String?) ?? '',
      communication: (json['communication'] as String?) ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'favoriteSubject': favoriteSubject,
    'handsOnWork': handsOnWork,
    'jobPreference': jobPreference,
    'workEnvironment': workEnvironment,
    'leadership': leadership,
    'problemSolving': problemSolving,
    'creativity': creativity,
    'communication': communication,
  };
}

class QuizAttempt {
  const QuizAttempt({
    required this.id,
    required this.timestamp,
    required this.formattedDate,
    required this.topCareer,
    required this.topScore,
    this.scores = const {},
  });

  final String id;
  final int timestamp;
  final String formattedDate;
  final String topCareer;
  final int topScore;
  final Map<String, int> scores;

  factory QuizAttempt.fromJson(Map<String, dynamic> json) {
    final rawScores = json['scores'];
    final parsedScores = <String, int>{};
    if (rawScores is Map) {
      for (final entry in rawScores.entries) {
        final key = entry.key?.toString();
        final value = entry.value;
        if (key != null && value is num) {
          parsedScores[key] = value.toInt();
        }
      }
    }
    return QuizAttempt(
      id: (json['id'] as String?) ?? '',
      timestamp: (json['timestamp'] as num?)?.toInt() ?? 0,
      formattedDate: (json['formattedDate'] as String?) ?? '',
      topCareer: (json['topCareer'] as String?) ?? '',
      topScore: (json['topScore'] as num?)?.toInt() ?? 0,
      scores: Map.unmodifiable(parsedScores),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'timestamp': timestamp,
    'formattedDate': formattedDate,
    'topCareer': topCareer,
    'topScore': topScore,
    'scores': scores,
  };
}
