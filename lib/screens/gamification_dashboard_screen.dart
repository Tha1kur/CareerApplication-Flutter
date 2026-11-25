import 'dart:async';
import 'dart:math' as math;

import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

import '../core/constants/app_routes.dart';
import '../models/user_progress.dart';
import '../providers/quiz_gamification_provider.dart';
import '../widgets/gradient_hero_card.dart';

class GamificationDashboardScreen extends StatefulWidget {
  const GamificationDashboardScreen({super.key});

  @override
  State<GamificationDashboardScreen> createState() =>
      _GamificationDashboardScreenState();
}

class _GamificationDashboardScreenState
    extends State<GamificationDashboardScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _confettiController;
  final List<_ConfettiParticle> _particles = [];
  int? _lastKnownLevel;
  int? _lastKnownBadgeCount;

  @override
  void initState() {
    super.initState();
    _confettiController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  void _triggerConfetti(ColorScheme scheme) {
    final rng = math.Random();
    final palette = [
      scheme.primary,
      scheme.secondary,
      scheme.primaryContainer,
      scheme.secondaryContainer,
      scheme.tertiary,
    ];
    _particles
      ..clear()
      ..addAll(
        List.generate(55, (_) {
          final angle = rng.nextDouble() * math.pi * 2;
          final speed = 120 + rng.nextDouble() * 240;
          return _ConfettiParticle(
            vx: math.cos(angle) * speed,
            vy: math.sin(angle) * speed - 60,
            radius: 3 + rng.nextDouble() * 4,
            color: palette[rng.nextInt(palette.length)],
          );
        }),
      );
    unawaited(_confettiController.forward(from: 0));
  }

  void _checkLevelUp(
    BuildContext context,
    LevelInfo levelInfo,
    UserProgress progress,
  ) {
    final prevLevel = _lastKnownLevel;
    final prevBadges = _lastKnownBadgeCount;
    _lastKnownLevel = levelInfo.level;
    _lastKnownBadgeCount = progress.badges.length;

    if (prevLevel == null || prevBadges == null) return;

    final leveledUp = levelInfo.level > prevLevel;
    final earnedBadge = progress.badges.length > prevBadges;
    if (!leveledUp && !earnedBadge) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _triggerConfetti(Theme.of(context).colorScheme);
      if (leveledUp) {
        unawaited(
          showDialog<void>(
            context: context,
            builder: (dialogContext) => AlertDialog(
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
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final quizProvider = context.watch<QuizGamificationProvider>();
    final progress = quizProvider.progress;
    final levelInfo = quizProvider.levelInfo;
    final savedCareerTitle = quizProvider.savedCareerTitle;
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    _checkLevelUp(context, levelInfo, progress);

    final badgesDisplay = progress.badges.isEmpty
        ? const ['No badges yet']
        : progress.badges;

    return Scaffold(
      appBar: AppBar(title: const Text('Dashboard')),
      body: SafeArea(
        child: Stack(
          children: [
            ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Gradient Level Hero
                GradientHeroCard(
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Your journey',
                              style: textTheme.labelMedium?.copyWith(
                                color: scheme.onPrimary.withAlpha(220),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Level ${levelInfo.level}',
                              style: textTheme.headlineMedium?.copyWith(
                                color: scheme.onPrimary,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Text(
                              '${progress.points} XP total',
                              style: textTheme.bodyMedium?.copyWith(
                                color: scheme.onPrimary.withAlpha(235),
                              ),
                            ),
                            if (savedCareerTitle.isNotEmpty) ...[
                              const SizedBox(height: 4),
                              Text(
                                'Saved path: $savedCareerTitle',
                                style: textTheme.bodySmall?.copyWith(
                                  color: scheme.onPrimary.withAlpha(245),
                                ),
                              ),
                            ],
                            const SizedBox(height: 12),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(6),
                              child: LinearProgressIndicator(
                                value: levelInfo.progressFraction,
                                minHeight: 7,
                                backgroundColor: scheme.onPrimary.withAlpha(65),
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  scheme.secondary,
                                ),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              '${levelInfo.currentXp}/${levelInfo.nextLevelXp} XP to next level',
                              style: textTheme.labelSmall?.copyWith(
                                color: scheme.onPrimary.withAlpha(225),
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

                const SizedBox(height: 16),

                // Stats Row
                Row(
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

                const SizedBox(height: 18),

                // Badges header + quick actions
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Badges',
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
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
                          onPressed: () => context.push(AppRoutes.scholarships),
                          child: const Text('Scholarships'),
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: 0.92,
                  ),
                  itemCount: badgesDisplay.length,
                  itemBuilder: (context, index) =>
                      _BadgeTile(name: badgesDisplay[index]),
                ),

                const SizedBox(height: 16),

                // Recent Activity
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Recent activity',
                          style: textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
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

            // Confetti Canvas Overlay
            IgnorePointer(
              child: AnimatedBuilder(
                animation: _confettiController,
                builder: (context, _) {
                  if (!_confettiController.isAnimating || _particles.isEmpty) {
                    return const SizedBox.shrink();
                  }
                  return CustomPaint(
                    size: Size.infinite,
                    painter: _ConfettiPainter(
                      particles: _particles,
                      t: _confettiController.value,
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LevelRing extends StatelessWidget {
  const _LevelRing({required this.levelInfo});

  final LevelInfo levelInfo;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return SizedBox(
      width: 92,
      height: 92,
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: levelInfo.progressFraction),
        duration: const Duration(milliseconds: 600),
        builder: (context, animatedFraction, _) {
          return CustomPaint(
            painter: _LevelRingPainter(
              progress: animatedFraction,
              trackColor: scheme.onPrimary.withAlpha(60),
              progressColor: scheme.secondary,
              accentColor: scheme.onPrimary,
            ),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Lv ${levelInfo.level}',
                    style: textTheme.titleSmall?.copyWith(
                      color: scheme.onPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    '${(levelInfo.progressFraction * 100).round()}%',
                    style: textTheme.labelSmall?.copyWith(
                      color: scheme.onPrimary.withAlpha(220),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _LevelRingPainter extends CustomPainter {
  const _LevelRingPainter({
    required this.progress,
    required this.trackColor,
    required this.progressColor,
    required this.accentColor,
  });

  final double progress;
  final Color trackColor;
  final Color progressColor;
  final Color accentColor;

  @override
  void paint(Canvas canvas, Size size) {
    final strokeWidth = size.shortestSide * 0.14;
    final rect = Rect.fromLTWH(
      strokeWidth / 2,
      strokeWidth / 2,
      size.width - strokeWidth,
      size.height - strokeWidth,
    );

    final bgPaint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    final fgPaint = Paint()
      ..shader = SweepGradient(
        colors: [progressColor, accentColor, progressColor],
      ).createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(rect, -math.pi / 2, math.pi * 2, false, bgPaint);
    canvas.drawArc(
      rect,
      -math.pi / 2,
      math.pi * 2 * progress.clamp(0.0, 1.0),
      false,
      fgPaint,
    );
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
    final textTheme = Theme.of(context).textTheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: textTheme.labelMedium?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
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
            const Color(0xFFE3F2FD),
            Icons.emoji_events_rounded,
            const Color(0xFF1E88E5),
          )
        : lower.contains('college')
        ? (
            const Color(0xFFF3E5F5),
            Icons.school_rounded,
            const Color(0xFF6A1B9A),
          )
        : lower.contains('scholar')
        ? (
            const Color(0xFFFFF3E0),
            Icons.emoji_events_rounded,
            const Color(0xFFFF8F00),
          )
        : (scheme.primaryContainer, Icons.verified_rounded, scheme.primary);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8),
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
              style: textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
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
      padding: const EdgeInsets.only(bottom: 4),
      child: Text('• $text', style: Theme.of(context).textTheme.bodySmall),
    );
  }
}

class _ConfettiParticle {
  const _ConfettiParticle({
    required this.vx,
    required this.vy,
    required this.radius,
    required this.color,
  });

  final double vx;
  final double vy;
  final double radius;
  final Color color;
}

class _ConfettiPainter extends CustomPainter {
  const _ConfettiPainter({required this.particles, required this.t});

  final List<_ConfettiParticle> particles;
  final double t;

  @override
  void paint(Canvas canvas, Size size) {
    final origin = Offset(size.width / 2, size.height * 0.12);
    final elapsed = t * 1.4;
    const gravity = 460.0;
    final alpha = ((1 - t) * 255).round().clamp(0, 255);

    for (final p in particles) {
      final dx = origin.dx + p.vx * elapsed;
      final dy = origin.dy + p.vy * elapsed + 0.5 * gravity * elapsed * elapsed;
      final paint = Paint()..color = p.color.withAlpha(alpha);
      canvas.drawCircle(Offset(dx, dy), p.radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _ConfettiPainter oldDelegate) =>
      oldDelegate.t != t;
}
