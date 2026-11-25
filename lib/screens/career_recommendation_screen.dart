import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

import '../core/constants/app_routes.dart';
import '../models/college.dart';
import '../models/quiz_models.dart';
import '../models/scholarship.dart';
import '../providers/catalog_provider.dart';
import '../providers/quiz_gamification_provider.dart';
import '../services/scoring_service.dart';
import '../widgets/gradient_hero_card.dart';

class CareerRecommendationScreen extends StatefulWidget {
  const CareerRecommendationScreen({super.key});

  @override
  State<CareerRecommendationScreen> createState() =>
      _CareerRecommendationScreenState();
}

class _CareerRecommendationScreenState
    extends State<CareerRecommendationScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final quizProvider = context.watch<QuizGamificationProvider>();
    final catalogProvider = context.watch<CatalogProvider>();
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final effectiveScores = quizProvider.scores.isEmpty
        ? {for (final key in ScoringService.careerCategories) key: 0}
        : quizProvider.scores;
    final sorted = ScoringService.sortedScores(effectiveScores)
        .where((e) => ScoringService.careerCatalog.containsKey(e.key))
        .toList(growable: false);

    final maxScore = sorted.isEmpty || sorted.first.value <= 0
        ? 1
        : sorted.first.value;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Career Recommendations'),
        leading: IconButton(
          tooltip: 'Back to Home',
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.go(AppRoutes.home),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              GradientHeroCard(
                horizontalGradient: true,
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      quizProvider.scores.isEmpty
                          ? 'Explore all 5 career tracks'
                          : 'Great job finishing the quiz!',
                      style: textTheme.labelMedium?.copyWith(
                        color: scheme.onPrimary.withAlpha(230),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      quizProvider.scores.isEmpty
                          ? 'Browse paths & take the quiz'
                          : 'Your top match: ${sorted.first.key}',
                      style: textTheme.titleLarge?.copyWith(
                        color: scheme.onPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Swipe left or right to compare how different paths fit your strengths.',
                      style: textTheme.bodySmall?.copyWith(
                        color: scheme.onPrimary.withAlpha(240),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: sorted.length,
                  onPageChanged: (page) => setState(() => _currentPage = page),
                  itemBuilder: (context, index) {
                    final entry = sorted[index];
                    final info = ScoringService.careerCatalog[entry.key]!;
                    final percent = ((entry.value / maxScore) * 100)
                        .round()
                        .clamp(0, 100);
                    final colleges = ScoringService.collegesForCareer(
                      entry.key,
                      catalogProvider.allColleges,
                    );
                    final scholarships = ScoringService.scholarshipsForCareer(
                      entry.key,
                      catalogProvider.allScholarships,
                    );
                    final isSaved = quizProvider.savedCareerKey == entry.key;

                    return _CareerSwipeCard(
                      info: info,
                      score: entry.value,
                      percent: percent,
                      answers: quizProvider.submittedAnswers,
                      colleges: colleges,
                      scholarships: scholarships,
                      isSaved: isSaved,
                      onSave: () async {
                        final awardedXp = await quizProvider.saveCareerPath(
                          entry.key,
                        );
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context)
                          ..hideCurrentSnackBar()
                          ..showSnackBar(
                            SnackBar(
                              content: Text(
                                awardedXp
                                    ? 'Saved ${info.title} (+50 XP earned!)'
                                    : 'Saved ${info.title} as your career path',
                              ),
                            ),
                          );
                      },
                      onSeeColleges: () => context.push(AppRoutes.colleges),
                      onSeeScholarships: () =>
                          context.push(AppRoutes.scholarships),
                    );
                  },
                ),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(sorted.length, (idx) {
                  final selected = idx == _currentPage;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: selected ? 18 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: selected
                          ? scheme.primary
                          : scheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 6),
              Text(
                'Swipe left / right to explore all ${sorted.length} career tracks.',
                style: textTheme.bodySmall?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => context.push(AppRoutes.dashboard),
                      child: const Text('Dashboard'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: FilledButton(
                      onPressed: () => context.push(AppRoutes.results),
                      child: const Text('Score Breakdown'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CareerSwipeCard extends StatelessWidget {
  const _CareerSwipeCard({
    required this.info,
    required this.score,
    required this.percent,
    required this.answers,
    required this.colleges,
    required this.scholarships,
    required this.isSaved,
    required this.onSave,
    required this.onSeeColleges,
    required this.onSeeScholarships,
  });

  final CareerInfo info;
  final int score;
  final int percent;
  final QuizAnswers answers;
  final List<College> colleges;
  final List<Scholarship> scholarships;
  final bool isSaved;
  final VoidCallback onSave;
  final VoidCallback onSeeColleges;
  final VoidCallback onSeeScholarships;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final reasons = [
      ...ScoringService.reasonChipsForCareer(info.key, answers),
      ...info.vibeTags,
    ];

    return Card(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        info.title,
                        style: textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        info.shortDescription,
                        style: textTheme.bodyMedium?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: scheme.primary.withAlpha(28),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Column(
                    children: [
                      Text(
                        '$percent%',
                        style: textTheme.titleSmall?.copyWith(
                          color: scheme.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        '$score pts',
                        style: textTheme.labelSmall?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(),
            const SizedBox(height: 10),
            Text(
              'Key skills',
              style: textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: info.skills
                  .map(
                    (skill) => _TagPill(
                      text: skill,
                      bg: scheme.primaryContainer,
                      fg: scheme.onPrimaryContainer,
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 14),
            Text(
              'This suits you because…',
              style: textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: reasons
                  .map(
                    (r) => _TagPill(
                      text: r,
                      bg: scheme.secondaryContainer,
                      fg: scheme.onSecondaryContainer,
                    ),
                  )
                  .toList(),
            ),
            if (colleges.isNotEmpty) ...[
              const SizedBox(height: 14),
              Text(
                'Good colleges to explore',
                style: textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: colleges
                    .take(3)
                    .map(
                      (c) => _IconTagPill(
                        icon: Icons.school_rounded,
                        text: c.name,
                      ),
                    )
                    .toList(),
              ),
            ],
            if (scholarships.isNotEmpty) ...[
              const SizedBox(height: 14),
              Text(
                'Scholarships that might fit',
                style: textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: scholarships
                    .take(3)
                    .map(
                      (s) =>
                          _IconTagPill(icon: Icons.star_rounded, text: s.name),
                    )
                    .toList(),
              ),
            ],
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: FilledButton(
                    onPressed: isSaved ? null : onSave,
                    child: Text(isSaved ? 'Path Saved' : 'Save This Path'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton(
                    onPressed: onSeeColleges,
                    child: const Text('Explore Colleges'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: onSeeScholarships,
                child: const Text('View Scholarships'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TagPill extends StatelessWidget {
  const _TagPill({required this.text, required this.bg, required this.fg});

  final String text;
  final Color bg;
  final Color fg;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(color: fg),
      ),
    );
  }
}

class _IconTagPill extends StatelessWidget {
  const _IconTagPill({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: scheme.primary),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              text,
              style: Theme.of(context).textTheme.labelMedium,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
