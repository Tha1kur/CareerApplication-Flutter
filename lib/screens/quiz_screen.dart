import 'dart:async';

import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

import '../core/constants/app_routes.dart';
import '../models/quiz_models.dart';
import '../providers/quiz_gamification_provider.dart';
import '../widgets/empty_state_view.dart';
import '../widgets/gradient_hero_card.dart';

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  int _index = 0;

  Future<void> _handleSubmit(QuizGamificationProvider provider) async {
    final questions = provider.questions;
    final draft = provider.draftAnswers;

    final firstUnanswered = questions.indexWhere(
      (q) => (draft[q.id] ?? '').trim().isEmpty,
    );

    if (firstUnanswered >= 0) {
      unawaited(HapticFeedback.mediumImpact());
      setState(() => _index = firstUnanswered);
      final remaining = questions
          .where((q) => (draft[q.id] ?? '').trim().isEmpty)
          .length;
      if (!mounted) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text('Please answer all questions ($remaining remaining)'),
          ),
        );
      return;
    }

    unawaited(HapticFeedback.heavyImpact());
    await provider.submitQuiz();
    if (!mounted) return;
    context.go(AppRoutes.recommendations);
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<QuizGamificationProvider>();
    final questions = provider.questions;
    final draft = provider.draftAnswers;
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Aptitude Quiz'),
        leading: IconButton(
          tooltip: 'Back to Home',
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.go(AppRoutes.home),
        ),
      ),
      body: SafeArea(
        child: !provider.isLoaded
            ? const Center(child: CircularProgressIndicator())
            : provider.loadError != null
            ? EmptyStateView(
                icon: Icons.error_outline_rounded,
                title: 'Could not load quiz',
                subtitle: provider.loadError!,
                actionLabel: 'Back to Home',
                onAction: () => context.go(AppRoutes.home),
              )
            : questions.isEmpty
            ? EmptyStateView(
                icon: Icons.quiz_outlined,
                title: 'No quiz questions available',
                subtitle: 'Could not find questions in assets/data/aptitudequiz.json.',
                actionLabel: 'Back to Home',
                onAction: () => context.go(AppRoutes.home),
              )
            : Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _QuizProgressHeader(
                      index: _index.clamp(0, questions.length - 1),
                      total: questions.length,
                      answeredCount: draft.length,
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 240),
                        child: _QuizQuestionCard(
                          key: ValueKey(
                            questions[_index.clamp(0, questions.length - 1)].id,
                          ),
                          question:
                              questions[_index.clamp(0, questions.length - 1)],
                          selectedValue:
                              draft[questions[_index.clamp(
                                    0,
                                    questions.length - 1,
                                  )]
                                  .id],
                          onOptionSelected: (value) {
                            unawaited(HapticFeedback.selectionClick());
                            final qId =
                                questions[_index.clamp(0, questions.length - 1)]
                                    .id;
                            unawaited(provider.selectDraftAnswer(qId, value));
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextButton(
                            onPressed: () => context.go(AppRoutes.home),
                            child: const Text('Exit'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: OutlinedButton(
                            onPressed: _index > 0
                                ? () {
                                    unawaited(HapticFeedback.selectionClick());
                                    setState(() => _index--);
                                  }
                                : null,
                            child: const Text('Previous'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: FilledButton(
                            onPressed: _index == questions.length - 1
                                ? () => _handleSubmit(provider)
                                : () {
                                    unawaited(HapticFeedback.selectionClick());
                                    setState(() => _index++);
                                  },
                            child: Text(
                              _index == questions.length - 1
                                  ? 'Submit'
                                  : 'Next',
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (draft.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text(
                        'Progress auto-saved locally (${draft.length}/${questions.length})',
                        style: textTheme.labelSmall?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
      ),
    );
  }
}

class _QuizProgressHeader extends StatelessWidget {
  const _QuizProgressHeader({
    required this.index,
    required this.total,
    required this.answeredCount,
  });

  final int index;
  final int total;
  final int answeredCount;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final progress = total == 0 ? 0.0 : (index + 1) / total;

    return GradientHeroCard(
      horizontalGradient: true,
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Question ${index + 1} of $total',
                style: textTheme.titleMedium?.copyWith(
                  color: scheme.onPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '$answeredCount answered',
                style: textTheme.labelMedium?.copyWith(
                  color: scheme.onPrimary.withAlpha(235),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 7,
              backgroundColor: scheme.onPrimary.withAlpha(60),
              valueColor: AlwaysStoppedAnimation<Color>(scheme.secondary),
            ),
          ),
        ],
      ),
    );
  }
}

class _QuizQuestionCard extends StatelessWidget {
  const _QuizQuestionCard({
    super.key,
    required this.question,
    required this.selectedValue,
    required this.onOptionSelected,
  });

  final QuizQuestion question;
  final String? selectedValue;
  final ValueChanged<String> onOptionSelected;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Card(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              question.question,
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 14),
            for (var i = 0; i < question.options.length; i++) ...[
              _OptionTile(
                index: i,
                label: question.options[i].label,
                selected: selectedValue == question.options[i].value,
                onTap: () => onOptionSelected(question.options[i].value),
                scheme: scheme,
              ),
              if (i < question.options.length - 1) const SizedBox(height: 10),
            ],
          ],
        ),
      ),
    );
  }
}

class _OptionTile extends StatelessWidget {
  const _OptionTile({
    required this.index,
    required this.label,
    required this.selected,
    required this.onTap,
    required this.scheme,
  });

  final int index;
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final ColorScheme scheme;

  @override
  Widget build(BuildContext context) {
    final bg = selected
        ? scheme.primaryContainer
        : scheme.surfaceContainerHighest;
    final border = selected ? scheme.primary : scheme.outlineVariant;
    final fg = selected ? scheme.onPrimaryContainer : scheme.onSurface;
    final letter = String.fromCharCode('A'.codeUnitAt(0) + index);

    return Material(
      color: bg,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: border, width: selected ? 1.5 : 1),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          child: Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: fg.withAlpha(selected ? 38 : 22),
                child: Text(
                  letter,
                  style: Theme.of(context).textTheme.labelLarge
                      ?.copyWith(color: fg, fontWeight: FontWeight.w700),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: fg,
                    fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
              ),
              if (selected)
                Icon(Icons.check_circle_rounded, color: scheme.primary),
            ],
          ),
        ),
      ),
    );
  }
}
