import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

import '../core/constants/app_routes.dart';
import '../providers/profile_provider.dart';
import '../providers/quiz_gamification_provider.dart';
import '../widgets/gradient_hero_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final quizProvider = context.watch<QuizGamificationProvider>();
    final profile = context.watch<ProfileProvider>().profile;
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final savedCareerTitle = quizProvider.savedCareerTitle;
    final greeting = profile.name.trim().isNotEmpty
        ? 'Welcome back, ${profile.name.trim()}'
        : 'Start your journey';

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Career Guidance Community',
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          IconButton(
            tooltip: 'Profile',
            onPressed: () => context.push(AppRoutes.profile),
            icon: const Icon(Icons.person_outline_rounded),
          ),
          IconButton(
            tooltip: 'Settings',
            onPressed: () => context.push(AppRoutes.settings),
            icon: const Icon(Icons.settings_outlined),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          children: [
            // Hero Banner
            GradientHeroCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    greeting,
                    style: textTheme.labelMedium?.copyWith(
                      color: scheme.onPrimary.withAlpha(220),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Find your best-fit career',
                    style: textTheme.headlineSmall?.copyWith(
                      color: scheme.onPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Take a quick aptitude quiz, explore colleges & scholarships, and track your career milestones offline.',
                    style: textTheme.bodyMedium?.copyWith(
                      color: scheme.onPrimary.withAlpha(240),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 10,
                    runSpacing: 8,
                    children: [
                      FilledButton(
                        style: FilledButton.styleFrom(
                          backgroundColor: scheme.surface,
                          foregroundColor: scheme.primary,
                        ),
                        onPressed: () => context.push(AppRoutes.quiz),
                        child: const Text('Start Quiz'),
                      ),
                      OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: scheme.onPrimary,
                          side: BorderSide(
                            color: scheme.onPrimary.withAlpha(180),
                          ),
                        ),
                        onPressed: () => context.push(AppRoutes.dashboard),
                        child: Text(
                          'Level ${quizProvider.levelInfo.level} • ${quizProvider.progress.points} XP',
                        ),
                      ),
                    ],
                  ),
                  if (savedCareerTitle.isNotEmpty) ...[
                    const SizedBox(height: 14),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: scheme.secondaryContainer.withAlpha(235),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.bookmark_added_rounded,
                            size: 18,
                            color: scheme.onSecondaryContainer,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Saved path: $savedCareerTitle',
                              style: textTheme.labelLarge?.copyWith(
                                color: scheme.onSecondaryContainer,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          TextButton(
                            onPressed: () =>
                                context.push(AppRoutes.recommendations),
                            child: const Text('View'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 16),

            // AI Career Mentor Flagship Banner
            Card(
              color: scheme.secondaryContainer,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.auto_awesome_rounded, color: scheme.primary),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Personalized AI Career Mentor',
                            style: textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: scheme.onSecondaryContainer,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Synthesizes your profile and quiz results on-device into a milestone roadmap, exam targets, and portfolio project ideas.',
                      style: textTheme.bodySmall?.copyWith(
                        color: scheme.onSecondaryContainer.withAlpha(225),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Align(
                      alignment: Alignment.centerRight,
                      child: FilledButton(
                        onPressed: () => context.push(AppRoutes.aiMentor),
                        child: const Text('Open Roadmap'),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            Text(
              'Explore modules',
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 12),

            // 9 quick actions covering all modules cleanly
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.65,
              children: [
                _QuickActionTile(
                  title: 'Colleges',
                  subtitle: 'Explore colleges',
                  icon: Icons.school_rounded,
                  tint: scheme.primary,
                  onTap: () => context.push(AppRoutes.colleges),
                ),
                _QuickActionTile(
                  title: 'Scholarships',
                  subtitle: 'Find funding',
                  icon: Icons.star_rounded,
                  tint: scheme.secondary,
                  onTap: () => context.push(AppRoutes.scholarships),
                ),
                _QuickActionTile(
                  title: 'AI Mentor',
                  subtitle: 'Milestone plan',
                  icon: Icons.auto_awesome_rounded,
                  tint: scheme.primary,
                  onTap: () => context.push(AppRoutes.aiMentor),
                ),
                _QuickActionTile(
                  title: 'Tracker',
                  subtitle: 'Grants pipeline',
                  icon: Icons.assignment_turned_in_rounded,
                  tint: scheme.tertiary,
                  onTap: () => context.push(AppRoutes.applicationTracker),
                ),
                _QuickActionTile(
                  title: 'Community',
                  subtitle: 'Mentorship Q&A',
                  icon: Icons.forum_rounded,
                  tint: scheme.secondary,
                  onTap: () => context.push(AppRoutes.community),
                ),
                _QuickActionTile(
                  title: 'Compare',
                  subtitle: 'Side-by-side view',
                  icon: Icons.compare_arrows_rounded,
                  tint: scheme.primary,
                  onTap: () => context.push(AppRoutes.compare),
                ),
                _QuickActionTile(
                  title: 'Saved Items',
                  subtitle: 'Colleges & Grants',
                  icon: Icons.bookmark_rounded,
                  tint: scheme.tertiary,
                  onTap: () => context.push(AppRoutes.saved),
                ),
                _QuickActionTile(
                  title: 'Dashboard',
                  subtitle: 'XP & badges',
                  icon: Icons.emoji_events_rounded,
                  tint: scheme.primary,
                  onTap: () => context.push(AppRoutes.dashboard),
                ),
              ],
            ),

            const SizedBox(height: 12),

            _QuickActionTile(
              title: 'Parental Tips',
              subtitle: 'Guidance & resources for parents',
              icon: Icons.menu_book_rounded,
              tint: scheme.error,
              onTap: () => context.push(AppRoutes.parental),
            ),

            const SizedBox(height: 24),

            Text(
              'Recommended next steps',
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            const Divider(),
            const SizedBox(height: 8),

            _NextStepCard(
              title: 'Consult AI Career Mentor',
              description: 'Review your tailored milestones, entrance exams, and portfolio project ideas.',
              actionLabel: 'Open Roadmap',
              onPrimary: () => context.push(AppRoutes.aiMentor),
            ),
            const SizedBox(height: 10),
            _NextStepCard(
              title: 'Join Peer & Mentor Community',
              description: 'Browse sample mentor discussions or post your own career questions locally.',
              actionLabel: 'Open Community',
              onPrimary: () => context.push(AppRoutes.community),
            ),
            const SizedBox(height: 10),
            _NextStepCard(
              title: 'Track Scholarship Applications',
              description: 'Organize stages, document checklists, and personal application notes.',
              actionLabel: 'Open Tracker',
              onPrimary: () => context.push(AppRoutes.applicationTracker),
            ),
            const SizedBox(height: 10),
            _NextStepCard(
              title: 'Review your quiz results',
              description:
                  'Inspect your career match breakdown and past quiz attempts.',
              actionLabel: 'See Results',
              secondaryLabel: 'Recommendations',
              onPrimary: () => context.push(AppRoutes.results),
              onSecondary: () => context.push(AppRoutes.recommendations),
            ),

            const SizedBox(height: 20),
            Text(
              'Career Guidance Community • Offline Student Prototype',
              style: textTheme.bodySmall?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickActionTile extends StatelessWidget {
  const _QuickActionTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.tint,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color tint;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: tint.withAlpha(32),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: tint),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: textTheme.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NextStepCard extends StatelessWidget {
  const _NextStepCard({
    required this.title,
    required this.description,
    required this.actionLabel,
    required this.onPrimary,
    this.secondaryLabel,
    this.onSecondary,
  });

  final String title;
  final String description;
  final String actionLabel;
  final VoidCallback onPrimary;
  final String? secondaryLabel;
  final VoidCallback? onSecondary;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              description,
              style: textTheme.bodySmall?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: [
                FilledButton.tonal(
                  onPressed: onPrimary,
                  child: Text(actionLabel),
                ),
                if (secondaryLabel != null && onSecondary != null)
                  TextButton(
                    onPressed: onSecondary,
                    child: Text(secondaryLabel!),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
