import 'dart:async';

import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

import '../core/constants/app_routes.dart';
import '../core/router/app_navigation.dart';
import '../core/theme/app_colors.dart';
import '../models/quiz_models.dart';
import '../providers/quiz_gamification_provider.dart';
import '../services/scoring_service.dart';
import '../widgets/empty_state_view.dart';

/// Cohesive CareerGuide Lavender & White Quiz Results screen:
/// - Secondary screen (no repeated brand top bar) starting with <- Quiz Results
/// - Rich violet Top Match banner + floating white Career Scores & Quiz History cards
class ResultsScreen extends StatefulWidget {
  const ResultsScreen({super.key});

  @override
  State<ResultsScreen> createState() => _ResultsScreenState();
}

class _ResultsScreenState extends State<ResultsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      unawaited(context.read<QuizGamificationProvider>().markViewedResults());
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<QuizGamificationProvider>();
    final scores = provider.scores;
    final answers = provider.submittedAnswers;
    final history = provider.quizHistory;
    final scheme = Theme.of(context).colorScheme;
    final brightness = Theme.of(context).brightness;
    final isDark = brightness == Brightness.dark;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: CustomPaint(
              painter: _ResultsBackdropPainter(isDark: isDark),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 8),

                // Clean Secondary Header Row
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
                          'Quiz Results',
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
                    ],
                  ),
                ),

                const SizedBox(height: 10),

                Expanded(
                  child: scores.isEmpty
                      ? EmptyStateView(
                          icon: Icons.analytics_outlined,
                          title: 'No results yet',
                          subtitle:
                              'Take the aptitude quiz to see your career matches.',
                          actionLabel: 'Start Quiz',
                          onAction: () => context.push(AppRoutes.quiz),
                        )
                      : _buildResultsBody(
                          context,
                          scores: scores,
                          answers: answers,
                          history: history,
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultsBody(
    BuildContext context, {
    required Map<String, int> scores,
    required QuizAnswers answers,
    required List<QuizAttempt> history,
  }) {
    final scheme = Theme.of(context).colorScheme;
    final brightness = Theme.of(context).brightness;
    final isDark = brightness == Brightness.dark;
    final textTheme = Theme.of(context).textTheme;

    final sorted = ScoringService.sortedScores(scores);
    final topEntry = sorted.first;
    final maxScore = topEntry.value <= 0 ? 1 : topEntry.value;
    final topPercent = ((topEntry.value / maxScore) * 100).round();
    final summaryChips = ScoringService.buildAnswerSummaryChips(answers);

    return ListView(
      padding: const EdgeInsets.fromLTRB(14, 2, 14, 24),
      children: [
        // Rich Violet Top Match Hero Card
        Container(
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
                color: const Color(0xFF6B2FD0).withAlpha(isDark ? 70 : 58),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Quiz results',
                style: TextStyle(
                  color: Colors.white.withAlpha(215),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                'Top match: ${topEntry.key}',
                style: textTheme.headlineSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '$topPercent% relative match • ${topEntry.value} pts (heuristic)',
                style: TextStyle(
                  color: Colors.white.withAlpha(235),
                  fontSize: 13.5,
                ),
              ),
              if (summaryChips.isNotEmpty) ...[
                const SizedBox(height: 12),
                Wrap(
                  spacing: 7,
                  runSpacing: 7,
                  children: summaryChips
                      .map(
                        (chip) => Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withAlpha(42),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            chip,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11.5,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),
              ],
            ],
          ),
        ),

        const SizedBox(height: 14),

        // Career Score Breakdown White Card
        Container(
          padding: const EdgeInsets.all(16),
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Career scores',
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              Divider(height: 20, color: scheme.outlineVariant.withAlpha(140)),
              for (final entry in sorted) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      entry.key,
                      style: textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      '${entry.value} pts',
                      style: textTheme.labelMedium?.copyWith(
                        color: scheme.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: (entry.value / maxScore).clamp(0.0, 1.0),
                    minHeight: 7,
                    backgroundColor: isDark
                        ? Colors.white.withAlpha(24)
                        : const Color(0xFFE6DCFE),
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      Color(0xFF7433D6),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
              ],
            ],
          ),
        ),

        if (history.isNotEmpty) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        'Quiz History (${history.length} attempts)',
                        style: textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () => context.push(AppRoutes.quiz),
                      child: const Text('Retake Quiz'),
                    ),
                  ],
                ),
                Divider(height: 16, color: scheme.outlineVariant.withAlpha(140)),
                for (var i = 0; i < history.take(4).length; i++)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Attempt #${history.length - i} • ${history[i].topCareer}',
                                style: textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              Text(
                                history[i].formattedDate,
                                style: textTheme.labelSmall?.copyWith(
                                  color: scheme.onSurfaceVariant,
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
                            color: isDark
                                ? scheme.primaryContainer
                                : const Color(0xFFF0E8FF),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '${history[i].topScore} pts',
                            style: TextStyle(
                              fontSize: 11.8,
                              fontWeight: FontWeight.w800,
                              color: isDark
                                  ? scheme.primary
                                  : const Color(0xFF6B2FD0),
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

        const SizedBox(height: 16),

        Container(
          width: double.infinity,
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
              onTap: () => context.push(AppRoutes.recommendations),
              child: const Center(
                child: Text(
                  'View detailed recommendations',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 46,
                child: OutlinedButton(
                  onPressed: () => context.push(AppRoutes.dashboard),
                  style: OutlinedButton.styleFrom(
                    enableFeedback: false,
                    backgroundColor: scheme.surface,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  child: const Text(
                    'Dashboard',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: SizedBox(
                height: 46,
                child: OutlinedButton(
                  onPressed: () => context.push(AppRoutes.colleges),
                  style: OutlinedButton.styleFrom(
                    enableFeedback: false,
                    backgroundColor: scheme.surface,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  child: const Text(
                    'Explore colleges',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _ResultsBackdropPainter extends CustomPainter {
  const _ResultsBackdropPainter({required this.isDark});

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
  bool shouldRepaint(covariant _ResultsBackdropPainter oldDelegate) =>
      oldDelegate.isDark != isDark;
}
