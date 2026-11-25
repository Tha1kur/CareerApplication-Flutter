import 'dart:async';
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/community_models.dart';
import '../models/profile.dart';
import '../models/quiz_models.dart';
import '../models/tracked_scholarship.dart';
import '../models/user_progress.dart';

/// Typed local persistence abstraction backed by [SharedPreferences].
/// Uses a serialized write queue to keep read-modify-write mutations race-free.
class LocalStorageService {
  LocalStorageService({SharedPreferences? prefs}) : _prefsOverride = prefs;

  final SharedPreferences? _prefsOverride;
  SharedPreferences? _cachedPrefs;
  Future<void> _writeQueue = Future<void>.value();

  // Storage keys aligned with Kotlin DataStoreManager
  static const String keyProfileName = 'profile_name';
  static const String keyProfileAge = 'profile_age';
  static const String keyProfileGoal = 'profile_goal';
  static const String keyThemeMode = 'theme_mode';
  static const String keySavedCareer = 'saved_career_key';

  static const String keyPoints = 'points';
  static const String keyBadges = 'badges';
  static const String keyAwardedRewards = 'awarded_reward_keys';
  static const String keyCompletedQuiz = 'completed_quiz';
  static const String keyViewedResults = 'viewed_results';
  static const String keyExploredColleges = 'explored_colleges';
  static const String keyCheckedScholarships = 'checked_scholarships';

  static const String keyQuizPartialAnswers = 'quiz_partial_answers';
  static const String keyQuizAnswers = 'quiz_answers_json';
  static const String keyQuizScores = 'quiz_scores_json';
  static const String keyQuizHistory = 'quiz_history_json';

  static const String keySavedColleges = 'saved_colleges';
  static const String keySavedScholarships = 'saved_scholarships';

  static const String keyCollegesSearch = 'colleges_search';
  static const String keyCollegesFilter = 'colleges_filter';
  static const String keyScholarshipsSearch = 'scholarships_search';
  static const String keyScholarshipsFilter = 'scholarships_filter';

  static const String keyCompletedMilestones = 'completed_milestones';
  static const String keyTrackedScholarships = 'tracked_scholarships_json';
  static const String keyCommunityQuestions = 'community_questions_json';
  static const String keyUpvotedQuestions = 'upvoted_questions';

  Future<SharedPreferences> _getPrefs() async {
    if (_prefsOverride != null) return _prefsOverride;
    return _cachedPrefs ??= await SharedPreferences.getInstance();
  }

  /// Ensures multi-step read-modify-write operations run sequentially.
  Future<T> _serialized<T>(Future<T> Function(SharedPreferences prefs) op) {
    final completer = Completer<T>();
    _writeQueue = _writeQueue.then((_) async {
      try {
        final prefs = await _getPrefs();
        final result = await op(prefs);
        completer.complete(result);
      } catch (error, stackTrace) {
        completer.completeError(error, stackTrace);
      }
    });
    return completer.future;
  }

  // ---------------- Profile ----------------

  Future<Profile> loadProfile() async {
    final prefs = await _getPrefs();
    return Profile(
      name: prefs.getString(keyProfileName) ?? '',
      age: prefs.getInt(keyProfileAge) ?? 0,
      goal: prefs.getString(keyProfileGoal) ?? '',
    );
  }

  Future<void> saveProfile(Profile profile) {
    return _serialized((prefs) async {
      await prefs.setString(keyProfileName, profile.name);
      await prefs.setInt(keyProfileAge, profile.age);
      await prefs.setString(keyProfileGoal, profile.goal);
    });
  }

  Future<void> clearProfile() {
    return _serialized((prefs) async {
      await prefs.remove(keyProfileName);
      await prefs.remove(keyProfileAge);
      await prefs.remove(keyProfileGoal);
    });
  }

  // ---------------- Theme & Saved Career ----------------

  Future<String> loadThemeMode() async {
    final prefs = await _getPrefs();
    return prefs.getString(keyThemeMode) ?? 'system';
  }

  Future<void> saveThemeMode(String mode) {
    return _serialized((prefs) => prefs.setString(keyThemeMode, mode));
  }

  Future<String> loadSavedCareerKey() async {
    final prefs = await _getPrefs();
    return prefs.getString(keySavedCareer) ?? '';
  }

  Future<void> saveSavedCareerKey(String careerKey) {
    return _serialized((prefs) => prefs.setString(keySavedCareer, careerKey));
  }

  // ---------------- Gamification Progress & Atomic Rewards ----------------

