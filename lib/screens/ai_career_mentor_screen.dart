import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

import '../core/constants/app_routes.dart';
import '../core/router/app_navigation.dart';
import '../core/theme/app_colors.dart';
import '../models/ai_career_plan.dart';
import '../providers/profile_provider.dart';
import '../providers/quiz_gamification_provider.dart';
import '../widgets/duotone_icons.dart';

/// Cohesive CareerGuide Lavender & White AI Career Mentor screen:
/// - Secondary screen (no repeated brand top bar) starting with <- AI Career Mentor
/// - Fixed duotone AI Mentor hero icon on pastel lavender blob (zero floating, zero 3-line sparkles)
/// - Rich violet executive alignment card with honest local heuristic label
/// - Floating white Strengths/Growth, Exams/Skills, Milestone Roadmap (+25 XP once), & Projects cards
class AiCareerMentorScreen extends StatelessWidget {
  const AiCareerMentorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final profile = context.watch<ProfileProvider>().profile;
    final quizProvider = context.watch<QuizGamificationProvider>();
    final completedMilestones = quizProvider.completedMilestones;
    final plan = quizProvider.generateMentorPlan(profile);

    final scheme = Theme.of(context).colorScheme;
    final brightness = Theme.of(context).brightness;
    final isDark = brightness == Brightness.dark;
    final textTheme = Theme.of(context).textTheme;

