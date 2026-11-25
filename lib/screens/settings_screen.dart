import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

import '../core/theme/theme_provider.dart';
import '../providers/profile_provider.dart';
import '../providers/quiz_gamification_provider.dart';

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
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              'Appearance',
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 12),
            SegmentedButton<ThemeMode>(
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
                  ..showSnackBar(SnackBar(content: Text('Theme: $label')));
              },
            ),
            const SizedBox(height: 8),
            Text(
              'Current: ${themeProvider.themeModeKey[0].toUpperCase()}${themeProvider.themeModeKey.substring(1)}',
              style: textTheme.bodySmall?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Data & app',
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              icon: const Icon(Icons.emoji_events_outlined),
              label: const Text('Reset gamification (XP & badges)'),
              onPressed: () => _confirmAndRun(
                context,
                title: 'Reset Gamification?',
                message: 'This resets your XP, level, earned badges, and reward milestones. Your quiz answers, scores, and profile remain intact.',
                confirmLabel: 'Reset XP',
                action: quizProvider.resetGamificationProgress,
                successMessage: 'Gamification progress reset',
              ),
            ),
            const SizedBox(height: 10),
            OutlinedButton.icon(
              icon: const Icon(Icons.restart_alt_rounded),
              label: const Text('Reset quiz, scores & XP'),
              onPressed: () => _confirmAndRun(
                context,
                title: 'Reset Quiz, Scores & XP?',
                message: 'This clears your quiz draft, submitted answers, scores, attempt history, saved career path, and XP progress.',
                confirmLabel: 'Reset All',
                action: quizProvider.resetAllQuizAndProgress,
                successMessage: 'All quiz data reset',
              ),
            ),
            const SizedBox(height: 10),
            OutlinedButton.icon(
              icon: const Icon(Icons.person_remove_outlined),
              label: const Text('Clear profile'),
              onPressed: () => _confirmAndRun(
                context,
                title: 'Clear Profile?',
                message: 'This removes your saved name, age, and career goal from this device.',
                confirmLabel: 'Clear Profile',
                action: profileProvider.clearProfile,
                successMessage: 'Profile cleared',
              ),
            ),
            const SizedBox(height: 18),
            Text(
              'All preferences, quiz attempts, saved bookmarks, tracker notes, and community discussions are stored locally on this device.',
              style: textTheme.bodySmall?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
