import 'dart:async';

import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

import '../core/constants/app_routes.dart';
import '../providers/quiz_gamification_provider.dart';
import '../services/scoring_service.dart';
import '../widgets/empty_state_view.dart';
import '../widgets/gradient_hero_card.dart';

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
    final textTheme = Theme.of(context).textTheme;

    if (scores.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Quiz Results')),
        body: EmptyStateView(
          icon: Icons.analytics_outlined,
          title: 'No results yet',
          subtitle: 'Take the aptitude quiz to see your career matches.',
          actionLabel: 'Start Quiz',
          onAction: () => context.push(AppRoutes.quiz),
        ),
      );
    }

    final sorted = ScoringService.sortedScores(scores);
    final topEntry = sorted.first;
    final maxScore = topEntry.value <= 0 ? 1 : topEntry.value;
    final topPercent = ((topEntry.value / maxScore) * 100).round();
    final summaryChips = ScoringService.buildAnswerSummaryChips(answers);

    return Scaffold(
      appBar: AppBar(title: const Text('Quiz Results')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            GradientHeroCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Quiz results',
                    style: textTheme.labelMedium?.copyWith(
                      color: scheme.onPrimary.withAlpha(225),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Top match: ${topEntry.key}',
                    style: textTheme.headlineSmall?.copyWith(
                      color: scheme.onPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$topPercent% relative match • ${topEntry.value} pts (heuristic)',
                    style: textTheme.bodyMedium?.copyWith(
                      color: scheme.onPrimary.withAlpha(240),
                    ),
                  ),
                  if (summaryChips.isNotEmpty) ...[
                    const SizedBox(height: 14),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: summaryChips
                          .map(
                            (chip) => Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: scheme.secondaryContainer,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                chip,
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
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Career Score Breakdown
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Career scores',
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Divider(),
                    const SizedBox(height: 8),
                    for (final entry in sorted) ...[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(entry.key, style: textTheme.bodyMedium),
                          Text(
                            '${entry.value} pts',
                            style: textTheme.labelMedium?.copyWith(
                              color: scheme.onSurfaceVariant,
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
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],
                  ],
                ),
              ),
            ),

            if (history.isNotEmpty) ...[
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
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
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          TextButton(
                            onPressed: () => context.push(AppRoutes.quiz),
                            child: const Text('Retake Quiz'),
                          ),
                        ],
                      ),
                      const Divider(),
                      for (var i = 0; i < history.take(4).length; i++) ...[
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
                                        fontWeight: FontWeight.w600,
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
                                  color: scheme.primaryContainer,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  '${history[i].topScore} pts',
                                  style: textTheme.labelSmall?.copyWith(
                                    color: scheme.onPrimaryContainer,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],

            const SizedBox(height: 18),
            FilledButton(
              onPressed: () => context.push(AppRoutes.recommendations),
              child: const Text('View detailed recommendations'),
            ),
            const SizedBox(height: 10),
            OutlinedButton(
              onPressed: () => context.push(AppRoutes.dashboard),
              child: const Text('Open gamified dashboard'),
            ),
            const SizedBox(height: 10),
            OutlinedButton(
              onPressed: () => context.push(AppRoutes.colleges),
              child: const Text('Explore colleges'),
            ),
          ],
        ),
      ),
    );
  }
}
