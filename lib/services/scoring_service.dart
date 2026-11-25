import '../models/college.dart';
import '../models/quiz_models.dart';
import '../models/scholarship.dart';
import '../models/user_progress.dart';

class CareerInfo {
  const CareerInfo({
    required this.key,
    required this.title,
    required this.shortDescription,
    required this.skills,
    required this.vibeTags,
  });

  final String key;
  final String title;
  final String shortDescription;
  final List<String> skills;
  final List<String> vibeTags;
}

/// Pure, deterministic career scoring, gamification level math, and career-match helpers.
/// Ported directly from Kotlin `Model.kt`, `ResultsScreen.kt`, and `CareerRecommendationScreen.kt`.
abstract final class ScoringService {
  static const int xpPerLevel = 150;

  static const List<String> careerCategories = [
    'Engineering',
    'Design',
    'Management',
    'Science',
    'Entrepreneurship',
  ];

  static const Map<String, CareerInfo> careerCatalog = {
    'Engineering': CareerInfo(
      key: 'Engineering',
      title: 'Engineering & Tech',
      shortDescription: 'Build and optimize real-world systems using math, code and hardware.',
      skills: [
        'Mathematics',
        'Programming',
        'Problem solving',
        'Physics',
        'Robotics',
      ],
      vibeTags: ['Labs & projects', 'Tech innovation', 'Product building'],
    ),
    'Design': CareerInfo(
      key: 'Design',
      title: 'Design & UX',
      shortDescription:
          'Turn ideas into beautiful, usable products and experiences.',
      skills: ['Visual design', 'UI/UX', 'Creativity', 'Storytelling'],
      vibeTags: ['Figma & sketches', 'User research', 'Portfolios'],
    ),
    'Management': CareerInfo(
      key: 'Management',
      title: 'Business & Management',
      shortDescription:
          'Lead teams, manage resources and drive strategy & growth.',
      skills: ['Communication', 'Leadership', 'Strategy', 'Finance basics'],
      vibeTags: ['Presentations', 'Teamwork', 'Decision making'],
    ),
    'Science': CareerInfo(
      key: 'Science',
      title: 'Science & Research',
      shortDescription:
          'Explore how the world works with experiments, data and theory.',
      skills: ['Scientific method', 'Data analysis', 'Curiosity'],
      vibeTags: ['Labs', 'Research papers', 'Deep thinking'],
    ),
    'Entrepreneurship': CareerInfo(
      key: 'Entrepreneurship',
      title: 'Entrepreneurship',
      shortDescription:
          'Start and grow your own products, startups or services.',
      skills: ['Problem spotting', 'Business models', 'Networking'],
      vibeTags: ['Startups', 'Pitch decks', 'Ownership'],
    ),
  };

  static String mapCareerKeyToTitle(String key) {
    return careerCatalog[key]?.title ?? key;
  }

  /// Calculates gamification level info: 150 XP per level, starting at Level 1.
  static LevelInfo calculateLevel(int points) {
    final safePoints = points < 0 ? 0 : points;
    final level = (safePoints ~/ xpPerLevel) + 1;
    final currentXp = safePoints % xpPerLevel;
    final fraction = (currentXp / xpPerLevel).clamp(0.0, 1.0);
    return LevelInfo(
      level: level,
      progressFraction: fraction,
      currentXp: currentXp,
      nextLevelXp: xpPerLevel,
    );
  }

