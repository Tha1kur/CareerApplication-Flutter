import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

import '../app.dart';
import '../core/constants/app_routes.dart';
import '../core/router/app_navigation.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/theme_provider.dart';
import '../providers/profile_provider.dart';
import '../providers/quiz_gamification_provider.dart';

/// Cohesive CareerGuide Lavender & White Settings screen:
/// - Secondary screen (no repeated brand top bar) starting with <- Settings
/// - Floating white Appearance card (Light / Dark / System)
/// - Floating white Data & App card with confirmation dialogs for all 3 destructive resets
///   plus a Replay Welcome Screen helper for demos
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  Future<void> _confirmAndRun(
    BuildContext context, {
    required String title,
    required String message,
    required String confirmLabel,
    required Future<void> Function() action,
    required String successMessage,
  }) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: Text(confirmLabel),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !context.mounted) return;
    await action();
    if (!context.mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(successMessage)));
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final quizProvider = context.read<QuizGamificationProvider>();
    final profileProvider = context.read<ProfileProvider>();
    final deps = context.read<AppDependencies>();
    final scheme = Theme.of(context).colorScheme;
    final brightness = Theme.of(context).brightness;
    final isDark = brightness == Brightness.dark;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: CustomPaint(
              painter: _SettingsBackdropPainter(isDark: isDark),
            ),
          ),
          SafeArea(
            child: ListView(
              padding: const EdgeInsets.only(bottom: 24),
              children: [
                const SizedBox(height: 8),

                // 1. Clean Secondary Top Row
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  child: Row(
                    children: [
                      Material(
                        color: Colors.transparent,
                        shape: const CircleBorder(),
                        clipBehavior: Clip.antiAlias,
                        child: InkWell(
                          enableFeedback: false,
                          onTap: () => context.safePop(),
                          child: Padding(
                            padding: const EdgeInsets.all(6),
                            child: Icon(
                              Icons.arrow_back_rounded,
                              size: 22,
                              color: isDark
                                  ? scheme.primary
                                  : const Color(0xFF5D26C6),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          'Settings',
                          style: textTheme.headlineSmall?.copyWith(
                            fontSize: 22.5,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.5,
                            color: isDark
                                ? scheme.onSurface
                                : const Color(0xFF17122B),
                          ),
                        ),
                      ),
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: isDark
                              ? scheme.primaryContainer
                              : const Color(0xFFF0E8FF),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Icon(
                          Icons.settings_outlined,
                          size: 22,
                          color: isDark
                              ? scheme.primary
                              : const Color(0xFF6B2FD0),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 14),

                // 2. Appearance Card
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: scheme.surface,
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(
                        color: scheme.outlineVariant.withAlpha(175),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.cardShadow(brightness),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Appearance',
                          style: textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: SegmentedButton<ThemeMode>(
                            segments: const [
                              ButtonSegment<ThemeMode>(
                                value: ThemeMode.light,
                                label: Text('Light'),
                                icon: Icon(Icons.light_mode_outlined),
                              ),
                              ButtonSegment<ThemeMode>(
                                value: ThemeMode.dark,
                                label: Text('Dark'),
                                icon: Icon(Icons.dark_mode_outlined),
                              ),
                              ButtonSegment<ThemeMode>(
                                value: ThemeMode.system,
                                label: Text('System'),
                                icon: Icon(Icons.settings_suggest_outlined),
                              ),
                            ],
                            selected: {themeProvider.themeMode},
                            onSelectionChanged: (selection) async {
                              final chosen = selection.first;
                              await themeProvider.setThemeMode(chosen);
                              if (!context.mounted) return;
                              final label = switch (chosen) {
                                ThemeMode.light => 'Light',
                                ThemeMode.dark => 'Dark',
                                ThemeMode.system => 'System',
                              };
                              ScaffoldMessenger.of(context)
                                ..hideCurrentSnackBar()
                                ..showSnackBar(
                                  SnackBar(content: Text('Theme: $label')),
                                );
                            },
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Current: ${themeProvider.themeModeKey[0].toUpperCase()}${themeProvider.themeModeKey.substring(1)}',
                          style: textTheme.bodySmall?.copyWith(
                            color: scheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 14),

                // 3. Data & App Card
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: scheme.surface,
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(
                        color: scheme.outlineVariant.withAlpha(175),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.cardShadow(brightness),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Data & app',
                          style: textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            icon: const Icon(Icons.emoji_events_outlined),
                            label: const Text(
                              'Reset gamification (XP & badges)',
                            ),
                            onPressed: () => _confirmAndRun(
                              context,
                              title: 'Reset Gamification?',
                              message:
                                  'This resets your XP, level, earned badges, and reward milestones. Your quiz answers, scores, and profile remain intact.',
                              confirmLabel: 'Reset XP',
                              action: quizProvider.resetGamificationProgress,
                              successMessage: 'Gamification progress reset',
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            icon: const Icon(Icons.restart_alt_rounded),
                            label: const Text('Reset quiz, scores & XP'),
                            onPressed: () => _confirmAndRun(
                              context,
                              title: 'Reset Quiz, Scores & XP?',
                              message:
                                  'This clears your quiz draft, submitted answers, scores, attempt history, saved career path, and XP progress.',
                              confirmLabel: 'Reset All',
                              action: quizProvider.resetAllQuizAndProgress,
                              successMessage: 'All quiz data reset',
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            icon: const Icon(Icons.person_remove_outlined),
                            label: const Text('Clear profile'),
                            onPressed: () => _confirmAndRun(
                              context,
                              title: 'Clear Profile?',
                              message:
                                  'This removes your saved name, age, career goal, and custom profile photo from this device.',
                              confirmLabel: 'Clear Profile',
                              action: profileProvider.clearProfile,
                              successMessage: 'Profile cleared',
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            icon: const Icon(Icons.slideshow_rounded),
                            label: const Text('Preview Splash & Welcome'),
                            onPressed: () async {
                              await deps.storage.setHasSeenWelcome(false);
                              if (!context.mounted) return;
                              context.go(AppRoutes.splash);
                            },
                          ),
                        ),
                        const SizedBox(height: 14),
                        Text(
                          'All preferences, quiz attempts, saved bookmarks, tracker notes, and community discussions are stored locally on this device.',
                          style: textTheme.bodySmall?.copyWith(
                            color: scheme.onSurfaceVariant,
                            height: 1.38,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingsBackdropPainter extends CustomPainter {
  const _SettingsBackdropPainter({required this.isDark});

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
  }

  @override
  bool shouldRepaint(covariant _SettingsBackdropPainter oldDelegate) =>
      oldDelegate.isDark != isDark;
}
