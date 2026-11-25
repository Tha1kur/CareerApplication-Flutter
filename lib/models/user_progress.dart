class UserProgress {
  const UserProgress({
    this.points = 0,
    this.badges = const [],
    this.completedQuiz = false,
    this.viewedResults = false,
    this.exploredColleges = false,
    this.checkedScholarships = false,
  });

  final int points;
  final List<String> badges;
  final bool completedQuiz;
  final bool viewedResults;
  final bool exploredColleges;
  final bool checkedScholarships;

  int get completedMilestonesCount {
    var count = 0;
    if (completedQuiz) count++;
    if (viewedResults) count++;
    if (exploredColleges) count++;
    if (checkedScholarships) count++;
    return count;
  }

  UserProgress copyWith({
    int? points,
    List<String>? badges,
    bool? completedQuiz,
    bool? viewedResults,
    bool? exploredColleges,
    bool? checkedScholarships,
  }) {
    return UserProgress(
      points: points ?? this.points,
      badges: badges ?? this.badges,
      completedQuiz: completedQuiz ?? this.completedQuiz,
      viewedResults: viewedResults ?? this.viewedResults,
      exploredColleges: exploredColleges ?? this.exploredColleges,
      checkedScholarships: checkedScholarships ?? this.checkedScholarships,
    );
  }
}

class LevelInfo {
  const LevelInfo({
    required this.level,
    required this.progressFraction,
    required this.currentXp,
    required this.nextLevelXp,
  });

  final int level;
  final double progressFraction;
  final int currentXp;
  final int nextLevelXp;
}
