import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

import '../core/constants/app_routes.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/theme_provider.dart';
import '../providers/catalog_provider.dart';
import '../providers/profile_provider.dart';
import '../providers/quiz_gamification_provider.dart';
import '../providers/tracker_provider.dart';
import '../widgets/career_guide_top_bar.dart';

/// Mobbin-researched EdTech Student Profile Hub (4th primary bottom-nav tab):
/// - Brand CareerGuideTopBar + PopScope back-to-Home
/// - Centered Student Identity Card with circular avatar + edit badge, name, goal/age,
///   Level & XP progress bar, and Edit Profile CTA (opens dedicated Edit Profile bottom sheet)
/// - "Vital 3" Metrics Grid (Quizzes, Saved, Tracked)
/// - Saved Career Path / Quiz CTA Violet Banner
/// - Categorized white menu cards (My Career Hub + Community & Preferences)
/// - Zero floating animations, zero 3-line sparkles, zero tap click sounds
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  void _openEditProfileSheet(BuildContext context) {
    final profileProvider = context.read<ProfileProvider>();
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (sheetContext) =>
          _EditProfileSheet(profileProvider: profileProvider),
    );
  }

  Future<void> _pickAvatar(BuildContext context, ImageSource source) async {
    final profileProvider = context.read<ProfileProvider>();
    try {
      final picked = await ImagePicker().pickImage(
        source: source,
        maxWidth: 640,
        maxHeight: 640,
        imageQuality: 85,
      );
      if (picked == null) return;
      await profileProvider.setAvatarPath(picked.path);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(const SnackBar(content: Text('Profile photo updated')));
    } catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(content: Text('Could not pick image on this device')),
        );
    }
  }

  void _openAvatarOptionsSheet(BuildContext context, bool hasCustomAvatar) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final profileProvider = context.read<ProfileProvider>();

    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      backgroundColor: scheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: Text(
                    'Profile Photo',
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                ListTile(
                  enableFeedback: false,
                  leading: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: scheme.primaryContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.photo_library_outlined,
                      color: scheme.primary,
                    ),
                  ),
                  title: const Text('Choose from Gallery'),
                  subtitle: const Text('Pick a photo from your device'),
                  onTap: () {
                    Navigator.of(sheetContext).pop();
                    unawaited(_pickAvatar(context, ImageSource.gallery));
                  },
                ),
                ListTile(
                  enableFeedback: false,
                  leading: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: scheme.primaryContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.photo_camera_outlined,
                      color: scheme.primary,
                    ),
                  ),
                  title: const Text('Take a Photo'),
                  subtitle: const Text('Use device camera'),
                  onTap: () {
                    Navigator.of(sheetContext).pop();
                    unawaited(_pickAvatar(context, ImageSource.camera));
                  },
                ),
                if (hasCustomAvatar)
                  ListTile(
                    enableFeedback: false,
                    leading: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: scheme.errorContainer,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.delete_outline_rounded,
                        color: scheme.onErrorContainer,
                      ),
                    ),
                    title: const Text('Remove Photo'),
                    subtitle: const Text('Revert to default avatar'),
                    onTap: () {
                      Navigator.of(sheetContext).pop();
                      unawaited(profileProvider.clearAvatar());
                    },
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _themeLabel(ThemeMode mode) => switch (mode) {
    ThemeMode.light => 'Light',
    ThemeMode.dark => 'Dark',
    ThemeMode.system => 'System',
  };

  @override
  Widget build(BuildContext context) {
    final profile = context.watch<ProfileProvider>().profile;
    final quizProvider = context.watch<QuizGamificationProvider>();
    final catalog = context.watch<CatalogProvider>();
    final tracker = context.watch<TrackerProvider>();
    final themeProvider = context.watch<ThemeProvider>();

    final levelInfo = quizProvider.levelInfo;
    final progress = quizProvider.progress;
    final totalSaved =
        catalog.savedCollegeIds.length + catalog.savedScholarshipIds.length;
    final trackedCount = tracker.items.length;
    final quizAttempts = quizProvider.quizHistory.length;
    final savedCareerTitle = quizProvider.savedCareerTitle;

    final scheme = Theme.of(context).colorScheme;
    final brightness = Theme.of(context).brightness;
    final isDark = brightness == Brightness.dark;
    final textTheme = Theme.of(context).textTheme;

    final displayName =
        profile.name.trim().isNotEmpty ? profile.name.trim() : 'Student Explorer';
    final goalText = profile.goal.trim().isNotEmpty
        ? profile.goal.trim()
        : 'Set your dream career goal';
    final ageLabel = profile.age > 0 ? ' • Age ${profile.age}' : '';
    final hasCustomAvatar =
        profile.avatarPath.isNotEmpty && File(profile.avatarPath).existsSync();

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) context.go(AppRoutes.home);
      },
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Stack(
          children: [
            Positioned.fill(
              child: CustomPaint(
                painter: _ProfileBackdropPainter(isDark: isDark),
              ),
            ),
            SafeArea(
              bottom: false,
              child: ListView(
                padding: const EdgeInsets.only(bottom: 104),
                children: [
                  // 1. Brand Top Bar (primary bottom-nav screen)
                  const CareerGuideTopBar(),

                  const SizedBox(height: 8),

                  // 2. Mobbin Centered Student Identity Hero Card
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    child: Container(
                      decoration: BoxDecoration(
                        color: scheme.surface,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: scheme.outlineVariant.withAlpha(175),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.cardShadow(brightness),
                            blurRadius: 18,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: Column(
                        children: [
                          // Subtle lavender top header band + overlapping student avatar
                          Stack(
                            clipBehavior: Clip.none,
                            alignment: Alignment.topCenter,
                            children: [
                              Container(
                                height: 64,
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: isDark
                                        ? const [
                                            Color(0xFF332366),
                                            Color(0xFF4C2E96),
                                          ]
                                        : const [
                                            Color(0xFFEDE4FF),
                                            Color(0xFFE3D4FF),
                                          ],
                                  ),
                                ),
                              ),
                              // Quick Settings gear pill top-right
                              Positioned(
                                right: 12,
                                top: 12,
                                child: Material(
                                  color: scheme.surface.withAlpha(225),
                                  shape: const CircleBorder(),
                                  clipBehavior: Clip.antiAlias,
                                  child: InkWell(
                                    enableFeedback: false,
                                    onTap: () =>
                                        context.push(AppRoutes.settings),
                                    child: Tooltip(
                                      message: 'Settings',
                                      child: Padding(
                                        padding: const EdgeInsets.all(8),
                                        child: Icon(
                                          Icons.settings_outlined,
                                          size: 19,
                                          color: isDark
                                              ? scheme.primary
                                              : const Color(0xFF5D26C6),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              // Centered 84dp Default Silhouette Avatar (or Custom Picked Photo) with Camera Badge
                              Padding(
                                padding: const EdgeInsets.only(top: 20),
                                child: GestureDetector(
                                  onTap: () => _openAvatarOptionsSheet(
                                    context,
                                    hasCustomAvatar,
                                  ),
                                  child: Stack(
                                    clipBehavior: Clip.none,
                                    children: [
                                      Container(
                                        width: 84,
                                        height: 84,
                                        padding: const EdgeInsets.all(3),
                                        decoration: BoxDecoration(
                                          color: scheme.surface,
                                          shape: BoxShape.circle,
                                          boxShadow: [
                                            BoxShadow(
                                              color: const Color(0xFF6B2FD0)
                                                  .withAlpha(38),
                                              blurRadius: 14,
                                              offset: const Offset(0, 5),
                                            ),
                                          ],
                                        ),
                                        child: ClipOval(
                                          child: Container(
                                            color: isDark
                                                ? const Color(0xFF2D2254)
                                                : const Color(0xFFEFE7FF),
                                            child: hasCustomAvatar
                                                ? Image.file(
                                                    File(profile.avatarPath),
                                                    fit: BoxFit.cover,
                                                    errorBuilder: (_, _, _) =>
                                                        CustomPaint(
                                                          painter:
                                                              _DefaultAvatarPainter(
                                                                color: isDark
                                                                    ? scheme
                                                                          .primary
                                                                    : const Color(
                                                                        0xFF7B3CE0,
                                                                      ),
                                                              ),
                                                        ),
                                                  )
                                                : CustomPaint(
                                                    painter:
                                                        _DefaultAvatarPainter(
                                                          color: isDark
                                                              ? scheme.primary
                                                              : const Color(
                                                                  0xFF7B3CE0,
                                                                ),
                                                        ),
                                                  ),
                                          ),
                                        ),
                                      ),
                                      Positioned(
                                        right: -2,
                                        bottom: 0,
                                        child: Container(
                                          width: 28,
                                          height: 28,
                                          decoration: BoxDecoration(
                                            color: const Color(0xFF7433D6),
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                              color: scheme.surface,
                                              width: 2.2,
                                            ),
                                          ),
                                          child: const Icon(
                                            Icons.camera_alt_rounded,
                                            size: 14,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),

                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
                            child: Column(
                              children: [
                                Text(
                                  displayName,
                                  style: textTheme.titleLarge?.copyWith(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: -0.4,
                                    color: isDark
                                        ? scheme.onSurface
                                        : const Color(0xFF17122B),
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  '$goalText$ageLabel',
                                  style: textTheme.bodySmall?.copyWith(
                                    fontSize: 12.8,
                                    color: isDark
                                        ? scheme.onSurfaceVariant
                                        : const Color(0xFF56506E),
                                  ),
                                  textAlign: TextAlign.center,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 12),

                                // Level + XP Progress Pill Bar
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 10,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isDark
                                        ? const Color(0xFF231C42)
                                        : const Color(0xFFF6F2FF),
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  child: Column(
                                    children: [
                                      Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 9,
                                              vertical: 3,
                                            ),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFF7433D6),
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                            child: Text(
                                              'Level ${levelInfo.level}',
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 11.2,
                                                fontWeight: FontWeight.w800,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Text(
                                              '${progress.points} XP total • ${progress.badges.length} badges',
                                              style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w600,
                                                color: isDark
                                                    ? scheme.onSurface
                                                    : const Color(0xFF3E3856),
                                              ),
                                            ),
                                          ),
                                          GestureDetector(
                                            onTap: () =>
                                                _openEditProfileSheet(context),
                                            child: Text(
                                              'Edit Profile',
                                              style: TextStyle(
                                                fontSize: 12.2,
                                                fontWeight: FontWeight.w700,
                                                color: isDark
                                                    ? scheme.primary
                                                    : const Color(0xFF7433D6),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(6),
                                        child: LinearProgressIndicator(
                                          value: levelInfo.progressFraction
                                              .clamp(0.0, 1.0),
                                          minHeight: 6,
                                          backgroundColor: isDark
                                              ? Colors.white.withAlpha(24)
                                              : const Color(0xFFE3D8FC),
                                          valueColor:
                                              const AlwaysStoppedAnimation<
                                                Color
                                              >(Color(0xFF7433D6)),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // 3. Mobbin "Vital 3" Stats Row (Quizzes / Saved / Tracked)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    child: Row(
                      children: [
                        Expanded(
                          child: _VitalStatCard(
                            icon: Icons.quiz_rounded,
                            value: '$quizAttempts',
                            label: 'Quizzes',
                            onTap: () => context.push(AppRoutes.results),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _VitalStatCard(
                            icon: Icons.bookmark_rounded,
                            value: '$totalSaved',
                            label: 'Saved',
                            onTap: () => context.go(AppRoutes.saved),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _VitalStatCard(
                            icon: Icons.assignment_turned_in_rounded,
                            value: '$trackedCount',
                            label: 'Tracked',
                            onTap: () =>
                                context.push(AppRoutes.applicationTracker),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),

                  // 4. Rich Violet Saved Career Path / Assessment Highlight Card
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(22),
                        gradient: const LinearGradient(
                          colors: [
                            Color(0xFF5D26C6),
                            Color(0xFF7E3EE2),
                            Color(0xFF9757EE),
                          ],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF6B2FD0).withAlpha(
                              isDark ? 68 : 54,
                            ),
                            blurRadius: 18,
                            offset: const Offset(0, 7),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: Colors.white.withAlpha(42),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: const Icon(
                              Icons.explore_rounded,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  savedCareerTitle.isNotEmpty
                                      ? 'Saved Career Path'
                                      : 'Find Your Best-Fit Career',
                                  style: TextStyle(
                                    color: Colors.white.withAlpha(215),
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  savedCareerTitle.isNotEmpty
                                      ? savedCareerTitle
                                      : 'Take the 8-question aptitude quiz',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 14.8,
                                    fontWeight: FontWeight.w800,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Material(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(18),
                            clipBehavior: Clip.antiAlias,
                            child: InkWell(
                              enableFeedback: false,
                              onTap: () => context.push(
                                savedCareerTitle.isNotEmpty
                                    ? AppRoutes.recommendationsWithCareer(
                                        quizProvider.savedCareerKey,
                                      )
                                    : AppRoutes.quiz,
                              ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                                child: Text(
                                  savedCareerTitle.isNotEmpty ? 'View' : 'Start',
                                  style: const TextStyle(
                                    color: Color(0xFF6729CC),
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // 5. Categorized Menu Group 1: "My Career Hub"
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 18),
                    child: Text(
                      'My Career Hub',
                      style: textTheme.labelLarge?.copyWith(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w800,
                        color: isDark
                            ? scheme.onSurfaceVariant
                            : const Color(0xFF56506E),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    child: _GroupedMenuCard(
                      items: [
                        _MenuEntry(
                          icon: Icons.person_outline_rounded,
                          title: 'Personal Information',
                          subtitle: profile.isEmpty
                              ? 'Add your name, age & career goal'
                              : 'Name: ${profile.name}',
                          onTap: () => _openEditProfileSheet(context),
                        ),
                        _MenuEntry(
                          icon: Icons.assignment_turned_in_outlined,
                          title: 'Application Tracker',
                          subtitle:
                              '$trackedCount tracked scholarship applications',
                          onTap: () =>
                              context.push(AppRoutes.applicationTracker),
                        ),
                        _MenuEntry(
                          icon: Icons.analytics_outlined,
                          title: 'Quiz Results & History',
                          subtitle: quizAttempts == 0
                              ? 'No attempts yet — take the quiz'
                              : '$quizAttempts recorded attempt${quizAttempts == 1 ? '' : 's'}',
                          onTap: () => context.push(AppRoutes.results),
                        ),
                        _MenuEntry(
                          icon: Icons.emoji_events_outlined,
                          title: 'XP & Badges Dashboard',
                          subtitle:
                              'Level ${levelInfo.level} • ${progress.badges.length} badges unlocked',
                          onTap: () => context.push(AppRoutes.dashboard),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // 6. Categorized Menu Group 2: "Community & Preferences"
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 18),
                    child: Text(
                      'Community & Preferences',
                      style: textTheme.labelLarge?.copyWith(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w800,
                        color: isDark
                            ? scheme.onSurfaceVariant
                            : const Color(0xFF56506E),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    child: _GroupedMenuCard(
                      items: [
                        _MenuEntry(
                          icon: Icons.forum_outlined,
                          title: 'Student & Mentor Q&A',
                          subtitle: 'Browse local Q&A threads or ask a question',
                          onTap: () => context.push(AppRoutes.community),
                        ),
                        _MenuEntry(
                          icon: Icons.menu_book_outlined,
                          title: 'Parental Guidance',
                          subtitle: 'Career tips & official links for parents',
                          onTap: () => context.push(AppRoutes.parental),
                        ),
                        _MenuEntry(
                          icon: Icons.palette_outlined,
                          title: 'Appearance & Settings',
                          subtitle:
                              'Theme: ${_themeLabel(themeProvider.themeMode)} • Data controls',
                          onTap: () => context.push(AppRoutes.settings),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EditProfileSheet extends StatefulWidget {
  const _EditProfileSheet({required this.profileProvider});

  final ProfileProvider profileProvider;

  @override
  State<_EditProfileSheet> createState() => _EditProfileSheetState();
}

class _EditProfileSheetState extends State<_EditProfileSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _ageController;
  late final TextEditingController _goalController;

  @override
  void initState() {
    super.initState();
    final p = widget.profileProvider.profile;
    _nameController = TextEditingController(text: p.name);
    _ageController = TextEditingController(
      text: p.age > 0 ? p.age.toString() : '',
    );
    _goalController = TextEditingController(text: p.goal);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _goalController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final age = int.tryParse(_ageController.text.trim()) ?? 0;
    await widget.profileProvider.saveProfile(
      name: _nameController.text.trim(),
      age: age,
      goal: _goalController.text.trim(),
    );
    if (!mounted) return;
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(const SnackBar(content: Text('Profile saved')));
  }

  Future<void> _clear() async {
    await widget.profileProvider.clearProfile();
    _nameController.clear();
    _ageController.clear();
    _goalController.clear();
    if (!mounted) return;
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(const SnackBar(content: Text('Profile cleared')));
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(20, 0, 20, 20 + bottomInset),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Edit Profile',
                style: textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Saved locally on your device to personalize CareerGuide.',
                style: textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nameController,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: 'Name',
                  hintText: 'Enter your full name',
                  prefixIcon: Icon(Icons.person_outline_rounded),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter your name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _ageController,
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.next,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: const InputDecoration(
                  labelText: 'Age',
                  hintText: 'e.g. 19',
                  prefixIcon: Icon(Icons.cake_outlined),
                ),
                validator: (value) {
                  final raw = value?.trim() ?? '';
                  if (raw.isEmpty) return null;
                  final parsed = int.tryParse(raw);
                  if (parsed == null || parsed < 10 || parsed > 100) {
                    return 'Enter a valid age (10–100)';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _goalController,
                minLines: 2,
                maxLines: 3,
                textInputAction: TextInputAction.done,
                decoration: const InputDecoration(
                  labelText: 'Goal / dream career',
                  hintText: 'e.g. Software Engineer, UX Designer',
                  prefixIcon: Icon(Icons.flag_outlined),
                ),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Container(
                      height: 48,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        gradient: const LinearGradient(
                          colors: [Color(0xFF5D26C6), Color(0xFF8344E4)],
                        ),
                      ),
                      child: Material(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(16),
                        clipBehavior: Clip.antiAlias,
                        child: InkWell(
                          enableFeedback: false,
                          onTap: _save,
                          child: const Center(
                            child: Text(
                              'Save',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: SizedBox(
                      height: 48,
                      child: OutlinedButton(
                        onPressed: _clear,
                        style: OutlinedButton.styleFrom(
                          enableFeedback: false,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: const Text(
                          'Clear',
                          style: TextStyle(fontWeight: FontWeight.w700),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _VitalStatCard extends StatelessWidget {
  const _VitalStatCard({
    required this.icon,
    required this.value,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String value;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final brightness = Theme.of(context).brightness;
    final isDark = brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: scheme.outlineVariant.withAlpha(175)),
        boxShadow: [
          BoxShadow(
            color: AppColors.cardShadow(brightness),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          enableFeedback: false,
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 8),
            child: Column(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: isDark
                        ? scheme.primaryContainer
                        : const Color(0xFFF3ECFF),
                    borderRadius: BorderRadius.circular(11),
                  ),
                  child: Icon(
                    icon,
                    size: 19,
                    color: isDark ? scheme.primary : const Color(0xFF7433D6),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: isDark ? scheme.onSurface : const Color(0xFF17122B),
                  ),
                ),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 11.4,
                    fontWeight: FontWeight.w500,
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MenuEntry {
  const _MenuEntry({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
}

class _GroupedMenuCard extends StatelessWidget {
  const _GroupedMenuCard({required this.items});

  final List<_MenuEntry> items;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final brightness = Theme.of(context).brightness;
    final isDark = brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: scheme.outlineVariant.withAlpha(175)),
        boxShadow: [
          BoxShadow(
            color: AppColors.cardShadow(brightness),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          for (var i = 0; i < items.length; i++) ...[
            Material(
              color: Colors.transparent,
              child: InkWell(
                enableFeedback: false,
                onTap: items[i].onTap,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: isDark
                              ? scheme.primaryContainer
                              : const Color(0xFFF3ECFF),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          items[i].icon,
                          size: 20,
                          color: isDark
                              ? scheme.primary
                              : const Color(0xFF6B2FD0),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              items[i].title,
                              style: TextStyle(
                                fontSize: 14.2,
                                fontWeight: FontWeight.w700,
                                color: isDark
                                    ? scheme.onSurface
                                    : const Color(0xFF17122B),
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              items[i].subtitle,
                              style: TextStyle(
                                fontSize: 11.8,
                                color: scheme.onSurfaceVariant,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        Icons.chevron_right_rounded,
                        size: 20,
                        color: scheme.onSurfaceVariant,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            if (i < items.length - 1)
              Divider(
                height: 1,
                indent: 66,
                endIndent: 14,
                color: scheme.outlineVariant.withAlpha(130),
              ),
          ],
        ],
      ),
    );
  }
}

class _ProfileBackdropPainter extends CustomPainter {
  const _ProfileBackdropPainter({required this.isDark});

  final bool isDark;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    canvas.drawRect(
      rect,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          stops: const [0.0, 0.35, 1.0],
          colors: isDark
              ? const [
                  AppColors.darkBackgroundTop,
                  AppColors.darkBackground,
                  AppColors.darkBackground,
                ]
              : const [
                  Color(0xFFF6F1FF),
                  Color(0xFFF9F7FF),
                  Color(0xFFF3EEFF),
                ],
        ).createShader(rect),
    );

    final topLeft = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width * 0.44, 0)
      ..quadraticBezierTo(
        size.width * 0.24,
        size.height * 0.08,
        0,
        size.height * 0.14,
      )
      ..close();
    canvas.drawPath(
      topLeft,
      Paint()
        ..color = isDark
            ? const Color(0xFF281F4A).withAlpha(140)
            : const Color(0xFFEBE1FF).withAlpha(185),
    );
  }

  @override
  bool shouldRepaint(covariant _ProfileBackdropPainter oldDelegate) =>
      oldDelegate.isDark != isDark;
}

class _DefaultAvatarPainter extends CustomPainter {
  const _DefaultAvatarPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    final w = size.width;
    final h = size.height;
    canvas.drawCircle(Offset(w * 0.50, h * 0.36), w * 0.175, paint);
    final shoulders = Path()
      ..moveTo(w * 0.16, h * 0.96)
      ..quadraticBezierTo(w * 0.18, h * 0.62, w * 0.50, h * 0.62)
      ..quadraticBezierTo(w * 0.82, h * 0.62, w * 0.84, h * 0.96)
      ..close();
    canvas.drawPath(shoulders, paint);
  }

  @override
  bool shouldRepaint(covariant _DefaultAvatarPainter oldDelegate) =>
      oldDelegate.color != color;
}
