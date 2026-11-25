import 'package:flutter/foundation.dart';

import '../models/ai_career_plan.dart';
import '../models/profile.dart';
import '../models/quiz_models.dart';
import '../models/user_progress.dart';
import '../repositories/quiz_repository.dart';
import '../services/ai_career_mentor_service.dart';
import '../services/local_storage_service.dart';
import '../services/scoring_service.dart';

/// Manages aptitude quiz questions, draft/submitted answers, scores, attempt history,
/// saved career path, gamification XP/badges, and AI Mentor milestone completion.
class QuizGamificationProvider extends ChangeNotifier {
  QuizGamificationProvider({
    required this._quizRepository,
    required this._storage,
  });

  final QuizRepository _quizRepository;
  final LocalStorageService _storage;

  List<QuizQuestion> _questions = const [];
  Map<String, String> _draftAnswers = const {};
  QuizAnswers _submittedAnswers = const QuizAnswers();
  Map<String, int> _scores = const {};
  List<QuizAttempt> _quizHistory = const [];
  UserProgress _progress = const UserProgress();
  String _savedCareerKey = '';
  Set<String> _completedMilestones = const {};

  bool _isLoaded = false;
  String? _loadError;

  List<QuizQuestion> get questions => _questions;
  Map<String, String> get draftAnswers => _draftAnswers;
  QuizAnswers get submittedAnswers => _submittedAnswers;
  Map<String, int> get scores => _scores;
  List<QuizAttempt> get quizHistory => _quizHistory;
  UserProgress get progress => _progress;
  LevelInfo get levelInfo => ScoringService.calculateLevel(_progress.points);
  String get savedCareerKey => _savedCareerKey;
  String get savedCareerTitle =>
      ScoringService.mapCareerKeyToTitle(_savedCareerKey);
  Set<String> get completedMilestones => _completedMilestones;
  bool get isLoaded => _isLoaded;
  String? get loadError => _loadError;

  Future<void> load() async {
    _loadError = null;
    try {
      _questions = await _quizRepository.loadAll();
    } catch (e) {
      _loadError = e.toString();
    }

    _draftAnswers = await _storage.loadQuizDraft();
    _submittedAnswers = await _storage.loadQuizAnswers();
    _scores = await _storage.loadQuizScores();
    _quizHistory = await _storage.loadQuizHistory();
    _progress = await _storage.loadProgress();
    _savedCareerKey = await _storage.loadSavedCareerKey();
    _completedMilestones = await _storage.loadCompletedMilestones();
    _isLoaded = true;
    notifyListeners();
  }

  Future<void> selectDraftAnswer(String questionId, String optionValue) async {
    final updated = Map<String, String>.from(_draftAnswers);
    updated[questionId] = optionValue;
    _draftAnswers = Map<String, String>.unmodifiable(updated);
    notifyListeners();
    await _storage.saveQuizDraft(_draftAnswers);
  }

  /// Submits the current draft answers (or optional override), computes weighted scores,
  /// records attempt history, clears the partial draft, and grants +100 XP + "Quiz Master".
  Future<Map<String, int>> submitQuiz({DateTime? now}) async {
    final answers = QuizAnswers.fromAnswerMap(_draftAnswers);
    final computed = ScoringService.calculateQuizScores(answers);
    final topCareer = ScoringService.topCareerCategory(
      computed,
      fallback: 'General',
    );
    final topScore = computed[topCareer] ?? 0;

    final timestampDt = now ?? DateTime.now();
    final attempt = QuizAttempt(
      id: timestampDt.millisecondsSinceEpoch.toString(),
      timestamp: timestampDt.millisecondsSinceEpoch,
      formattedDate: _formatAttemptDate(timestampDt),
      topCareer: topCareer,
      topScore: topScore,
      scores: computed,
    );

    _submittedAnswers = answers;
    _scores = computed;
    _draftAnswers = const {};

    await _storage.saveQuizAnswers(answers);
    await _storage.saveQuizScores(computed);
    await _storage.clearQuizDraft();
    _quizHistory = await _storage.recordQuizAttempt(attempt);

    final updatedBadges = _progress.badges.contains('Quiz Master')
        ? _progress.badges
        : [..._progress.badges, 'Quiz Master'];
    _progress = _progress.copyWith(
      points: _progress.points + 100,
      completedQuiz: true,
      viewedResults: true,
      badges: List<String>.unmodifiable(updatedBadges),
    );
    await _storage.saveProgress(_progress);
    notifyListeners();
    return computed;
  }