  Future<UserProgress> loadProgress() async {
    final prefs = await _getPrefs();
    return UserProgress(
      points: prefs.getInt(keyPoints) ?? 0,
      badges: List<String>.unmodifiable(
        prefs.getStringList(keyBadges) ?? const [],
      ),
      completedQuiz: prefs.getBool(keyCompletedQuiz) ?? false,
      viewedResults: prefs.getBool(keyViewedResults) ?? false,
      exploredColleges: prefs.getBool(keyExploredColleges) ?? false,
      checkedScholarships: prefs.getBool(keyCheckedScholarships) ?? false,
    );
  }

  Future<void> saveProgress(UserProgress progress) {
    return _serialized((prefs) async {
      await prefs.setInt(keyPoints, progress.points);
      await prefs.setStringList(keyBadges, progress.badges.toSet().toList());
      await prefs.setBool(keyCompletedQuiz, progress.completedQuiz);
      await prefs.setBool(keyViewedResults, progress.viewedResults);
      await prefs.setBool(keyExploredColleges, progress.exploredColleges);
      await prefs.setBool(keyCheckedScholarships, progress.checkedScholarships);
    });
  }

  Future<UserProgress> addPointsAndBadge({int points = 0, String? badge}) {
    return _serialized((prefs) async {
      final currentPoints = prefs.getInt(keyPoints) ?? 0;
      if (points != 0) {
        await prefs.setInt(keyPoints, currentPoints + points);
      }
      if (badge != null && badge.trim().isNotEmpty) {
        final badges = (prefs.getStringList(keyBadges) ?? const []).toSet();
        badges.add(badge);
        await prefs.setStringList(keyBadges, badges.toList());
      }
      return _readProgressSync(prefs);
    });
  }

  /// Atomically grants a one-time reward identified by [rewardKey].
  /// Returns `true` when newly granted, `false` if already granted previously.
  Future<({bool granted, UserProgress progress})> grantOneTimeReward({
    required String rewardKey,
    required int points,
    String? badge,
    bool markExploredColleges = false,
    bool markCheckedScholarships = false,
  }) {
    return _serialized((prefs) async {
      if (markExploredColleges) {
        await prefs.setBool(keyExploredColleges, true);
      }
      if (markCheckedScholarships) {
        await prefs.setBool(keyCheckedScholarships, true);
      }

      final awarded = (prefs.getStringList(keyAwardedRewards) ?? const [])
          .toSet();
      var granted = false;
      if (!awarded.contains(rewardKey)) {
        awarded.add(rewardKey);
        await prefs.setStringList(keyAwardedRewards, awarded.toList());

        if (points > 0) {
          final currentPoints = prefs.getInt(keyPoints) ?? 0;
          await prefs.setInt(keyPoints, currentPoints + points);
        }
        if (badge != null && badge.trim().isNotEmpty) {
          final badges = (prefs.getStringList(keyBadges) ?? const []).toSet();
          badges.add(badge);
          await prefs.setStringList(keyBadges, badges.toList());
        }
        granted = true;
      }

      return (granted: granted, progress: _readProgressSync(prefs));
    });
  }

  Future<void> resetGamificationProgress() {
    return _serialized((prefs) async {
      await prefs.setInt(keyPoints, 0);
      await prefs.setStringList(keyBadges, const []);
      await prefs.setBool(keyCompletedQuiz, false);
      await prefs.setBool(keyViewedResults, false);
      await prefs.setBool(keyExploredColleges, false);
      await prefs.setBool(keyCheckedScholarships, false);
      await prefs.remove(keyAwardedRewards);
    });
  }

  UserProgress _readProgressSync(SharedPreferences prefs) {
    return UserProgress(
      points: prefs.getInt(keyPoints) ?? 0,
      badges: List<String>.unmodifiable(
        prefs.getStringList(keyBadges) ?? const [],
      ),
      completedQuiz: prefs.getBool(keyCompletedQuiz) ?? false,
      viewedResults: prefs.getBool(keyViewedResults) ?? false,
      exploredColleges: prefs.getBool(keyExploredColleges) ?? false,
      checkedScholarships: prefs.getBool(keyCheckedScholarships) ?? false,
    );
  }

  // ---------------- Quiz Drafts, Answers, Scores & History ----------------

