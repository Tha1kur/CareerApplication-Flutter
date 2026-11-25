import 'dart:async';

import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

import '../core/constants/app_routes.dart';
import '../core/theme/app_colors.dart';
import '../models/ai_career_plan.dart';
import '../providers/profile_provider.dart';
import '../providers/quiz_gamification_provider.dart';
import '../widgets/gradient_hero_card.dart';

class AiCareerMentorScreen extends StatelessWidget {
  const AiCareerMentorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final profile = context.watch<ProfileProvider>().profile;
    final quizProvider = context.watch<QuizGamificationProvider>();
    final completedMilestones = quizProvider.completedMilestones;
    final plan = quizProvider.generateMentorPlan(profile);
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final totalMilestones = plan.milestones.length;
    final completedCount = plan.milestones
        .where((m) => completedMilestones.contains(m.id))
        .length;
    final progressFraction = totalMilestones > 0
        ? completedCount / totalMilestones
        : 0.0;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.auto_awesome_rounded, color: scheme.primary),
            const SizedBox(width: 8),
            const Text('AI Career Mentor'),
          ],
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Executive Hero Banner
            GradientHeroCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: scheme.onPrimary.withAlpha(45),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.star_rounded,
                              size: 16,
                              color: scheme.onPrimary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${plan.matchPercentage}% Alignment',
                              style: textTheme.labelMedium?.copyWith(
                                color: scheme.onPrimary,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: scheme.surface.withAlpha(235),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          plan.careerCategory,
                          style: textTheme.labelSmall?.copyWith(
                            color: scheme.primary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    plan.careerTitle,
                    style: textTheme.headlineSmall?.copyWith(
                      color: scheme.onPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    plan.executiveSummary,
                    style: textTheme.bodyMedium?.copyWith(
                      color: scheme.onPrimary.withAlpha(242),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Heuristic match • Generated locally on-device from your quiz & profile',
                    style: textTheme.labelSmall?.copyWith(
                      color: scheme.onPrimary.withAlpha(205),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Strengths & Growth Matrix
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Core Strengths & Growth Matrix',
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Identified Strengths',
                      style: textTheme.labelMedium?.copyWith(
                        color: scheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 6),
                    for (final strength in plan.keyStrengths)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.check_circle_rounded,
                              size: 16,
                              color: AppColors.success,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                strength,
                                style: textTheme.bodyMedium,
                              ),
                            ),
                          ],
                        ),
                      ),
                    const Divider(height: 20),
                    Text(
                      'High-Leverage Growth Areas',
                      style: textTheme.labelMedium?.copyWith(
                        color: scheme.tertiary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 6),
                    for (final growth in plan.growthAreas)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Row(
                          children: [
                            Icon(Icons.circle, size: 8, color: scheme.tertiary),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(growth, style: textTheme.bodyMedium),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Target Exams & Skills (Wrapped cleanly to prevent overflow)
            Card(
              color: scheme.surfaceContainerHighest.withAlpha(150),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Target Entrance Exams & Critical Skills',
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Benchmark Exams',
                      style: textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: plan.targetEntranceExams
                          .map(
                            (exam) => Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                color: scheme.primaryContainer,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                exam,
                                style: textTheme.labelSmall?.copyWith(
                                  color: scheme.onPrimaryContainer,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          )
                          .toList(),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      'Essential Skills to Develop',
                      style: textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: plan.recommendedSkills
                          .map(
                            (skill) => Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                color: scheme.secondaryContainer,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                skill,
                                style: textTheme.labelSmall?.copyWith(
                                  color: scheme.onSecondaryContainer,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Milestone Progress Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    'Personalized Milestone Roadmap',
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Text(
                  '$completedCount / $totalMilestones Completed',
                  style: textTheme.labelMedium?.copyWith(
                    color: scheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: progressFraction,
                minHeight: 8,
              ),
            ),
            const SizedBox(height: 12),

            // Milestone Cards
            for (final milestone in plan.milestones) ...[
              _MilestoneCard(
                milestone: milestone,
                isCompleted: completedMilestones.contains(milestone.id),
                onToggle: () async {
                  unawaited(HapticFeedback.mediumImpact());
                  final xpEarned = await quizProvider.toggleMilestone(
                    milestone.id,
                  );
                  if (xpEarned && context.mounted) {
                    ScaffoldMessenger.of(context)
                      ..hideCurrentSnackBar()
                      ..showSnackBar(
                        const SnackBar(
                          content: Text('Milestone completed! +25 XP earned'),
                        ),
                      );
                  }
                },
                onAction: milestone.actionRoute == null
                    ? null
                    : () => context.push(milestone.actionRoute!),
              ),
              const SizedBox(height: 10),
            ],

            const SizedBox(height: 6),

            // Portfolio Projects
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.work_outline_rounded, color: scheme.primary),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Recommended Portfolio Projects',
                            style: textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    for (var i = 0; i < plan.portfolioProjects.length; i++)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${i + 1}.',
                              style: textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                                color: scheme.primary,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                plan.portfolioProjects[i],
                                style: textTheme.bodyMedium,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: FilledButton.tonal(
                    onPressed: () => context.push(AppRoutes.quiz),
                    child: const Text('Recalibrate Quiz'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    onPressed: () => context.push(AppRoutes.colleges),
                    child: const Text('Explore Colleges'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MilestoneCard extends StatelessWidget {
  const _MilestoneCard({
    required this.milestone,
    required this.isCompleted,
    required this.onToggle,
    required this.onAction,
  });

  final AiCareerMilestone milestone;
  final bool isCompleted;
  final VoidCallback onToggle;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final priorityBg = switch (milestone.priority) {
      'Essential' => scheme.errorContainer,
      'High' => scheme.tertiaryContainer,
      _ => scheme.surfaceContainerHighest,
    };
    final priorityFg = switch (milestone.priority) {
      'Essential' => scheme.onErrorContainer,
      'High' => scheme.onTertiaryContainer,
      _ => scheme.onSurfaceVariant,
    };

    return Card(
      color: isCompleted ? AppColors.success.withAlpha(18) : scheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isCompleted
              ? AppColors.success.withAlpha(140)
              : scheme.outlineVariant.withAlpha(140),
          width: isCompleted ? 1.5 : 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                IconButton(
                  tooltip: isCompleted ? 'Completed' : 'Mark Done',
                  visualDensity: VisualDensity.compact,
                  onPressed: onToggle,
                  icon: Icon(
                    isCompleted
                        ? Icons.check_circle_rounded
                        : Icons.radio_button_unchecked_rounded,
                    color: isCompleted ? AppColors.success : scheme.outline,
                  ),
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        milestone.title,
                        style: textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${milestone.category} • ${milestone.estimatedTimeline}',
                        style: textTheme.labelSmall?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: priorityBg,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    milestone.priority,
                    style: textTheme.labelSmall?.copyWith(
                      color: priorityFg,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Padding(
              padding: const EdgeInsets.only(left: 44),
              child: Text(
                milestone.description,
                style: textTheme.bodySmall?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
            ),
            if (onAction != null) ...[
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: FilledButton.tonalIcon(
                  onPressed: onAction,
                  icon: const Icon(Icons.arrow_forward_rounded, size: 16),
                  label: const Text('Take Action'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
