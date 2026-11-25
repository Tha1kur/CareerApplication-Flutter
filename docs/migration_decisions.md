# Migration & UI/UX Decisions Log

## Approved Architecture & P1 Decisions (25 Nov 2026)
1. **Flutter SDK:** Installed globally via Homebrew Cask (`Flutter 3.50.1`, `Dart 3.14.0`, `/opt/homebrew/bin/flutter`); uses `package:material_ui/material_ui.dart` per Flutter 3.50.1 toolchain.
2. **Project location:** Independent standalone Flutter project at `career_application_flutter/` alongside the Kotlin reference `CareerApplication/`.
3. **Android Application ID:** `com.careerguidance.flutter` (distinct from Kotlin's `com.adityayadav.careerguidancecommunity`), `minSdk = 24`, version `1.0.0+1`.
4. **P1 Fixes Applied Across Both Kotlin & Flutter:**
   - Atomic one-time XP deduplication (`explored_colleges`, `checked_scholarships`, `career_path_saved`, per-milestone completion, per-scholarship `AWARDED`).
   - Restore persisted search & filter state for Colleges and Scholarships.
   - Default theme aligned to `system` across Theme and Settings.
   - Confirmation dialogs before destructive Settings reset/clear actions, and full reset clearing partial quiz drafts and saved career path.
   - Quiz submission validation ensuring all 8 questions are answered and preventing stale answers on retake.
   - Honest labels for expired 2025 sample scholarships, on-device rule-based mentor, and local sample community discussions.

## Phase 6 UI/UX & Polish Decisions
5. **CareerGuide Lavender & White Design System:** Rebuilt all 19 screens to a cohesive Lavender & White theme with full Dark mode support, custom illustrations (`home_student.png`, `home_books.png`, `splash_scene.png`, `welcome_hero.png`), and custom Android adaptive launcher icons (`mipmap-*/ic_launcher*.png` + `mipmap-anydpi-v26/ic_launcher.xml`).
6. **Navigation & Motion:**
   - `StatefulShellRoute` keeps the 4 primary tabs (`Home`, `Explore`, `Saved`, `Profile`) mounted with a smooth crossfade container (`_SmoothFadeBranchContainer`, with `TickerMode` nested inside `AnimatedOpacity`) and a gliding lavender pill in `FloatingBottomNav`.
   - Secondary screens (13 routes) use Material 3 Shared-Axis horizontal slide+fade transitions (`app_transitions.dart`) and clean `← <Screen Title>` headers without repeating the brand top bar.
   - Modal bottom sheets opened inside shell tabs use `useRootNavigator: true` so they always overlay `FloatingBottomNav` cleanly.
7. **Calm Interaction Rules:**
   - Zero floating/bobbing animations and zero 3-line sparkle bursts.
   - Silent touch feedback app-wide via `enableFeedback: false` in `AppTheme`/interactive widgets plus `MainActivity.kt` disabling Android view `isSoundEffectsEnabled` recursively on `window.decorView`.
8. **Profile Avatar Picker:** Added local gallery/camera photo selection via `image_picker` (`^1.2.4`) persisted in `SharedPreferences` (`profile_avatar_path`), falling back cleanly to the default lavender+violet vector silhouette when unset or removed.
