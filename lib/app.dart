import 'dart:async';

import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

import 'core/constants/app_routes.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_provider.dart';
import 'providers/catalog_provider.dart';
import 'providers/community_provider.dart';
import 'providers/profile_provider.dart';
import 'providers/quiz_gamification_provider.dart';
import 'providers/tracker_provider.dart';
import 'repositories/college_repository.dart';
import 'repositories/community_repository.dart';
import 'repositories/quiz_repository.dart';
import 'repositories/scholarship_repository.dart';
import 'services/local_storage_service.dart';

class AppDependencies {
  AppDependencies({
    required this.storage,
    required this.themeProvider,
    required this.profileProvider,
    required this.quizProvider,
    required this.catalogProvider,
    required this.trackerProvider,
    required this.communityProvider,
  });

  final LocalStorageService storage;
  final ThemeProvider themeProvider;
  final ProfileProvider profileProvider;
  final QuizGamificationProvider quizProvider;
  final CatalogProvider catalogProvider;
  final TrackerProvider trackerProvider;
  final CommunityProvider communityProvider;

  factory AppDependencies.create({LocalStorageService? storage}) {
    final resolvedStorage = storage ?? LocalStorageService();
    return AppDependencies(
      storage: resolvedStorage,
      themeProvider: ThemeProvider(storage: resolvedStorage),
      profileProvider: ProfileProvider(storage: resolvedStorage),
      quizProvider: QuizGamificationProvider(
        quizRepository: QuizRepository(),
        storage: resolvedStorage,
      ),
      catalogProvider: CatalogProvider(
        collegeRepository: CollegeRepository(),
        scholarshipRepository: ScholarshipRepository(),
        storage: resolvedStorage,
      ),
      trackerProvider: TrackerProvider(storage: resolvedStorage),
      communityProvider: CommunityProvider(
        repository: CommunityRepository(storage: resolvedStorage),
      ),
    );
  }

  Future<void> loadAll() async {
    await Future.wait([
      themeProvider.load(),
      profileProvider.load(),
      quizProvider.load(),
      catalogProvider.load(),
      trackerProvider.load(),
      communityProvider.load(),
    ]);
  }

  void dispose() {
    themeProvider.dispose();
    profileProvider.dispose();
    quizProvider.dispose();
    catalogProvider.dispose();
    trackerProvider.dispose();
    communityProvider.dispose();
  }
}

class CareerGuidanceApp extends StatefulWidget {
  const CareerGuidanceApp({
    super.key,
    this.dependencies,
    this.router,
    this.initialLocation = AppRoutes.home,
  });

  final AppDependencies? dependencies;
  final GoRouter? router;
  final String initialLocation;

  @override
  State<CareerGuidanceApp> createState() => _CareerGuidanceAppState();
}

class _CareerGuidanceAppState extends State<CareerGuidanceApp> {
  late final AppDependencies _deps;
  late GoRouter _router;
  late final bool _ownsDeps;

  @override
  void initState() {
    super.initState();
    _ownsDeps = widget.dependencies == null;
    _deps = widget.dependencies ?? AppDependencies.create();
    if (!_deps.themeProvider.isLoaded &&
        widget.initialLocation != AppRoutes.splash) {
      unawaited(_deps.loadAll());
    }
    _router =
        widget.router ?? createAppRouter(initialLocation: widget.initialLocation);
  }

  @override
  void didUpdateWidget(covariant CareerGuidanceApp oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.router != null && widget.router != oldWidget.router) {
      _router = widget.router!;
    }
  }

  @override
  void dispose() {
    if (_ownsDeps) {
      _deps.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<AppDependencies>.value(value: _deps),
        ChangeNotifierProvider<ThemeProvider>.value(value: _deps.themeProvider),
        ChangeNotifierProvider<ProfileProvider>.value(
          value: _deps.profileProvider,
        ),
        ChangeNotifierProvider<QuizGamificationProvider>.value(
          value: _deps.quizProvider,
        ),
        ChangeNotifierProvider<CatalogProvider>.value(
          value: _deps.catalogProvider,
        ),
        ChangeNotifierProvider<TrackerProvider>.value(
          value: _deps.trackerProvider,
        ),
        ChangeNotifierProvider<CommunityProvider>.value(
          value: _deps.communityProvider,
        ),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          return MaterialApp.router(
            title: 'Career Guidance Community',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.light(),
            darkTheme: AppTheme.dark(),
            themeMode: themeProvider.themeMode,
            routerConfig: _router,
          );
        },
      ),
    );
  }
}
