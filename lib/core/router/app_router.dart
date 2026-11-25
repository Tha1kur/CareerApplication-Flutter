import 'package:go_router/go_router.dart';

import '../../screens/ai_career_mentor_screen.dart';
import '../../screens/application_tracker_screen.dart';
import '../../screens/career_recommendation_screen.dart';
import '../../screens/college_comparison_screen.dart';
import '../../screens/college_details_screen.dart';
import '../../screens/colleges_screen.dart';
import '../../screens/community_screen.dart';
import '../../screens/gamification_dashboard_screen.dart';
import '../../screens/home_screen.dart';
import '../../screens/parental_screen.dart';
import '../../screens/profile_screen.dart';
import '../../screens/quiz_screen.dart';
import '../../screens/results_screen.dart';
import '../../screens/saved_screen.dart';
import '../../screens/scholarship_screen.dart';
import '../../screens/settings_screen.dart';
import '../constants/app_routes.dart';

/// Centralized GoRouter wiring all 16 application screens.
GoRouter createAppRouter({String initialLocation = AppRoutes.home}) {
  return GoRouter(
    initialLocation: initialLocation,
    routes: [
      GoRoute(
        path: AppRoutes.home,
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: AppRoutes.quiz,
        builder: (context, state) => const QuizScreen(),
      ),
      GoRoute(
        path: AppRoutes.results,
        builder: (context, state) => const ResultsScreen(),
      ),
      GoRoute(
        path: AppRoutes.recommendations,
        builder: (context, state) => const CareerRecommendationScreen(),
      ),
      GoRoute(
        path: AppRoutes.colleges,
        builder: (context, state) => const CollegesScreen(),
      ),
      GoRoute(
        path: AppRoutes.collegeDetailsPattern,
        builder: (context, state) {
          final id = state.pathParameters['collegeId'] ?? '';
          return CollegeDetailsScreen(collegeId: id);
        },
      ),
      GoRoute(
        path: AppRoutes.compare,
        builder: (context, state) {
          final rawIds = state.uri.queryParameters['ids'] ?? '';
          final ids = rawIds
              .split(',')
              .map((s) => s.trim())
              .where((s) => s.isNotEmpty)
              .toList(growable: false);
          return CollegeComparisonScreen(initialIds: ids);
        },
      ),
      GoRoute(
        path: AppRoutes.scholarships,
        builder: (context, state) => const ScholarshipScreen(),
      ),
      GoRoute(
        path: AppRoutes.saved,
        builder: (context, state) => const SavedScreen(),
      ),
      GoRoute(
        path: AppRoutes.aiMentor,
        builder: (context, state) => const AiCareerMentorScreen(),
      ),
      GoRoute(
        path: AppRoutes.applicationTracker,
        builder: (context, state) => const ApplicationTrackerScreen(),
      ),
      GoRoute(
        path: AppRoutes.community,
        builder: (context, state) => const CommunityScreen(),
      ),
      GoRoute(
        path: AppRoutes.dashboard,
        builder: (context, state) => const GamificationDashboardScreen(),
      ),
      GoRoute(
        path: AppRoutes.parental,
        builder: (context, state) => const ParentalScreen(),
      ),
      GoRoute(
        path: AppRoutes.profile,
        builder: (context, state) => const ProfileScreen(),
      ),
      GoRoute(
        path: AppRoutes.settings,
        builder: (context, state) => const SettingsScreen(),
      ),
    ],
  );
}
