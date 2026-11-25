import 'package:material_ui/material_ui.dart';
import 'package:go_router/go_router.dart';

import '../../screens/foundation_home_screen.dart';
import '../constants/app_routes.dart';

/// Centralized GoRouter configuration with all 16 planned application routes.
/// Phase 2 registers every typed route; Phases 4–5 replace staged screens with full modules.
GoRouter createAppRouter() {
  return GoRouter(
    initialLocation: AppRoutes.home,
    routes: [
      GoRoute(
        path: AppRoutes.home,
        builder: (context, state) => const FoundationHomeScreen(),
      ),
      GoRoute(
        path: AppRoutes.quiz,
        builder: (context, state) => const _StagedRouteScreen(
          title: 'Aptitude Quiz',
          phaseLabel: 'Phase 4',
        ),
      ),
      GoRoute(
        path: AppRoutes.results,
        builder: (context, state) => const _StagedRouteScreen(
          title: 'Quiz Results',
          phaseLabel: 'Phase 4',
        ),
      ),
      GoRoute(
        path: AppRoutes.recommendations,
        builder: (context, state) => const _StagedRouteScreen(
          title: 'Career Recommendations',
          phaseLabel: 'Phase 4',
        ),
      ),
      GoRoute(
        path: AppRoutes.colleges,
        builder: (context, state) =>
            const _StagedRouteScreen(title: 'Colleges', phaseLabel: 'Phase 4'),
      ),
      GoRoute(
        path: AppRoutes.collegeDetailsPattern,
        builder: (context, state) {
          final id = state.pathParameters['collegeId'] ?? '';
          return _StagedRouteScreen(
            title: 'College Details ($id)',
            phaseLabel: 'Phase 4',
          );
        },
      ),
      GoRoute(
        path: AppRoutes.compare,
        builder: (context, state) {
          final idsRaw = state.uri.queryParameters['ids'] ?? '';
          return _StagedRouteScreen(
            title: idsRaw.isEmpty
                ? 'Compare Colleges'
                : 'Compare Colleges ($idsRaw)',
            phaseLabel: 'Phase 4',
          );
        },
      ),
      GoRoute(
        path: AppRoutes.scholarships,
        builder: (context, state) => const _StagedRouteScreen(
          title: 'Scholarships',
          phaseLabel: 'Phase 4',
        ),
      ),
      GoRoute(
        path: AppRoutes.saved,
        builder: (context, state) => const _StagedRouteScreen(
          title: 'Saved Opportunities',
          phaseLabel: 'Phase 4',
        ),
      ),
      GoRoute(
        path: AppRoutes.aiMentor,
        builder: (context, state) => const _StagedRouteScreen(
          title: 'AI Career Mentor',
          phaseLabel: 'Phase 5',
        ),
      ),
      GoRoute(
        path: AppRoutes.applicationTracker,
        builder: (context, state) => const _StagedRouteScreen(
          title: 'Application Tracker',
          phaseLabel: 'Phase 5',
        ),
      ),
      GoRoute(
        path: AppRoutes.community,
        builder: (context, state) => const _StagedRouteScreen(
          title: 'Student & Mentor Community',
          phaseLabel: 'Phase 5',
        ),
      ),
      GoRoute(
        path: AppRoutes.dashboard,
        builder: (context, state) => const _StagedRouteScreen(
          title: 'Gamification Dashboard',
          phaseLabel: 'Phase 5',
        ),
      ),
      GoRoute(
        path: AppRoutes.parental,
        builder: (context, state) => const _StagedRouteScreen(
          title: 'For Parents',
          phaseLabel: 'Phase 5',
        ),
      ),
      GoRoute(
        path: AppRoutes.profile,
        builder: (context, state) =>
            const _StagedRouteScreen(title: 'Profile', phaseLabel: 'Phase 4'),
      ),
      GoRoute(
        path: AppRoutes.settings,
        builder: (context, state) =>
            const _StagedRouteScreen(title: 'Settings', phaseLabel: 'Phase 4'),
      ),
    ],
  );
}

class _StagedRouteScreen extends StatelessWidget {
  const _StagedRouteScreen({required this.title, required this.phaseLabel});

  final String title;
  final String phaseLabel;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.construction_rounded, size: 48, color: scheme.primary),
              const SizedBox(height: 12),
              Text(
                title,
                style: Theme.of(context).textTheme.titleLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Route verified in Phase 2 Foundation. Full module implementation is scheduled for $phaseLabel.',
                style: Theme.of(context).textTheme.bodyMedium
                    ?.copyWith(color: scheme.onSurfaceVariant),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