  Future<Map<String, String>> loadQuizDraft() async {
    final prefs = await _getPrefs();
    final raw = prefs.getString(keyQuizPartialAnswers);
    if (raw == null || raw.trim().isEmpty) return const {};
    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map) {
        return Map<String, String>.unmodifiable({
          for (final entry in decoded.entries)
            if (entry.key != null && entry.value != null)
              entry.key.toString(): entry.value.toString(),
        });
      }
    } catch (_) {}
    return const {};
  }

  Future<void> saveQuizDraft(Map<String, String> draft) {
    return _serialized(
      (prefs) => prefs.setString(keyQuizPartialAnswers, jsonEncode(draft)),
    );
  }

  Future<void> clearQuizDraft() {
    return _serialized((prefs) => prefs.remove(keyQuizPartialAnswers));
  }

  Future<QuizAnswers> loadQuizAnswers() async {
    final prefs = await _getPrefs();
    final raw = prefs.getString(keyQuizAnswers);
    if (raw == null || raw.trim().isEmpty) return const QuizAnswers();
    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map<String, dynamic>) {
        return QuizAnswers.fromJson(decoded);
      }
    } catch (_) {}
    return const QuizAnswers();
  }

  Future<void> saveQuizAnswers(QuizAnswers answers) {
    return _serialized(
      (prefs) => prefs.setString(keyQuizAnswers, jsonEncode(answers.toJson())),
    );
  }

  Future<Map<String, int>> loadQuizScores() async {
    final prefs = await _getPrefs();
    final raw = prefs.getString(keyQuizScores);
    if (raw == null || raw.trim().isEmpty) return const {};
    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map) {
        return Map<String, int>.unmodifiable({
          for (final entry in decoded.entries)
            if (entry.key != null && entry.value is num)
              entry.key.toString(): (entry.value as num).toInt(),
        });
      }
    } catch (_) {}
    return const {};
  }

  Future<void> saveQuizScores(Map<String, int> scores) {
    return _serialized(
      (prefs) => prefs.setString(keyQuizScores, jsonEncode(scores)),
    );
  }

  Future<List<QuizAttempt>> loadQuizHistory() async {
    final prefs = await _getPrefs();
    final raw = prefs.getString(keyQuizHistory);
    if (raw == null || raw.trim().isEmpty) return const [];
    try {
      final decoded = jsonDecode(raw);
      if (decoded is List) {
        return decoded
            .whereType<Map<String, dynamic>>()
            .map(QuizAttempt.fromJson)
            .toList(growable: false);
      }
    } catch (_) {}
    return const [];
  }

  Future<List<QuizAttempt>> recordQuizAttempt(QuizAttempt attempt) {
    return _serialized((prefs) async {
      final current = await loadQuizHistory();
      final updated = [attempt, ...current];
      await prefs.setString(
        keyQuizHistory,
        jsonEncode(updated.map((a) => a.toJson()).toList(growable: false)),
      );
      return List<QuizAttempt>.unmodifiable(updated);
    });
  }

  Future<void> clearAllQuizAndProgressData() {
    return _serialized((prefs) async {
      await prefs.setInt(keyPoints, 0);
      await prefs.setStringList(keyBadges, const []);
      await prefs.setBool(keyCompletedQuiz, false);
      await prefs.setBool(keyViewedResults, false);
      await prefs.setBool(keyExploredColleges, false);
      await prefs.setBool(keyCheckedScholarships, false);
      await prefs.remove(keyAwardedRewards);
      await prefs.remove(keyQuizPartialAnswers);
      await prefs.remove(keyQuizAnswers);
      await prefs.remove(keyQuizScores);
      await prefs.remove(keyQuizHistory);
      await prefs.remove(keySavedCareer);
    });
  }

  // ---------------- Bookmarks ----------------

  Future<Set<String>> loadSavedCollegeIds() async {
    final prefs = await _getPrefs();
    return Set<String>.unmodifiable(
      (prefs.getStringList(keySavedColleges) ?? const []).toSet(),
    );
  }

  Future<Set<String>> toggleSavedCollege(String collegeId) {
    return _serialized((prefs) async {
      final set = (prefs.getStringList(keySavedColleges) ?? const []).toSet();
      if (!set.remove(collegeId)) {
        set.add(collegeId);
      }
      await prefs.setStringList(keySavedColleges, set.toList());
      return Set<String>.unmodifiable(set);
    });
  }

  Future<Set<String>> loadSavedScholarshipIds() async {
    final prefs = await _getPrefs();
    return Set<String>.unmodifiable(
      (prefs.getStringList(keySavedScholarships) ?? const []).toSet(),
    );
  }

  Future<Set<String>> toggleSavedScholarship(String scholarshipId) {
    return _serialized((prefs) async {
      final set = (prefs.getStringList(keySavedScholarships) ?? const [])
          .toSet();
      if (!set.remove(scholarshipId)) {
        set.add(scholarshipId);
      }
      await prefs.setStringList(keySavedScholarships, set.toList());
      return Set<String>.unmodifiable(set);
    });
  }

  // ---------------- Search & Filter Persistence ----------------

  Future<({String search, String filter})> loadCollegesFilterState() async {
    final prefs = await _getPrefs();
    final filter = prefs.getString(keyCollegesFilter) ?? 'All';
    return (
      search: prefs.getString(keyCollegesSearch) ?? '',
      filter: filter.trim().isEmpty ? 'All' : filter,
    );
  }

  Future<void> saveCollegesFilterState({String? search, String? filter}) {
    return _serialized((prefs) async {
      if (search != null) await prefs.setString(keyCollegesSearch, search);
      if (filter != null) await prefs.setString(keyCollegesFilter, filter);
    });
  }

  Future<({String search, String category})>
  loadScholarshipsFilterState() async {
    final prefs = await _getPrefs();
    final category = prefs.getString(keyScholarshipsFilter) ?? 'All';
    return (
      search: prefs.getString(keyScholarshipsSearch) ?? '',
      category: category.trim().isEmpty ? 'All' : category,
    );
  }

  Future<void> saveScholarshipsFilterState({String? search, String? category}) {
    return _serialized((prefs) async {
      if (search != null) await prefs.setString(keyScholarshipsSearch, search);
      if (category != null) {
        await prefs.setString(keyScholarshipsFilter, category);
      }
    });
  }

  // ---------------- AI Mentor Milestones ----------------

  Future<Set<String>> loadCompletedMilestones() async {
    final prefs = await _getPrefs();
    return Set<String>.unmodifiable(
      (prefs.getStringList(keyCompletedMilestones) ?? const []).toSet(),
    );
  }

  Future<({bool isNowCompleted, Set<String> completedIds})> toggleMilestone(
    String milestoneId,
  ) {
    return _serialized((prefs) async {
      final set = (prefs.getStringList(keyCompletedMilestones) ?? const [])
          .toSet();
      final isNowCompleted = set.add(milestoneId);
      if (!isNowCompleted) {
        set.remove(milestoneId);
      }
      await prefs.setStringList(keyCompletedMilestones, set.toList());
      return (
        isNowCompleted: isNowCompleted,
        completedIds: Set<String>.unmodifiable(set),
      );
    });
  }

  // ---------------- Application Tracker ----------------

  Future<List<TrackedScholarship>> loadTrackedScholarships() async {
    final prefs = await _getPrefs();
    final raw = prefs.getString(keyTrackedScholarships);
    if (raw == null || raw.trim().isEmpty) return const [];
    try {
      final decoded = jsonDecode(raw);
      if (decoded is List) {
        return decoded
            .whereType<Map<String, dynamic>>()
            .map(TrackedScholarship.fromJson)
            .toList(growable: false);
      }
    } catch (_) {}
    return const [];
  }

  Future<List<TrackedScholarship>> saveTrackedScholarships(
    List<TrackedScholarship> items,
  ) {
    return _serialized((prefs) async {
      await prefs.setString(
        keyTrackedScholarships,
        jsonEncode(items.map((e) => e.toJson()).toList(growable: false)),
      );
      return List<TrackedScholarship>.unmodifiable(items);
    });
  }

  // ---------------- Community ----------------

  Future<List<CommunityQuestion>> loadCustomCommunityQuestions() async {
    final prefs = await _getPrefs();
    final raw = prefs.getString(keyCommunityQuestions);
    if (raw == null || raw.trim().isEmpty) return const [];
    try {
      final decoded = jsonDecode(raw);
      if (decoded is List) {
        return decoded
            .whereType<Map<String, dynamic>>()
            .map(CommunityQuestion.fromJson)
            .toList(growable: false);
      }
    } catch (_) {}
    return const [];
  }

  Future<void> saveCommunityQuestions(List<CommunityQuestion> questions) {
    return _serialized(
      (prefs) => prefs.setString(
        keyCommunityQuestions,
        jsonEncode(questions.map((q) => q.toJson()).toList(growable: false)),
      ),
    );
  }

  Future<Set<String>> loadUpvotedQuestionIds() async {
    final prefs = await _getPrefs();
    return Set<String>.unmodifiable(
      (prefs.getStringList(keyUpvotedQuestions) ?? const []).toSet(),
    );
  }

  Future<Set<String>> toggleQuestionUpvote(String questionId) {
    return _serialized((prefs) async {
      final set = (prefs.getStringList(keyUpvotedQuestions) ?? const [])
          .toSet();
      if (!set.remove(questionId)) {
        set.add(questionId);
      }
      await prefs.setStringList(keyUpvotedQuestions, set.toList());
      return Set<String>.unmodifiable(set);
    });
  }
}
