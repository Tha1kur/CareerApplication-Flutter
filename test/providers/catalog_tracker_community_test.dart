import 'package:career_application_flutter/models/college.dart';
import 'package:career_application_flutter/models/tracked_scholarship.dart';
import 'package:career_application_flutter/providers/catalog_provider.dart';
import 'package:career_application_flutter/providers/community_provider.dart';
import 'package:career_application_flutter/providers/profile_provider.dart';
import 'package:career_application_flutter/providers/tracker_provider.dart';
import 'package:career_application_flutter/repositories/college_repository.dart';
import 'package:career_application_flutter/repositories/community_repository.dart';
import 'package:career_application_flutter/repositories/scholarship_repository.dart';
import 'package:career_application_flutter/services/local_storage_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('CatalogProvider (colleges, scholarships, bookmarks, compare, filter restore)', () {
    test(
      'filters work together, restore on reload, and compare caps at 3',
      () async {
        final storage = LocalStorageService();
        final catalog = CatalogProvider(
          collegeRepository: CollegeRepository(),
          scholarshipRepository: ScholarshipRepository(),
          storage: storage,
        );
        await catalog.load();

        expect(catalog.allColleges.length, 4);
        expect(catalog.allScholarships.length, 5);

        // Combined college search + filter
        await catalog.setCollegeSearchQuery('Ahmedabad');
        expect(catalog.filteredColleges.map((c) => c.id).toSet(), {
          'nid',
          'iim-a',
        });

        await catalog.setCollegeTypeFilter('Design');
        expect(catalog.filteredColleges.map((c) => c.id).toList(), ['nid']);

        // Combined scholarship search + category
        await catalog.setScholarshipSearchQuery('income');
        await catalog.setScholarshipCategoryFilter('Need-based');
        expect(catalog.filteredScholarships.map((s) => s.id).toList(), [
          'obc-postmatric',
          'tata-scholar',
        ]);

        // Bookmarks
        await catalog.toggleSavedCollege('iitb');
        await catalog.toggleSavedScholarship('inspire');

        // Reload simulates restart -> P1 fix verifies search & filter restore!
        final reloaded = CatalogProvider(
          collegeRepository: CollegeRepository(),
          scholarshipRepository: ScholarshipRepository(),
          storage: LocalStorageService(),
        );
        await reloaded.load();
        expect(reloaded.collegeSearchQuery, 'Ahmedabad');
        expect(reloaded.collegeTypeFilter, 'Design');
        expect(reloaded.scholarshipSearchQuery, 'income');
        expect(reloaded.scholarshipCategoryFilter, 'Need-based');
        expect(reloaded.savedCollegeIds, {'iitb'});
        expect(reloaded.savedScholarshipIds, {'inspire'});

        // Comparison max 3 enforcement
        expect(reloaded.toggleCompareCollege('iitb'), isTrue);
        expect(reloaded.toggleCompareCollege('nid'), isTrue);
        expect(reloaded.toggleCompareCollege('iim-a'), isTrue);
        expect(reloaded.toggleCompareCollege('iitk'), isFalse); // capped at 3
        expect(reloaded.compareCollegeIds.length, 3);

        final insights = CollegeRepository.computeComparisonInsights(
          reloaded.comparedColleges,
        );
        expect(insights.bestRankedCollege?.id, 'iitb');
        expect(
          insights.categories,
          containsAll(['Engineering', 'Design', 'Management']),
        );

        // Unranked colleges fallback safely
        final unrankedInsights = CollegeRepository.computeComparisonInsights(
          const [
            College(id: 'u1', name: 'College A'),
            College(id: 'u2', name: 'College B'),
          ],
        );
        expect(unrankedInsights.bestRankedCollege, isNull);
      },
    );
  });

  group('TrackerProvider', () {
    test(
      'import, stages, document checklist, notes, untrack persist cleanly',
      () async {
        final scholarships = await ScholarshipRepository().loadAll();
        final tracker = TrackerProvider(storage: LocalStorageService());
        await tracker.load();

        // Import saved scholarships without duplicates
        final added = await tracker.importSavedScholarships(
          scholarships.take(2).toList(),
        );
        expect(added, 2);
        expect(
          await tracker.importSavedScholarships(scholarships.take(2).toList()),
          0,
        );
        expect(tracker.countForStage(ApplicationStage.discovered), 2);

        // Update stage, checklist, notes
        await tracker.updateStage('nsf', ApplicationStage.docsReady);
        await tracker.toggleDocument('nsf', kStandardRequiredDocuments[0]);
        await tracker.toggleDocument('nsf', kStandardRequiredDocuments[1]);
        await tracker.saveNotes('nsf', 'App ID #NSP-2026-01');

        // Reload & verify persistence
        final reloaded = TrackerProvider(storage: LocalStorageService());
        await reloaded.load();
        final nsf = reloaded.items.firstWhere((e) => e.scholarshipId == 'nsf');
        expect(nsf.stage, ApplicationStage.docsReady);
        expect(nsf.completedStandardDocsCount, 2);
        expect(nsf.documentProgressFraction, closeTo(0.4, 0.001));
        expect(nsf.notes, 'App ID #NSP-2026-01');

        // Filter by stage & untrack
        reloaded.setStageFilter(ApplicationStage.docsReady);
        expect(reloaded.filteredItems.length, 1);

        await reloaded.untrackScholarship('nsf');
        expect(reloaded.items.length, 1);
      },
    );
  });

  group('CommunityProvider', () {
    test(
      'seed threads, filters, post, answer, upvote persist across restarts',
      () async {
        final community = CommunityProvider(
          repository: CommunityRepository(storage: LocalStorageService()),
        );
        await community.load();

        expect(community.questions.length, 5);

        community.setSelectedCategory('Design');
        expect(community.filteredQuestions.length, 1);
        expect(community.filteredQuestions.first.id, 'q_2');

        community.setSelectedCategory('All');
        community.setSearchQuery('figma');
        expect(community.filteredQuestions.map((q) => q.id).toList(), ['q_2']);

        // Post new question, add answer, upvote
        final posted = await community.postQuestion(
          title: 'Best resources for Flutter state management?',
          content: 'Comparing Provider vs Riverpod for student projects.',
          category: 'Technology',
          authorName: 'Aditya',
          authorRole: 'B.Tech CSE',
        );
        await community.addAnswer(
          questionId: posted.id,
          content:
              'Provider with ChangeNotifier is simple and easy to explain.',
          authorName: 'Senior Dev',
          authorBadge: 'Alumni',
          isVerifiedMentor: true,
        );
        await community.toggleUpvote(posted.id);

        // Reload and verify persistence + no duplicate seed threads
        final reloaded = CommunityProvider(
          repository: CommunityRepository(storage: LocalStorageService()),
        );
        await reloaded.load();
        expect(reloaded.questions.length, 6);
        expect(reloaded.questions.first.id, posted.id);
        expect(reloaded.questions.first.answers.length, 1);
        expect(reloaded.isUpvoted(posted.id), isTrue);
        expect(reloaded.displayUpvotes(reloaded.questions.first), 2);
      },
    );
  });

  group('ProfileProvider & corrupt storage resilience', () {
    test(
      'profile saves, reloads, clears, and corrupt JSON falls back safely',
      () async {
        SharedPreferences.setMockInitialValues({
          LocalStorageService.keyQuizScores: '{not valid json',
          LocalStorageService.keyTrackedScholarships: 'corrupt',
        });

        final storage = LocalStorageService();
        expect(await storage.loadQuizScores(), isEmpty);
        expect(await storage.loadTrackedScholarships(), isEmpty);

        final profileProvider = ProfileProvider(storage: storage);
        await profileProvider.load();
        await profileProvider.saveProfile(
          name: 'Aditya Yadav',
          age: 21,
          goal: 'Build mobile products',
        );

        final reloaded = ProfileProvider(storage: LocalStorageService());
        await reloaded.load();
        expect(reloaded.profile.name, 'Aditya Yadav');
        expect(reloaded.profile.age, 21);
        expect(reloaded.profile.goal, 'Build mobile products');

        await reloaded.clearProfile();
        expect(reloaded.profile.isEmpty, isTrue);
      },
    );
  });
}
