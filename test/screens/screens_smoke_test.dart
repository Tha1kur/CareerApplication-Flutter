import 'package:career_application_flutter/app.dart';
import 'package:career_application_flutter/core/constants/app_routes.dart';
import 'package:career_application_flutter/core/router/app_router.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  Future<AppDependencies> pumpRoute(
    WidgetTester tester,
    String route, {
    AppDependencies? existingDeps,
  }) async {
    final deps = existingDeps ?? AppDependencies.create();
    if (!deps.themeProvider.isLoaded) {
      await tester.runAsync(deps.loadAll);
    }
    await tester.pumpWidget(
      CareerGuidanceApp(
        key: ValueKey(route),
        dependencies: deps,
        router: createAppRouter(initialLocation: route),
      ),
    );
    await tester.pumpAndSettle();
    return deps;
  }

  group('End-to-end widget verification across all 16 routes', () {
    testWidgets(
      'Quiz -> validation -> submit -> Recommendations -> Save Path -> Results',
      (WidgetTester tester) async {
        final deps = await pumpRoute(tester, AppRoutes.quiz);

        // Navigate to last question without answering -> Submit shows warning & jumps back
        for (var i = 0; i < 7; i++) {
          await tester.tap(find.text('Next'));
          await tester.pumpAndSettle();
        }
        await tester.tap(find.text('Submit'));
        await tester.pumpAndSettle();
        expect(
          find.textContaining('Please answer all questions'),
          findsOneWidget,
        );
        expect(find.text('Question 1 of 8'), findsOneWidget);

        // Wait for floating validation SnackBar to dismiss before tapping Next
        await tester.pump(const Duration(seconds: 5));
        await tester.pumpAndSettle();

        // Answer all 8 questions cleanly
        final firstOptionLabels = [
          'Mathematics',
          'Yes, I love working with my hands',
          'Private Job (Growth & Innovation)',
          'Mix of both',
          'Somewhat comfortable',
          'Analytical & Logical problems',
          'Somewhat important',
          'Written communication',
        ];
        for (var i = 0; i < firstOptionLabels.length; i++) {
          await tester.tap(find.text(firstOptionLabels[i]));
          await tester.pumpAndSettle();
          if (i < firstOptionLabels.length - 1) {
            await tester.tap(find.text('Next'));
            await tester.pumpAndSettle();
          }
        }

        await tester.tap(find.text('Submit'));
        await tester.pumpAndSettle();

        // Should land on Career Recommendations with Engineering top match
        expect(find.text('Career Recommendations'), findsOneWidget);
        expect(find.text('Your top match: Engineering'), findsOneWidget);
        expect(deps.quizProvider.progress.points, 100);

        // Save career path -> +50 XP once
        final saveBtn = find.text('Save This Path');
        await tester.ensureVisible(saveBtn);
        await tester.tap(saveBtn);
        await tester.pumpAndSettle();
        expect(find.text('Path Saved'), findsOneWidget);
        expect(deps.quizProvider.progress.points, 150);

        // Wait for SnackBar to dismiss before tapping bottom button
        await tester.pump(const Duration(seconds: 5));
        await tester.pumpAndSettle();

        // Navigate to Score Breakdown (Results)
        await tester.tap(find.text('Score Breakdown'));
        await tester.pumpAndSettle();
        expect(find.text('Quiz Results'), findsOneWidget);
        expect(find.text('Top match: Engineering'), findsOneWidget);
        await tester.scrollUntilVisible(
          find.textContaining('Quiz History (1 attempts)'),
          250,
        );
        expect(
          find.textContaining('Quiz History (1 attempts)'),
          findsOneWidget,
        );

        deps.dispose();
      },
    );

    testWidgets(
      'Colleges, Details (valid & invalid), Compare, Scholarships, Saved',
      (WidgetTester tester) async {
        final deps = await pumpRoute(tester, AppRoutes.colleges);
        expect(
          find.text('Indian Institute of Technology Bombay'),
          findsOneWidget,
        );
        expect(
          deps.quizProvider.progress.points,
          30,
        ); // one-time College Explorer

        // Bookmark first college
        await tester.tap(find.byTooltip('Bookmark').first);
        await tester.pumpAndSettle();
        expect(deps.catalogProvider.savedCollegeIds, isNotEmpty);

        // College Details valid ID
        await pumpRoute(
          tester,
          AppRoutes.collegeDetails('iitb'),
          existingDeps: deps,
        );
        expect(
          find.text('Indian Institute of Technology Bombay'),
          findsWidgets,
        );
        expect(find.text('Visit Website / Apply'), findsOneWidget);

        // College Details invalid ID
        await pumpRoute(
          tester,
          AppRoutes.collegeDetails('nonexistent'),
          existingDeps: deps,
        );
        expect(find.text('College not found'), findsOneWidget);

        // Compare screen defaults to 2 colleges when no ids passed
        await pumpRoute(tester, AppRoutes.compare, existingDeps: deps);
        expect(find.text('2 of 3 selected'), findsOneWidget);
        await tester.scrollUntilVisible(
          find.text('Comparison Insights'),
          250,
          scrollable: find.byType(Scrollable).first,
        );
        expect(find.text('Comparison Insights'), findsOneWidget);

        // Scholarships screen shows expired 2025 sample badge & awards one-time +40 XP
        await pumpRoute(tester, AppRoutes.scholarships, existingDeps: deps);
        expect(find.text('Sample • Expired (2025)'), findsWidgets);
        expect(deps.quizProvider.progress.points, 70); // 30 + 40

        // Saved screen shows saved college
        await pumpRoute(tester, AppRoutes.saved, existingDeps: deps);
        expect(find.text('Saved Opportunities'), findsOneWidget);
        expect(
          find.text('Indian Institute of Technology Bombay'),
          findsOneWidget,
        );

        deps.dispose();
      },
    );

    testWidgets(
      'AI Mentor, Tracker, Community, Gamification Dashboard & Parental',
      (WidgetTester tester) async {
        final deps = await pumpRoute(tester, AppRoutes.aiMentor);
        expect(find.text('AI Career Mentor'), findsOneWidget);
        expect(find.textContaining('Heuristic match'), findsOneWidget);

        // Mark first milestone complete -> +25 XP once
        await tester.scrollUntilVisible(
          find.byTooltip('Mark Done'),
          250,
          scrollable: find.byType(Scrollable).first,
        );
        final markDone = find.byTooltip('Mark Done').first;
        await tester.tap(markDone);
        await tester.pumpAndSettle();
        expect(deps.quizProvider.progress.points, 25);

        // Application Tracker: track a scholarship, change stage to Awarded (+100 XP once)
        await tester.runAsync(
          () => deps.trackerProvider.trackScholarship(
            deps.catalogProvider.allScholarships.first,
          ),
        );
        await pumpRoute(
          tester,
          AppRoutes.applicationTracker,
          existingDeps: deps,
        );
        expect(find.text('Application Tracker'), findsOneWidget);
        final awardedChip = find.widgetWithText(ChoiceChip, 'Awarded');
        await tester.ensureVisible(awardedChip);
        await tester.tap(awardedChip);
        await tester.runAsync(
          () => Future<void>.delayed(const Duration(milliseconds: 50)),
        );
        await tester.pumpAndSettle();
        expect(deps.quizProvider.progress.points, 125); // 25 + 100

        // Community Q&A renders seeded threads and local notice
        await pumpRoute(tester, AppRoutes.community, existingDeps: deps);
        expect(find.text('Community Q&A'), findsOneWidget);
        expect(find.textContaining('Sample local Q&A'), findsOneWidget);
        expect(find.text('Rohit Verma'), findsOneWidget);

        // Gamification Dashboard renders Level & XP cleanly
        await pumpRoute(tester, AppRoutes.dashboard, existingDeps: deps);
        expect(find.text('Dashboard'), findsOneWidget);
        expect(find.text('125 XP total'), findsOneWidget);

        // Parental Guidance renders expandable tips and resources
        await pumpRoute(tester, AppRoutes.parental, existingDeps: deps);
        expect(find.text('For Parents'), findsOneWidget);
        expect(find.text('Start early & listen'), findsOneWidget);
        await tester.tap(find.text('Start early & listen'));
        await tester.pumpAndSettle();
        expect(find.text('Hide'), findsOneWidget);

        deps.dispose();
      },
    );
  });
}