  Future<bool> saveCareerPath(String careerKey) async {
    _savedCareerKey = careerKey;
    await _storage.saveSavedCareerKey(careerKey);
    final result = await _storage.grantOneTimeReward(
      rewardKey: 'career_path_saved',
      points: 50,
      badge: 'Career Path Selected',
    );
    _progress = result.progress;
    notifyListeners();
    return result.granted;
  }

  Future<void> markViewedResults() async {
    if (_progress.viewedResults) return;
    _progress = _progress.copyWith(viewedResults: true);
    await _storage.saveProgress(_progress);
    notifyListeners();
  }

  Future<bool> markCollegesExplored() async {
    final result = await _storage.grantOneTimeReward(
      rewardKey: 'explored_colleges',
      points: 30,
      badge: 'College Explorer',
      markExploredColleges: true,
    );
    _progress = result.progress;
    notifyListeners();
    return result.granted;
  }

  Future<bool> markScholarshipsChecked() async {
    final result = await _storage.grantOneTimeReward(
      rewardKey: 'checked_scholarships',
      points: 40,
      badge: 'Scholarship Seeker',
      markCheckedScholarships: true,
    );
    _progress = result.progress;
    notifyListeners();
    return result.granted;
  }

  /// Toggles a mentor roadmap milestone and awards +25 XP at most once per milestone ID.
  Future<bool> toggleMilestone(String milestoneId) async {
    final toggleResult = await _storage.toggleMilestone(milestoneId);
    _completedMilestones = toggleResult.completedIds;
    var xpAwarded = false;
    if (toggleResult.isNowCompleted) {
      final rewardResult = await _storage.grantOneTimeReward(
        rewardKey: 'milestone_$milestoneId',
        points: 25,
      );
      _progress = rewardResult.progress;
      xpAwarded = rewardResult.granted;
    }
    notifyListeners();
    return xpAwarded;
  }

  Future<bool> grantScholarshipAwardedReward(String scholarshipId) async {
    final result = await _storage.grantOneTimeReward(
      rewardKey: 'scholarship_awarded_$scholarshipId',
      points: 100,
      badge: 'Scholarship Awardee',
    );
    _progress = result.progress;
    notifyListeners();
    return result.granted;
  }

  Future<void> grantCommunityQuestionReward() async {
    _progress = await _storage.addPointsAndBadge(points: 35);
    notifyListeners();
  }

  Future<void> grantCommunityAnswerReward() async {
    _progress = await _storage.addPointsAndBadge(
      points: 50,
      badge: 'Community Helper',
    );
    notifyListeners();
  }

  Future<void> resetGamificationProgress() async {
    await _storage.resetGamificationProgress();
    _progress = const UserProgress();
    notifyListeners();
  }

  Future<void> resetAllQuizAndProgress() async {
    await _storage.clearAllQuizAndProgressData();
    _progress = const UserProgress();
    _draftAnswers = const {};
    _submittedAnswers = const QuizAnswers();
    _scores = const {};
    _quizHistory = const [];
    _savedCareerKey = '';
    notifyListeners();
  }

  AiCareerPlan generateMentorPlan(Profile profile) {
    return AiCareerMentorService.generatePlan(
      profile: profile,
      scores: _scores,
      progress: _progress,
    );
  }

  static String _formatAttemptDate(DateTime dt) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    final month = months[dt.month - 1];
    final day = dt.day.toString().padLeft(2, '0');
    final hour = dt.hour.toString().padLeft(2, '0');
    final minute = dt.minute.toString().padLeft(2, '0');
    return '$month $day, ${dt.year} • $hour:$minute';
  }
}
