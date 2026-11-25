import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../screens/ai_career_mentor_screen.dart';
import '../../screens/application_tracker_screen.dart';
import '../../screens/career_recommendation_screen.dart';
import '../../screens/college_comparison_screen.dart';
import '../../screens/college_details_screen.dart';
import '../../screens/colleges_screen.dart';
import '../../screens/community_screen.dart';
import '../../screens/explore_screen.dart';
import '../../screens/gamification_dashboard_screen.dart';
import '../../screens/home_screen.dart';
import '../../screens/parental_screen.dart';
import '../../screens/profile_screen.dart';
import '../../screens/quiz_screen.dart';
import '../../screens/results_screen.dart';
import '../../screens/saved_screen.dart';
import '../../screens/scholarship_screen.dart';
import '../../screens/settings_screen.dart';
import '../../screens/splash_screen.dart';
import '../../screens/welcome_screen.dart';
import '../../widgets/floating_bottom_nav.dart';
import '../constants/app_routes.dart';
import 'app_transitions.dart';

/// Centralized GoRouter with jitter-free Mobbin / Material 3 transitions:
/// - StatefulShellRoute keeps root tabs mounted in memory and performs a pure-GPU
///   crossfade while the single lavender pill glides smoothly across the bottom nav.
/// - Hierarchical pushed routes use Material 3 Shared-Axis horizontal slide + fade.
/// - Splash & Welcome use a clean 240ms crossfade.
GoRouter createAppRouter({String initialLocation = AppRoutes.home}) {
  final rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');

  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: initialLocation,
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        parentNavigatorKey: rootNavigatorKey,
        pageBuilder: (context, state) => buildFadePage(
          key: state.pageKey,
          child: const SplashScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.welcome,
        parentNavigatorKey: rootNavigatorKey,
        pageBuilder: (context, state) => buildFadePage(
          key: state.pageKey,
          child: const WelcomeScreen(),
        ),
      ),

      // Jitter-free Stateful Shell for Bottom-Nav Root Tabs (kept mounted + GPU crossfade)
      StatefulShellRoute(
        builder: (context, state, navigationShell) {
          return _RootTabShell(navigationShell: navigationShell);
        },
        navigatorContainerBuilder: (context, navigationShell, children) {
          return _SmoothFadeBranchContainer(
            currentIndex: navigationShell.currentIndex,
            children: children,
          );
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.home,
                pageBuilder: (context, state) => const NoTransitionPage(
                  child: HomeScreen(),
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.explore,
                pageBuilder: (context, state) => const NoTransitionPage(
                  child: ExploreScreen(),
                ),
              ),
            ],
          ),
        ],
      ),

      // Hierarchical Pushed Screens (Shared-Axis Horizontal Slide + Fade)
      GoRoute(
        path: AppRoutes.quiz,
        parentNavigatorKey: rootNavigatorKey,
        pageBuilder: (context, state) => buildSharedAxisPage(
          key: state.pageKey,
          child: const QuizScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.results,
        parentNavigatorKey: rootNavigatorKey,
        pageBuilder: (context, state) => buildSharedAxisPage(
          key: state.pageKey,
          child: const ResultsScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.recommendations,
        parentNavigatorKey: rootNavigatorKey,
        pageBuilder: (context, state) {
          final career = state.uri.queryParameters['career'];
          return buildSharedAxisPage(
            key: state.pageKey,
            child: CareerRecommendationScreen(initialCareerKey: career),
          );
        },
      ),
      GoRoute(
        path: AppRoutes.colleges,
        parentNavigatorKey: rootNavigatorKey,
        pageBuilder: (context, state) => buildSharedAxisPage(
          key: state.pageKey,
          child: const CollegesScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.collegeDetailsPattern,
        parentNavigatorKey: rootNavigatorKey,
        pageBuilder: (context, state) {
          final id = state.pathParameters['collegeId'] ?? '';
          return buildSharedAxisPage(
            key: state.pageKey,
            child: CollegeDetailsScreen(collegeId: id),
          );
        },
      ),
      GoRoute(
        path: AppRoutes.compare,
        parentNavigatorKey: rootNavigatorKey,
        pageBuilder: (context, state) {
          final rawIds = state.uri.queryParameters['ids'] ?? '';
          final ids = rawIds
              .split(',')
              .map((s) => s.trim())
              .where((s) => s.isNotEmpty)
              .toList(growable: false);
          return buildSharedAxisPage(
            key: state.pageKey,
            child: CollegeComparisonScreen(initialIds: ids),
          );
        },
      ),
      GoRoute(
        path: AppRoutes.scholarships,
        parentNavigatorKey: rootNavigatorKey,
        pageBuilder: (context, state) => buildSharedAxisPage(
          key: state.pageKey,
          child: const ScholarshipScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.saved,
        parentNavigatorKey: rootNavigatorKey,
        pageBuilder: (context, state) => buildSharedAxisPage(
          key: state.pageKey,
          child: const SavedScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.aiMentor,
        parentNavigatorKey: rootNavigatorKey,
        pageBuilder: (context, state) => buildSharedAxisPage(
          key: state.pageKey,
          child: const AiCareerMentorScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.applicationTracker,
        parentNavigatorKey: rootNavigatorKey,
        pageBuilder: (context, state) => buildSharedAxisPage(
          key: state.pageKey,
          child: const ApplicationTrackerScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.community,
        parentNavigatorKey: rootNavigatorKey,
        pageBuilder: (context, state) => buildSharedAxisPage(
          key: state.pageKey,
          child: const CommunityScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.dashboard,
        parentNavigatorKey: rootNavigatorKey,
        pageBuilder: (context, state) => buildSharedAxisPage(
          key: state.pageKey,
          child: const GamificationDashboardScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.parental,
        parentNavigatorKey: rootNavigatorKey,
        pageBuilder: (context, state) => buildSharedAxisPage(
          key: state.pageKey,
          child: const ParentalScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.profile,
        parentNavigatorKey: rootNavigatorKey,
        pageBuilder: (context, state) => buildSharedAxisPage(
          key: state.pageKey,
          child: const ProfileScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.settings,
        parentNavigatorKey: rootNavigatorKey,
        pageBuilder: (context, state) => buildSharedAxisPage(
          key: state.pageKey,
          child: const SettingsScreen(),
        ),
      ),
    ],
  );
}

class _RootTabShell extends StatelessWidget {
  const _RootTabShell({required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    final currentTab = switch (navigationShell.currentIndex) {
      1 => CareerGuideTab.explore,
      2 => CareerGuideTab.saved,
      3 => CareerGuideTab.profile,
      _ => CareerGuideTab.home,
    };

    return Scaffold(
      extendBody: true,
      body: navigationShell,
      bottomNavigationBar: FloatingBottomNav(
        currentTab: currentTab,
        onTabSelected: (tab) {
          switch (tab) {
            case CareerGuideTab.home:
              navigationShell.goBranch(0);
            case CareerGuideTab.explore:
              navigationShell.goBranch(1);
            case CareerGuideTab.saved:
              context.push(AppRoutes.saved);
            case CareerGuideTab.profile:
              context.push(AppRoutes.profile);
          }
        },
      ),
    );
  }
}

/// Keeps all root tab widgets mounted in memory (zero rebuild / image-decode jitter)
/// and runs a silky pure-GPU opacity crossfade between tabs.
class _SmoothFadeBranchContainer extends StatelessWidget {
  const _SmoothFadeBranchContainer({
    required this.currentIndex,
    required this.children,
  });

  final int currentIndex;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final disableAnimations = MediaQuery.disableAnimationsOf(context);
    final duration = disableAnimations
        ? Duration.zero
        : const Duration(milliseconds: 210);

    return Stack(
      fit: StackFit.expand,
      children: [
        for (var i = 0; i < children.length; i++)
          IgnorePointer(
            ignoring: i != currentIndex,
            child: TickerMode(
              enabled: i == currentIndex,
              child: AnimatedOpacity(
                opacity: i == currentIndex ? 1.0 : 0.0,
                duration: duration,
                curve: Curves.easeOutCubic,
                child: children[i],
              ),
            ),
          ),
      ],
    );
  }
}