    final totalMilestones = plan.milestones.length;
    final completedCount = plan.milestones
        .where((m) => completedMilestones.contains(m.id))
        .length;
    final progressFraction = totalMilestones > 0
        ? completedCount / totalMilestones
        : 0.0;

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: CustomPaint(painter: _MentorBackdropPainter(isDark: isDark)),
          ),
          SafeArea(
            child: ListView(
              padding: const EdgeInsets.only(bottom: 24),
              children: [
                const SizedBox(height: 6),

                // 1. Hero Header Row: Back arrow + "AI Career Mentor" + Fixed Duotone Icon
                SizedBox(
                  height: 110,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Positioned(
                        right: 6,
                        bottom: 0,
                        width: 152,
                        height: 106,
                        child: CustomPaint(
                          painter: _MentorBlobPainter(isDark: isDark),
                        ),
                      ),
                      Positioned(
                        left: 14,
                        top: 10,
                        right: 128,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
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
                                    'AI Career Mentor',
                                    style: textTheme.headlineSmall?.copyWith(
                                      fontSize: 22.5,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: -0.5,
                                      color: isDark
                                          ? scheme.onSurface
                                          : const Color(0xFF17122B),
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Padding(
                              padding: const EdgeInsets.only(left: 36),
                              child: Text(
                                'Your personal on-device\nroadmap & action plan.',
                                style: textTheme.bodySmall?.copyWith(
                                  color: isDark
                                      ? scheme.onSurfaceVariant
                                      : const Color(0xFF4A4560),
                                  fontSize: 13,
                                  height: 1.35,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Positioned(
                        right: 18,
                        bottom: 8,
                        child: DuotoneFeatureIcon(
                          kind: DuotoneIconKind.aiMentor,
                          size: 90,
                        ),
                      ),
                    ],
                  ),
                ),

                // 2. Rich Violet Executive Match Banner
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24),
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xFF5D26C6),
                          Color(0xFF7E3EE2),
                          Color(0xFF9757EE),
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF6B2FD0)
                              .withAlpha(isDark ? 70 : 58),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
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
                                color: Colors.white.withAlpha(42),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.star_rounded,
                                    size: 15,
                                    color: Color(0xFFFDE68A),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${plan.matchPercentage}% Alignment',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
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
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                plan.careerCategory,
                                style: const TextStyle(
                                  color: Color(0xFF6729CC),
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          plan.careerTitle,
                          style: textTheme.titleLarge?.copyWith(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.3,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          plan.executiveSummary,
                          style: TextStyle(
                            color: Colors.white.withAlpha(235),
                            fontSize: 13.2,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Heuristic match • Generated locally on-device from your quiz & profile',
                          style: TextStyle(
                            color: Colors.white.withAlpha(195),
                            fontSize: 11.2,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 14),

                // 3. Core Strengths & Growth Matrix Card
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  child: _SurfaceCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Core Strengths & Growth Matrix',
                          style: textTheme.titleMedium?.copyWith(
                            fontSize: 15.5,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Identified Strengths',
                          style: TextStyle(
                            fontSize: 12.2,
                            color: isDark
                                ? scheme.primary
                                : const Color(0xFF6B2FD0),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 7),
                        for (final strength in plan.keyStrengths)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 6),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Padding(
                                  padding: EdgeInsets.only(top: 2),
                                  child: Icon(
                                    Icons.check_circle_rounded,
                                    size: 16,
                                    color: AppColors.success,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    strength,
                                    style: textTheme.bodyMedium?.copyWith(
                                      fontSize: 13.4,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        Divider(
                          height: 20,
                          color: scheme.outlineVariant.withAlpha(140),
                        ),
                        Text(
                          'High-Leverage Growth Areas',
                          style: TextStyle(
                            fontSize: 12.2,
                            color: scheme.tertiary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 7),
                        for (final growth in plan.growthAreas)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 6),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(top: 6),
                                  child: Icon(
                                    Icons.circle,
                                    size: 7,
                                    color: scheme.tertiary,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    growth,
                                    style: textTheme.bodyMedium?.copyWith(
                                      fontSize: 13.4,
                                    ),
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

                // 4. Target Exams & Skills Card (Clean Wrap Pills)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  child: _SurfaceCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Target Entrance Exams & Skills',
                          style: textTheme.titleMedium?.copyWith(
                            fontSize: 15.5,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Benchmark Exams',
                          style: textTheme.labelMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: scheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 7,
                          runSpacing: 7,
                          children: plan.targetEntranceExams
                              .map(
                                (exam) => Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 5,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isDark
                                        ? scheme.primaryContainer
                                        : const Color(0xFFF0E8FF),
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  child: Text(
                                    exam,
                                    style: TextStyle(
                                      fontSize: 11.8,
                                      fontWeight: FontWeight.w700,
                                      color: isDark
                                          ? scheme.primary
                                          : const Color(0xFF5D26C6),
                                    ),
                                  ),
                                ),
                              )
                              .toList(),
                        ),
                        const SizedBox(height: 13),
                        Text(
                          'Essential Skills to Develop',
                          style: textTheme.labelMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: scheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 7,
                          runSpacing: 7,
                          children: plan.recommendedSkills
                              .map(
                                (skill) => Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 5,
                                  ),
                                  decoration: BoxDecoration(
                                    color: scheme.surfaceContainerHighest,
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  child: Text(
                                    skill,
                                    style: TextStyle(
                                      fontSize: 11.8,
                                      fontWeight: FontWeight.w600,
                                      color: scheme.onSurface,
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

                const SizedBox(height: 16),

                // 5. Personalized Milestone Roadmap Header + Progress
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              'Personalized Milestone Roadmap',
                              style: textTheme.titleMedium?.copyWith(
                                fontSize: 15.8,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                          Text(
                            '$completedCount / $totalMilestones Completed',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: isDark
                                  ? scheme.primary
                                  : const Color(0xFF7433D6),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: LinearProgressIndicator(
                          value: progressFraction,
                          minHeight: 7,
                          backgroundColor: isDark
                              ? Colors.white.withAlpha(24)
                              : const Color(0xFFE3D8FC),
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            Color(0xFF7433D6),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 11),

                // Milestone Cards
                for (final milestone in plan.milestones) ...[
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    child: _MilestoneCard(
                      milestone: milestone,
                      isCompleted: completedMilestones.contains(milestone.id),
                      onToggle: () async {
                        final xpEarned = await quizProvider.toggleMilestone(
                          milestone.id,
                        );
                        if (xpEarned && context.mounted) {
                          ScaffoldMessenger.of(context)
                            ..hideCurrentSnackBar()
                            ..showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Milestone completed! +25 XP earned',
                                ),
                              ),
                            );
                        }
                      },
                      onAction: milestone.actionRoute == null
                          ? null
                          : () => context.push(milestone.actionRoute!),
                    ),
                  ),
                  const SizedBox(height: 10),
                ],

                const SizedBox(height: 4),

                // 6. Portfolio Projects Card
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  child: _SurfaceCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 34,
                              height: 34,
                              decoration: BoxDecoration(
                                color: isDark
                                    ? scheme.primaryContainer
                                    : const Color(0xFFF3ECFF),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(
                                Icons.work_outline_rounded,
                                size: 18,
                                color: isDark
                                    ? scheme.primary
                                    : const Color(0xFF6B2FD0),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'Recommended Portfolio Projects',
                                style: textTheme.titleMedium?.copyWith(
                                  fontSize: 15.5,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 11),
                        for (var i = 0; i < plan.portfolioProjects.length; i++)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: 22,
                                  height: 22,
                                  decoration: BoxDecoration(
                                    color: isDark
                                        ? scheme.primaryContainer
                                        : const Color(0xFFF0E8FF),
                                    shape: BoxShape.circle,
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    '${i + 1}',
                                    style: TextStyle(
                                      fontSize: 11.2,
                                      fontWeight: FontWeight.w800,
                                      color: isDark
                                          ? scheme.primary
                                          : const Color(0xFF6B2FD0),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 9),
                                Expanded(
                                  child: Text(
                                    plan.portfolioProjects[i],
                                    style: textTheme.bodyMedium?.copyWith(
                                      fontSize: 13.3,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 14),

                // 7. Bottom Actions Row
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  child: Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 46,
                          child: OutlinedButton(
                            onPressed: () => context.push(AppRoutes.quiz),
                            style: OutlinedButton.styleFrom(
                              enableFeedback: false,
                              backgroundColor: scheme.surface,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                            ),
                            child: const Text(
                              'Recalibrate Quiz',
                              style: TextStyle(fontWeight: FontWeight.w700),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Container(
                          height: 46,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15),
                            gradient: const LinearGradient(
                              colors: [Color(0xFF5D26C6), Color(0xFF8344E4)],
                            ),
                          ),
                          child: Material(
                            color: Colors.transparent,
                            borderRadius: BorderRadius.circular(15),
                            clipBehavior: Clip.antiAlias,
                            child: InkWell(
                              enableFeedback: false,
                              onTap: () => context.push(AppRoutes.colleges),
                              child: const Center(
                                child: Text(
                                  'Explore Colleges',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ),
                          ),
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
    );
  }
}

class _SurfaceCard extends StatelessWidget {
  const _SurfaceCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final brightness = Theme.of(context).brightness;
    return Container(
      padding: const EdgeInsets.all(15),
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
      child: child,
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
    final brightness = Theme.of(context).brightness;
    final isDark = brightness == Brightness.dark;
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

    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: isCompleted
            ? AppColors.success.withAlpha(isDark ? 30 : 18)
            : scheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isCompleted
              ? AppColors.success.withAlpha(140)
              : scheme.outlineVariant.withAlpha(175),
          width: isCompleted ? 1.5 : 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.cardShadow(brightness),
            blurRadius: 13,
            offset: const Offset(0, 4),
          ),
        ],
      ),
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
                  color: isCompleted
                      ? AppColors.success
                      : (isDark ? scheme.primary : const Color(0xFF7433D6)),
                ),
              ),
              const SizedBox(width: 2),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      milestone.title,
                      style: textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        fontSize: 14.2,
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
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: priorityBg,
                  borderRadius: BorderRadius.circular(8),
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
          const SizedBox(height: 5),
          Padding(
            padding: const EdgeInsets.only(left: 42),
            child: Text(
              milestone.description,
              style: textTheme.bodySmall?.copyWith(
                color: scheme.onSurfaceVariant,
                height: 1.35,
              ),
            ),
          ),
          if (onAction != null) ...[
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: FilledButton.tonalIcon(
                onPressed: onAction,
                style: FilledButton.styleFrom(
                  enableFeedback: false,
                  minimumSize: const Size(0, 36),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: const Icon(Icons.arrow_forward_rounded, size: 15),
                label: const Text(
                  'Take Action',
                  style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _MentorBackdropPainter extends CustomPainter {
  const _MentorBackdropPainter({required this.isDark});

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
              : const [Color(0xFFF6F1FF), Color(0xFFF9F7FF), Color(0xFFF3EEFF)],
        ).createShader(rect),
    );
  }

  @override
  bool shouldRepaint(covariant _MentorBackdropPainter oldDelegate) =>
      oldDelegate.isDark != isDark;
}

class _MentorBlobPainter extends CustomPainter {
  const _MentorBlobPainter({required this.isDark});

  final bool isDark;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final blob = Path()
      ..moveTo(w * 0.12, h)
      ..cubicTo(w * 0.04, h * 0.48, w * 0.24, h * 0.18, w * 0.62, h * 0.22)
      ..cubicTo(w * 0.92, h * 0.25, w * 1.02, h * 0.56, w * 0.92, h)
      ..close();
    canvas.drawPath(
      blob,
      Paint()
        ..color = isDark
            ? const Color(0xFF31245E).withAlpha(155)
            : const Color(0xFFE6DCFE).withAlpha(215),
    );
  }

  @override
  bool shouldRepaint(covariant _MentorBlobPainter oldDelegate) =>
      oldDelegate.isDark != isDark;
}
