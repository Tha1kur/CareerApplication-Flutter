import 'dart:async';
import 'dart:math' as math;

import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

import '../core/constants/app_routes.dart';
import '../core/router/app_navigation.dart';
import '../core/theme/app_colors.dart';
import '../models/user_progress.dart';
import '../providers/quiz_gamification_provider.dart';

/// Cohesive CareerGuide Lavender & White Gamification Dashboard screen:
/// - Secondary screen (no repeated brand top bar) starting with <- Dashboard
/// - Rich violet Level & XP Hero Card with crisp circular ring + progress bar
/// - 3 floating white stat cards, 3-column Badges grid (padding: EdgeInsets.zero), Recent Activity
class GamificationDashboardScreen extends StatefulWidget {
  const GamificationDashboardScreen({super.key});

  @override
  State<GamificationDashboardScreen> createState() =>
      _GamificationDashboardScreenState();
}

class _GamificationDashboardScreenState
    extends State<GamificationDashboardScreen> {
  int? _lastKnownLevel;

  void _checkLevelUp(
    BuildContext context,
    LevelInfo levelInfo,
    UserProgress progress,
  ) {
    final prevLevel = _lastKnownLevel;
    _lastKnownLevel = levelInfo.level;
    if (prevLevel == null || levelInfo.level <= prevLevel) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      unawaited(
        showDialog<void>(
          context: context,
          builder: (dialogContext) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            title: const Text('Level Up!'),
            content: Text(
              'You reached Level ${levelInfo.level} with ${progress.points} XP total.',
            ),
            actions: [
              FilledButton(
                onPressed: () => Navigator.of(dialogContext).pop(),
                child: const Text('Nice!'),
              ),
            ],
          ),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final quizProvider = context.watch<QuizGamificationProvider>();
    final progress = quizProvider.progress;
    final levelInfo = quizProvider.levelInfo;
    final savedCareerTitle = quizProvider.savedCareerTitle;
    final scheme = Theme.of(context).colorScheme;
    final brightness = Theme.of(context).brightness;
    final isDark = brightness == Brightness.dark;
    final textTheme = Theme.of(context).textTheme;

    _checkLevelUp(context, levelInfo, progress);

    final badgesDisplay = progress.badges.isEmpty
        ? const ['No badges yet']
        : progress.badges;

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: CustomPaint(
              painter: _DashboardBackdropPainter(isDark: isDark),
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
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Dashboard',
                              style: textTheme.headlineSmall?.copyWith(
                                fontSize: 22.5,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.5,
                                color: isDark
                                    ? scheme.onSurface
                                    : const Color(0xFF17122B),
                              ),
                            ),
                            Text(
                              'Track levels, XP milestones & earned badges.',
                              style: textTheme.bodySmall?.copyWith(
                                color: scheme.onSurfaceVariant,
                                fontSize: 12.2,
                              ),
                            ),
                          ],
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
                          Icons.emoji_events_rounded,
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

                // 2. Rich Violet Level & XP Hero Card
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  child: Container(
                    padding: const EdgeInsets.all(18),
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
                          color: const Color(0xFF6B2FD0).withAlpha(
                            isDark ? 70 : 58,
                          ),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Your journey',
                                style: TextStyle(
                                  color: Colors.white.withAlpha(215),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Level ${levelInfo.level}',
                                style: textTheme.headlineMedium?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              Text(
                                '${progress.points} XP total',
                                style: TextStyle(
                                  color: Colors.white.withAlpha(235),
                                  fontSize: 13.8,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              if (savedCareerTitle.isNotEmpty) ...[
                                const SizedBox(height: 4),
                                Text(
                                  'Saved path: $savedCareerTitle',
                                  style: TextStyle(
                                    color: Colors.white.withAlpha(225),
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                              const SizedBox(height: 12),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(6),
                                child: LinearProgressIndicator(
                                  value: levelInfo.progressFraction,
                                  minHeight: 7,
                                  backgroundColor: Colors.white.withAlpha(60),
                                  valueColor: const AlwaysStoppedAnimation<Color>(
                                    Color(0xFFEBCFFF),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                '${levelInfo.currentXp}/${levelInfo.nextLevelXp} XP to next level',
                                style: TextStyle(
                                  color: Colors.white.withAlpha(220),
                                  fontSize: 11.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 14),
                        _LevelRing(levelInfo: levelInfo),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 14),

                // 3. Stats Row
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  child: Row(
                    children: [
                      Expanded(
                        child: _StatCard(
                          label: 'Points',
                          value: '${progress.points}',
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _StatCard(
                          label: 'Badges',
                          value: '${progress.badges.length}',
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _StatCard(
                          label: 'Milestones',
                          value: '${progress.completedMilestonesCount}',
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // 4. Badges Header + Quick Links
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Badges',
                        style: textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      Wrap(
                        spacing: 4,
                        children: [
                          TextButton(
                            onPressed: () => context.push(AppRoutes.colleges),
                            child: const Text('Colleges'),
                          ),
                          TextButton(
                            onPressed: () =>
                                context.push(AppRoutes.scholarships),
                            child: const Text('Scholarships'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 8),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  child: GridView.builder(
                    padding: EdgeInsets.zero,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                          childAspectRatio: 0.90,
                        ),
                    itemCount: badgesDisplay.length,
                    itemBuilder: (context, index) =>
                        _BadgeTile(name: badgesDisplay[index]),
                  ),
                ),

                const SizedBox(height: 14),

                // 5. Recent Activity White Card
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  child: Container(
                    padding: const EdgeInsets.all(15),
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
                          'Recent activity',
                          style: textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w800,
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(height: 8),
                        if (!progress.completedQuiz &&
                            !progress.viewedResults &&
                            !progress.exploredColleges &&
                            !progress.checkedScholarships &&
                            progress.badges.isEmpty)
                          Text(
                            'Complete the quiz or explore colleges and scholarships to start earning XP and badges.',
                            style: textTheme.bodySmall?.copyWith(
                              color: scheme.onSurfaceVariant,
                            ),
                          )
                        else ...[
                          if (progress.completedQuiz)
                            const _ActivityLine('Completed aptitude quiz'),
                          if (progress.viewedResults)
                            const _ActivityLine('Viewed career results'),
                          if (progress.exploredColleges)
                            const _ActivityLine('Explored colleges catalog'),
                          if (progress.checkedScholarships)
                            const _ActivityLine('Checked scholarship listings'),
                          for (final badge in progress.badges.take(4))
                            _ActivityLine('Earned badge: $badge'),
                        ],
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

class _LevelRing extends StatelessWidget {
  const _LevelRing({required this.levelInfo});

  final LevelInfo levelInfo;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 82,
      height: 82,
      child: CustomPaint(
        painter: _LevelRingPainter(progress: levelInfo.progressFraction),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Lv ${levelInfo.level}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Text(
                '${(levelInfo.progressFraction * 100).round()}%',
                style: TextStyle(
                  color: Colors.white.withAlpha(220),
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LevelRingPainter extends CustomPainter {
  const _LevelRingPainter({required this.progress});

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    const strokeWidth = 7.5;
    final rect = Rect.fromLTWH(
      strokeWidth / 2,
      strokeWidth / 2,
      size.width - strokeWidth,
      size.height - strokeWidth,
    );

    canvas.drawArc(
      rect,
      -math.pi / 2,
      math.pi * 2,
      false,
      Paint()
        ..color = Colors.white.withAlpha(65)
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth,
    );

    if (progress > 0) {
      canvas.drawArc(
        rect,
        -math.pi / 2,
        math.pi * 2 * progress.clamp(0.0, 1.0),
        false,
        Paint()
          ..color = const Color(0xFFEBCFFF)
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeWidth
          ..strokeCap = StrokeCap.round,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _LevelRingPainter oldDelegate) =>
      oldDelegate.progress != progress;
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final brightness = Theme.of(context).brightness;
    final isDark = brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 13),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: scheme.outlineVariant.withAlpha(175)),
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
          Text(
            label,
            style: TextStyle(
              fontSize: 11.8,
              color: scheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: isDark ? scheme.onSurface : const Color(0xFF17122B),
            ),
          ),
        ],
      ),
    );
  }
}

class _BadgeTile extends StatelessWidget {
  const _BadgeTile({required this.name});

  final String name;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    final brightness = Theme.of(context).brightness;
    final isEmptyPlaceholder = name == 'No badges yet';
    final lower = name.toLowerCase();

    final (bg, icon, tint) = isEmptyPlaceholder
        ? (
            scheme.surfaceContainerHighest,
            Icons.work_outline_rounded,
            scheme.onSurfaceVariant,
          )
        : lower.contains('quiz')
        ? (
            const Color(0xFFEDE4FF),
            Icons.emoji_events_rounded,
            const Color(0xFF6B2FD0),
          )
        : lower.contains('college')
        ? (
            const Color(0xFFF3E5F5),
            Icons.school_rounded,
            const Color(0xFF7433D6),
          )
        : lower.contains('scholar')
        ? (
            const Color(0xFFFEF3C7),
            Icons.workspace_premium_rounded,
            const Color(0xFFD97706),
          )
        : (scheme.primaryContainer, Icons.verified_rounded, scheme.primary);

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: scheme.outlineVariant.withAlpha(175)),
        boxShadow: [
          BoxShadow(
            color: AppColors.cardShadow(brightness),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: bg,
            child: Icon(icon, color: tint, size: 20),
          ),
          const SizedBox(height: 6),
          Text(
            name,
            style: textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w700),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          if (!isEmptyPlaceholder)
            Text(
              'Earned',
              style: textTheme.labelSmall?.copyWith(
                color: scheme.onSurfaceVariant,
                fontSize: 10,
              ),
            ),
        ],
      ),
    );
  }
}

class _ActivityLine extends StatelessWidget {
  const _ActivityLine(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 5),
      child: Row(
        children: [
          const Icon(
            Icons.check_circle_rounded,
            size: 15,
            color: AppColors.success,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(text, style: Theme.of(context).textTheme.bodySmall),
          ),
        ],
      ),
    );
  }
}

class _DashboardBackdropPainter extends CustomPainter {
  const _DashboardBackdropPainter({required this.isDark});

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
  bool shouldRepaint(covariant _DashboardBackdropPainter oldDelegate) =>
      oldDelegate.isDark != isDark;
}
