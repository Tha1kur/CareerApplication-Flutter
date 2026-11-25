# Career Guidance Community (Flutter)

Standalone Android-first Flutter implementation of **Career Guidance Community** (**CareerGuide**), migrated from the native Kotlin/Jetpack Compose reference app with full offline parity, approved P1 reliability fixes, and a unified Lavender & White Material 3 design system.

## Configuration
- **App Name:** Career Guidance Community
- **Application ID:** `com.careerguidance.flutter`
- **Version:** `1.0.0+1`
- **Min Android SDK:** 24 (`compileSdk` / `targetSdk` per Flutter Android toolchain)
- **Mode:** 100% offline-first (no backend, authentication, Firebase, or paid AI APIs)
- **UI System:** `material_ui`, Lavender & White theme with Dark mode support, Material 3 Shared-Axis transitions, custom adaptive launcher icon, and silent touch feedback (`enableFeedback: false` + Android `isSoundEffectsEnabled = false`)
- **State management:** `provider` (`ChangeNotifier`)
- **Navigation:** `go_router` (`StatefulShellRoute` for 4 primary bottom-nav tabs + 15 pushed/onboarding routes = 19 routes total)
- **Local storage:** `shared_preferences`
- **Media & External links:** `image_picker` (profile avatar from gallery/camera), `url_launcher`

## Screens & Features (19 Routes)
- **Onboarding:** Branded `SplashScreen` (`/splash`) + single-page `WelcomeScreen` (`/welcome`, persisted `has_seen_welcome`, replayable from Settings)
- **4 Primary Bottom-Nav Tabs (mounted shell with gliding pill & crossfade):**
  - `HomeScreen` (`/`) — Career progress card, 3×2 duotone feature grid, Continue Assessment banner, quick Notifications & Settings sheet
  - `ExploreScreen` (`/explore`) — Live local search across careers, colleges (including IDs like `IIT`), and scholarships, category cards, trending careers
  - `SavedScreen` (`/saved`) — Bookmarked colleges & scholarships with `All` / `Colleges` / `Scholarships` filter tabs
  - `ProfileScreen` (`/profile`) — Student Profile Hub with default vector silhouette + gallery/camera photo picker (`image_picker`), Vital 3 stats, XP progress, and Edit Profile modal sheet
- **Career Assessment & AI Guidance:** `QuizScreen` (`/quiz`), `CareerRecommendationScreen` (`/recommendations`), `ResultsScreen` (`/results`), `AiCareerMentorScreen` (`/ai-mentor`)
- **Colleges & Scholarships:** `CollegesScreen` (`/colleges`), `CollegeDetailsScreen` (`/college/:collegeId`), `CollegeComparisonScreen` (`/compare`), `ScholarshipScreen` (`/scholarships`), `ApplicationTrackerScreen` (`/application-tracker`)
- **Community, Gamification & Settings:** `CommunityScreen` (`/community`), `GamificationDashboardScreen` (`/dashboard`), `ParentalScreen` (`/parental`), `SettingsScreen` (`/settings`)

## Commands
```bash
flutter pub get
dart format .
flutter analyze
flutter test --reporter expanded
flutter run
flutter build apk --release
```

## Documentation
- [Feature Parity Matrix](docs/feature_parity.md)
- [Migration & UI/UX Decisions](docs/migration_decisions.md)
- [Test & Build Verification Results](docs/test_results.md)