  /// Exact weighted career scoring formula from Kotlin `calculateQuizScores`.
  static Map<String, int> calculateQuizScores(QuizAnswers answers) {
    final scores = <String, int>{
      'Engineering': 0,
      'Design': 0,
      'Management': 0,
      'Science': 0,
      'Entrepreneurship': 0,
    };

    void add(String category, int delta) {
      scores[category] = (scores[category] ?? 0) + delta;
    }

    // 1. Favorite subject
    switch (answers.favoriteSubject.toLowerCase()) {
      case 'math':
        add('Engineering', 10);
        add('Management', 4);
      case 'science':
        add('Science', 10);
        add('Engineering', 4);
      case 'arts':
        add('Design', 10);
      case 'commerce':
        add('Management', 8);
        add('Entrepreneurship', 8);
    }

    // 2. Hands-on preference
    switch (answers.handsOnWork.toLowerCase()) {
      case 'yes':
        add('Engineering', 4);
        add('Design', 4);
        add('Science', 2);
      case 'no':
        add('Science', 3);
        add('Management', 2);
      case 'maybe':
        add('Engineering', 1);
        add('Design', 1);
        add('Science', 1);
    }

    // 3. Job preference
    switch (answers.jobPreference.toLowerCase()) {
      case 'government':
        add('Science', 4);
        add('Management', 4);
      case 'private':
        add('Engineering', 3);
        add('Design', 3);
        add('Management', 3);
      case 'business':
        add('Entrepreneurship', 10);
        add('Management', 5);
    }

    // 4. Work environment
    switch (answers.workEnvironment.toLowerCase()) {
      case 'team':
        add('Management', 4);
        add('Entrepreneurship', 3);
      case 'independent':
        add('Design', 3);
        add('Science', 3);
      case 'mixed':
        add('Engineering', 2);
        add('Management', 2);
        add('Entrepreneurship', 2);
    }

    // 5. Leadership comfort
    switch (answers.leadership.toLowerCase()) {
      case 'very':
        add('Management', 5);
        add('Entrepreneurship', 5);
      case 'somewhat':
        add('Management', 3);
        add('Entrepreneurship', 3);
      case 'not':
        add('Design', 2);
        add('Science', 2);
    }

    // 6. Problem-solving style
    switch (answers.problemSolving.toLowerCase()) {
      case 'analytical':
        add('Engineering', 5);
        add('Science', 5);
      case 'creative':
        add('Design', 6);
        add('Entrepreneurship', 2);
      case 'people':
        add('Management', 5);
        add('Entrepreneurship', 4);
    }

    // 7. Creativity importance
    switch (answers.creativity.toLowerCase()) {
      case 'very':
        add('Design', 6);
        add('Entrepreneurship', 4);
      case 'somewhat':
        add('Design', 3);
        add('Engineering', 2);
      case 'not':
        add('Engineering', 3);
        add('Science', 3);
    }

    // 8. Communication style
    switch (answers.communication.toLowerCase()) {
      case 'public':
        add('Management', 4);
        add('Entrepreneurship', 4);
      case 'written':
        add('Science', 3);
        add('Design', 3);
      case 'oneonone':
        add('Management', 3);
        add('Entrepreneurship', 2);
        add('Design', 2);
    }

    return Map.unmodifiable(scores);
  }

  /// Returns entries sorted by descending score while preserving insertion order on ties.
  static List<MapEntry<String, int>> sortedScores(Map<String, int> scores) {
    final entries = scores.entries.toList();
    entries.sort((a, b) => b.value.compareTo(a.value));
    return entries;
  }

  static String topCareerCategory(
    Map<String, int> scores, {
    String fallback = 'Engineering',
  }) {
    if (scores.isEmpty) return fallback;
    MapEntry<String, int>? best;
    for (final entry in scores.entries) {
      if (best == null || entry.value > best.value) {
        best = entry;
      }
    }
    return best?.key ?? fallback;
  }

  static List<String> buildAnswerSummaryChips(QuizAnswers a) {
    final chips = <String>[];

    if (a.favoriteSubject.trim().isNotEmpty) {
      chips.add(switch (a.favoriteSubject.toLowerCase()) {
        'math' => 'Enjoys Mathematics',
        'science' => 'Science lover',
        'arts' => 'Creative & artsy',
        'commerce' => 'Interested in commerce',
        _ => 'Has a favourite subject',
      });
    }

    if (a.handsOnWork.trim().isNotEmpty) {
      chips.add(switch (a.handsOnWork.toLowerCase()) {
        'yes' => 'Likes hands-on work',
        'no' => 'Prefers theory',
        'maybe' => 'Open to practical work',
        _ => 'Flexible about hands-on work',
      });
    }

    if (a.jobPreference.trim().isNotEmpty) {
      chips.add(switch (a.jobPreference.toLowerCase()) {
        'government' => 'Prefers stability',
        'private' => 'Open to corporate growth',
        'business' => 'Entrepreneurial mindset',
        _ => 'Has career preferences',
      });
    }

    if (a.workEnvironment.trim().isNotEmpty) {
      chips.add(switch (a.workEnvironment.toLowerCase()) {
        'team' => 'Team player',
        'independent' => 'Independent worker',
        'mixed' => 'Mix of solo & team work',
        _ => 'Has environment preference',
      });
    }

    if (a.leadership.trim().isNotEmpty) {
      chips.add(switch (a.leadership.toLowerCase()) {
        'very' => 'Comfortable leading',
        'somewhat' => 'Open to leadership',
        'not' => 'Prefers support role',
        _ => 'Thinks about leadership',
      });
    }

    if (a.problemSolving.trim().isNotEmpty) {
      chips.add(switch (a.problemSolving.toLowerCase()) {
        'analytical' => 'Analytical problem-solver',
        'creative' => 'Creative problem-solver',
        'people' => 'People-focused helper',
        _ => 'Enjoys solving problems',
      });
    }

    if (a.creativity.trim().isNotEmpty) {
      chips.add(switch (a.creativity.toLowerCase()) {
        'very' => 'Values creativity',
        'somewhat' => 'Balanced with creativity',
        'not' => 'Practical & structured',
        _ => 'Has views on creativity',
      });
    }

    if (a.communication.trim().isNotEmpty) {
      chips.add(switch (a.communication.toLowerCase()) {
        'public' => 'Likes public speaking',
        'written' => 'Strong written communicator',
        'oneonone' => 'Great in 1-1 conversations',
        _ => 'Has communication preference',
      });
    }

    return chips;
  }

