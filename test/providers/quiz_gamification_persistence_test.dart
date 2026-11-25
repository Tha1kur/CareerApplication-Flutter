import 'package:career_application_flutter/providers/quiz_gamification_provider.dart';
import 'package:career_application_flutter/repositories/quiz_repository.dart';
import 'package:career_application_flutter/services/local_storage_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  Future<QuizGamificationProvider> createLoadedProvider() async {
    final provider = QuizGamificationProvider(
      quizRepository: QuizRepository(),
      storage: LocalStorageService(),
    );
    await provider.load();
    return provider;
  }

  group('QuizGamificationProvider persistence & P1 reward deduplication', () {
    test(
      'partial quiz draft persists across reload and clears on submit',
      () async {
        final p1 = await createLoadedProvider();
        await p1.selectDraftAnswer('favoriteSubject', 'math');
        await p1.selectDraftAnswer('handsOnWork', 'yes');

        // Simulate process restart with fresh provider
        final p2 = await createLoadedProvider();
        expect(p2.draftAnswers['favoriteSubject'], 'math');
        expect(p2.draftAnswers['handsOnWork'], 'yes');

        await p2.selectDraftAnswer('jobPreference', 'private');
        await p2.selectDraftAnswer('workEnvironment', 'mixed');
        await p2.selectDraftAnswer('leadership', 'somewhat');
        await p2.selectDraftAnswer('problemSolving', 'analytical');
        await p2.selectDraftAnswer('creativity', 'somewhat');
        await p2.selectDraftAnswer('communication', 'written');

        final scores = await p2.submitQuiz(now: DateTime(2026, 11, 25, 10, 30));
        expect(scores['Engineering'], 26);
        expect(p2.draftAnswers, isEmpty);
        expect(p2.progress.points, 100);
        expect(p2.progress.badges, contains('Quiz Master'));
        expect(p2.quizHistory.length, 1);
        expect(p2.quizHistory.first.topCareer, 'Engineering');

        // Verify history, scores, and cleared draft survive restart
        final p3 = await createLoadedProvider();
        expect(p3.draftAnswers, isEmpty);
        expect(p3.scores['Engineering'], 26);
        expect(p3.quizHistory.length, 1);
        expect(p3.progress.points, 100);
      },
    );

    test(
      'one-time XP rewards cannot be farmed via repeated actions or restarts',
      () async {
        final provider = await createLoadedProvider();

        // Save career path twice -> +50 XP only once
        expect(await provider.saveCareerPath('Engineering'), isTrue);
        expect(await provider.saveCareerPath('Design'), isFalse);
        expect(provider.savedCareerKey, 'Design');
        expect(provider.progress.points, 50);

        // Visit colleges twice -> +30 XP only once
        expect(await provider.markCollegesExplored(), isTrue);
        expect(await provider.markCollegesExplored(), isFalse);
        expect(provider.progress.points, 80);
        expect(provider.progress.exploredColleges, isTrue);

        // Visit scholarships twice -> +40 XP only once
        expect(await provider.markScholarshipsChecked(), isTrue);
        expect(await provider.markScholarshipsChecked(), isFalse);
        expect(provider.progress.points, 120);
        expect(provider.progress.checkedScholarships, isTrue);

        // Toggle milestone check -> uncheck -> recheck -> +25 XP only once
        expect(await provider.toggleMilestone('eng_1'), isTrue);
        expect(provider.progress.points, 145);
        expect(await provider.toggleMilestone('eng_1'), isFalse);
        expect(await provider.toggleMilestone('eng_1'), isFalse);
        expect(provider.progress.points, 145);

        // Scholarship awarded twice -> +100 XP only once per scholarshipId
        expect(await provider.grantScholarshipAwardedReward('nsf'), isTrue);
        expect(await provider.grantScholarshipAwardedReward('nsf'), isFalse);
        expect(provider.progress.points, 245);
        expect(provider.progress.badges, contains('Scholarship Awardee'));

        // Different scholarship ID still grants reward once
        expect(await provider.grantScholarshipAwardedReward('inspire'), isTrue);
        expect(provider.progress.points, 345);

        // Restart and retry -> still deduplicated!
        final reloaded = await createLoadedProvider();
        expect(await reloaded.markCollegesExplored(), isFalse);
        expect(await reloaded.markScholarshipsChecked(), isFalse);
        expect(reloaded.progress.points, 345);
      },
    );

    test('reset scopes clear only intended data', () async {
      final provider = await createLoadedProvider();
      await provider.selectDraftAnswer('favoriteSubject', 'math');
      await provider.submitQuiz();
      await provider.saveCareerPath('Engineering');
      await provider.selectDraftAnswer('favoriteSubject', 'arts');

      // Reset gamification only -> keeps scores, history, saved path
      await provider.resetGamificationProgress();
      expect(provider.progress.points, 0);
      expect(provider.progress.badges, isEmpty);
      expect(provider.scores['Engineering'], 10);
      expect(provider.quizHistory.length, 1);
      expect(provider.savedCareerKey, 'Engineering');

      // After gamification reset, one-time rewards can be earned again
      expect(await provider.markCollegesExplored(), isTrue);
      expect(provider.progress.points, 30);

      // Reset all quiz & progress -> clears everything including draft & saved path
      await provider.resetAllQuizAndProgress();
      final reloaded = await createLoadedProvider();
      expect(reloaded.progress.points, 0);
      expect(reloaded.scores, isEmpty);
      expect(reloaded.quizHistory, isEmpty);
      expect(reloaded.draftAnswers, isEmpty);
      expect(reloaded.savedCareerKey, '');
    });
  });
}
