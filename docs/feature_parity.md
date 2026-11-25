# Feature Parity Matrix — Kotlin vs. Flutter

| ID | Kotlin Screen / Route | Flutter Screen / Route | Status | Notes / Approved Improvements |
|---|---|---|---|---|
| F01 | `HomeScreen` / `home` | `HomeScreen` / `/` | Done | Fixed Settings gear icon; honest offline prototype footer. |
| F02 | `QuizScreen` / `quiz` | `QuizScreen` / `/quiz` | Done | Draft auto-save/restore; submit validation jumps to unanswered question. |
| F03 | `ResultsScreen` / `results` | `ResultsScreen` / `/results` | Done | Relative score bars, summary chips, attempt history, heuristic label. |
| F04 | `CareerRecommendationScreen` / `recommendations` | `CareerRecommendationScreen` / `/recommendations` | Done | Swipeable `PageView` across all 5 categories; one-time +50 XP save path. |
| F05 | `CollegesScreen` / `colleges` | `CollegesScreen` / `/colleges` | Done | Restores persisted search/filter; one-time +30 XP; max 3 compare bar. |
| F06 | `CollegeDetailsScreen` / `college/{collegeId}` | `CollegeDetailsScreen` / `/college/:collegeId` | Done | Handles missing ID gracefully; safe `url_launcher` website open. |
| F07 | `CollegeComparisonScreen` / `compare` | `CollegeComparisonScreen` / `/compare` | Done | Max 3 colleges, add/remove dialog, comparison insights with null-safe ranks. |
| F08 | `ScholarshipScreen` / `scholarships` | `ScholarshipScreen` / `/scholarships` | Done | Restores search/filter; one-time +40 XP (never in build); 2025 sample badge. |
| F09 | `SavedScreen` / `saved` | `SavedScreen` / `/saved` | Done | Colleges & Scholarships tabs synchronized via `CatalogProvider`. |
| F10 | `AiCareerMentorScreen` / `ai_mentor` | `AiCareerMentorScreen` / `/ai-mentor` | Done | Deterministic 5-track engine, `Wrap` chips, one-time +25 XP per milestone. |
| F11 | `ApplicationTrackerScreen` / `application_tracker` | `ApplicationTrackerScreen` / `/application-tracker` | Done | 4 stages, import saved, 5-doc checklist, notes, one-time +100 XP on Awarded. |
| F12 | `CommunityScreen` / `community` | `CommunityScreen` / `/community` | Done | 5 seeded threads, search/filter, local post/answer/upvote, honest local notice. |
| F13 | `GamificationDashboard` / `dashboard` | `GamificationDashboardScreen` / `/dashboard` | Done | Animated `LevelRing`, XP bar, badge grid, activity list, level-up confetti. |
| F14 | `ParentalScreen` / `parental` | `ParentalScreen` / `/parental` | Done | 5 expandable tips, 3 official resource links with safe open & clipboard copy. |
| F15 | `ProfileScreen` / `profile` | `ProfileScreen` / `/profile` | Done | Input validation, save/clear persistence, live avatar & saved preview. |
| F16 | `Settings` / `settings` | `SettingsScreen` / `/settings` | Done | Default `system` theme; confirmation dialogs before all 3 destructive resets. |
