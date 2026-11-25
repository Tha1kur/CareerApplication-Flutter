# Feature Parity Matrix — Kotlin vs. Flutter

All 16 core Kotlin screens/features are migrated with 100% offline functional parity plus approved P1 fixes and 3 CareerGuide onboarding/discovery enhancements (`Splash`, `Welcome`, `Explore`), totaling **19 Flutter routes**.

| ID | Kotlin Screen / Route | Flutter Screen / Route | Status | Notes / Approved Improvements |
|---|---|---|---|---|
| F01 | `HomeScreen` / `home` | `HomeScreen` / `/` | Done | CareerGuide Lavender & White dashboard, 3×2 duotone grid, live progress, Notifications + Settings sheet. |
| F02 | `QuizScreen` / `quiz` | `QuizScreen` / `/quiz` | Done | Draft auto-save/restore; submit validation jumps to first unanswered question; clean retake flow. |
| F03 | `ResultsScreen` / `results` | `ResultsScreen` / `/results` | Done | Relative score bars, answer summary chips, attempt history, honest heuristic label. |
| F04 | `CareerRecommendationScreen` / `recommendations` | `CareerRecommendationScreen` / `/recommendations` | Done | Career Paths hero, search + category filter pills, expandable career cards with matched colleges/scholarships, one-time +50 XP save path. |
| F05 | `CollegesScreen` / `colleges` | `CollegesScreen` / `/colleges` | Done | Restores persisted search/filter; monogram crests; bookmark; max-3 compare bar; one-time +30 XP. |
| F06 | `CollegeDetailsScreen` / `college/{collegeId}` | `CollegeDetailsScreen` / `/college/:collegeId` | Done | Handles missing ID gracefully; safe `url_launcher` website open. |
| F07 | `CollegeComparisonScreen` / `compare` | `CollegeComparisonScreen` / `/compare` | Done | Max 3 colleges, add/remove dialog, null-safe comparison insights. |
| F08 | `ScholarshipScreen` / `scholarships` | `ScholarshipScreen` / `/scholarships` | Done | Restores persisted search/filter; one-time +40 XP (never awarded in `build`); honest 2025 sample badge. |
| F09 | `SavedScreen` / `saved` | `SavedScreen` / `/saved` | Done | Wired as bottom-nav Branch 2; `All` / `Colleges` / `Scholarships` filter tabs synced via `CatalogProvider`. |
| F10 | `AiCareerMentorScreen` / `ai_mentor` | `AiCareerMentorScreen` / `/ai-mentor` | Done | Deterministic on-device 5-track roadmap engine, `Wrap` chips, one-time +25 XP per milestone. |
| F11 | `ApplicationTrackerScreen` / `application_tracker` | `ApplicationTrackerScreen` / `/application-tracker` | Done | 4 stages, import saved scholarships, 5-doc checklist, notes, one-time +100 XP on `Awarded`. |
| F12 | `CommunityScreen` / `community` | `CommunityScreen` / `/community` | Done | 5 seeded threads, search/filter, local post/answer/upvote, honest local-prototype notice. |
| F13 | `GamificationDashboard` / `dashboard` | `GamificationDashboardScreen` / `/dashboard` | Done | Animated `LevelRing`, XP bar, badge grid, activity list, level-up celebration. |
| F14 | `ParentalScreen` / `parental` | `ParentalScreen` / `/parental` | Done | 5 expandable tips, 3 official resource links with safe open & clipboard copy. |
| F15 | `ProfileScreen` / `profile` | `ProfileScreen` / `/profile` | Done | Wired as bottom-nav Branch 3; default vector silhouette + custom gallery/camera photo picker (`image_picker`), Vital 3 stats, validated Edit Profile sheet. |
| F16 | `Settings` / `settings` | `SettingsScreen` / `/settings` | Done | Default `system` theme; confirmation dialogs before all 3 destructive resets; `Preview Splash & Welcome` demo shortcut. |
| E01 | *(New in Flutter)* | `SplashScreen` / `/splash` | Done | Real app initialization splash routing first-time users to `/welcome` and returning users to `/`. |
| E02 | *(New in Flutter)* | `WelcomeScreen` / `/welcome` | Done | Single-page CareerGuide welcome hero with `has_seen_welcome` persistence. |
| E03 | *(New in Flutter)* | `ExploreScreen` / `/explore` | Done | Wired as bottom-nav Branch 1; live local search across careers, colleges (name/city/ID), and scholarships, category cards, trending careers. |