  static List<String> reasonChipsForCareer(String key, QuizAnswers a) {
    final reasons = <String>[];
    switch (key) {
      case 'Engineering':
        if (a.favoriteSubject.toLowerCase() == 'math' ||
            a.favoriteSubject.toLowerCase() == 'science') {
          reasons.add('Strong in STEM subjects');
        }
        if (a.problemSolving.toLowerCase() == 'analytical') {
          reasons.add('Enjoys analytical problem solving');
        }
        if (a.handsOnWork.toLowerCase() == 'yes') {
          reasons.add('Likes practical, hands-on work');
        }
      case 'Design':
        if (a.favoriteSubject.toLowerCase() == 'arts') {
          reasons.add('Creative & arts oriented');
        }
        if (a.problemSolving.toLowerCase() == 'creative') {
          reasons.add('Enjoys creative challenges');
        }
        if (a.creativity.toLowerCase() == 'very') {
          reasons.add('Wants creativity in career');
        }
      case 'Management':
      case 'Entrepreneurship':
        if (a.jobPreference.toLowerCase() == 'business') {
          reasons.add('Interested in business / entrepreneurship');
        }
        if (a.leadership.toLowerCase() == 'very' ||
            a.leadership.toLowerCase() == 'somewhat') {
          reasons.add('Comfortable taking leadership roles');
        }
        if (a.communication.toLowerCase() == 'public') {
          reasons.add('Enjoys presenting & speaking');
        }
      case 'Science':
        if (a.favoriteSubject.toLowerCase() == 'science') {
          reasons.add('Science is a favourite subject');
        }
        if (a.problemSolving.toLowerCase() == 'analytical') {
          reasons.add('Enjoys research & analysis');
        }
    }
    return reasons.toSet().toList(growable: false);
  }

  static List<College> collegesForCareer(String key, List<College> all) {
    final matched = all.where((college) {
      final type = (college.type ?? '').toLowerCase();
      final tags = college.tags.map((t) => t.toLowerCase()).toList();
      return switch (key) {
        'Engineering' =>
          type.contains('engineering') ||
              tags.any(
                (t) =>
                    t.contains('engineering') ||
                    t.contains('computer') ||
                    t.contains('ai'),
              ),
        'Design' => tags.any(
          (t) => t.contains('design') || t.contains('ui/ux'),
        ),
        'Management' || 'Entrepreneurship' =>
          type.contains('management') ||
              tags.any(
                (t) => t.contains('management') || t.contains('business'),
              ),
        'Science' => tags.any((t) => t.contains('science')),
        _ => false,
      };
    }).toList();

    matched.sort((a, b) {
      final rankA = a.rank ?? 0x7fffffff;
      final rankB = b.rank ?? 0x7fffffff;
      return rankA.compareTo(rankB);
    });
    return matched.take(4).toList(growable: false);
  }

  static List<Scholarship> scholarshipsForCareer(
    String key,
    List<Scholarship> all,
  ) {
    final matched = all.where((scholarship) {
      final tags = scholarship.tags.map((t) => t.toLowerCase()).toList();
      return switch (key) {
        'Engineering' => tags.any(
          (t) => t == 'stem' || t == 'tech' || t == 'science' || t == 'merit',
        ),
        'Design' => tags.any((t) => t == 'merit' || t == 'private'),
        'Management' || 'Entrepreneurship' => tags.any(
          (t) => t == 'need-based' || t == 'merit' || t.contains('business'),
        ),
        'Science' => tags.any((t) => t == 'science' || t == 'merit'),
        _ => false,
      };
    });
    return matched.take(4).toList(growable: false);
  }
}
