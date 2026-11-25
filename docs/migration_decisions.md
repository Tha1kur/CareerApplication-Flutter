# Migration Decisions Log

## Approved Decisions (25 Nov 2026)
1. **Flutter SDK:** Installed globally via Homebrew Cask (`Flutter 3.50.1`, `Dart 3.14.0`, `/opt/homebrew/bin/flutter`).
2. **Project location:** Independent project at `career_application_flutter/` alongside the Kotlin reference `CareerApplication/`.
3. **Android Application ID:** `com.careerguidance.flutter` (distinct from Kotlin's `com.adityayadav.careerguidancecommunity`), `minSdk = 24`.
4. **P1 Fixes Approved for Both Kotlin & Flutter:**
   - Atomic one-time XP deduplication (`explored_colleges`, `checked_scholarships`, `career_path_saved`, per-milestone completion, per-scholarship `AWARDED`).
   - Restore persisted search & filter state for Colleges and Scholarships.
   - Default theme aligned to `system` across Theme and Settings.
   - Confirmation dialogs before destructive Settings reset/clear actions, and full reset clearing partial quiz drafts and saved career path.
   - Quiz submission validation ensuring all questions are answered and preventing stale answers on retake.
   - Honest labels for expired 2025 sample scholarships, on-device rule-based mentor, and local sample community discussions.
