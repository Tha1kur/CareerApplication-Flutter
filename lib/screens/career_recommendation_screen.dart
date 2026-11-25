import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

import '../core/constants/app_routes.dart';
import '../core/router/app_navigation.dart';
import '../core/theme/app_colors.dart';
import '../models/college.dart';
import '../models/quiz_models.dart';
import '../models/scholarship.dart';
import '../providers/catalog_provider.dart';
import '../providers/quiz_gamification_provider.dart';
import '../services/scoring_service.dart';

/// Exact reference CareerGuide Career Paths screen (PDF Page 6):
/// - Lavender-white backdrop + CareerGuide top bar
/// - Back arrow + "Career Paths" hero + fixed stacked books & graduation cap banner (zero 3-line sparkles)
/// - White pill search bar + violet category filter chips
/// - Reference-styled white rounded career path cards with expand-to-explore skills,
///   reasons, matched colleges, scholarships, and Save This Path (+50 XP once)
class CareerRecommendationScreen extends StatefulWidget {
  const CareerRecommendationScreen({super.key, this.initialCareerKey});

  final String? initialCareerKey;

  @override
  State<CareerRecommendationScreen> createState() =>
      _CareerRecommendationScreenState();
}

class _CareerRecommendationScreenState
    extends State<CareerRecommendationScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';
  late String _selectedFilter;
  String? _expandedKey;

  @override
  void initState() {
    super.initState();
    final incoming = (widget.initialCareerKey ?? '').trim();
    if (incoming.isNotEmpty &&
        ScoringService.careerCatalog.containsKey(incoming)) {
      _selectedFilter = incoming;
      _expandedKey = incoming;
    } else {
      _selectedFilter = 'All';
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  IconData _iconForCareer(String key) {
    return switch (key) {
      'Engineering' => Icons.laptop_mac_rounded,
      'Science' => Icons.bar_chart_rounded,
      'Design' => Icons.draw_rounded,
      'Management' => Icons.trending_up_rounded,
      'Entrepreneurship' => Icons.rocket_launch_rounded,
      _ => Icons.school_rounded,
    };
  }

  @override
  Widget build(BuildContext context) {
    final quizProvider = context.watch<QuizGamificationProvider>();
    final catalogProvider = context.watch<CatalogProvider>();
    final scheme = Theme.of(context).colorScheme;
    final brightness = Theme.of(context).brightness;
    final isDark = brightness == Brightness.dark;
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

    // Auto-expand top career match on first view when no explicit career selected
    final effectiveExpandedKey =
        _expandedKey ?? (sorted.isNotEmpty ? sorted.first.key : null);

    final q = _query.trim().toLowerCase();
    final filtered = sorted.where((entry) {
      if (_selectedFilter != 'All' && entry.key != _selectedFilter) {
        return false;
      }
      if (q.isEmpty) return true;
      final info = ScoringService.careerCatalog[entry.key]!;
      return info.title.toLowerCase().contains(q) ||
          info.key.toLowerCase().contains(q) ||
          info.shortDescription.toLowerCase().contains(q) ||
          info.skills.any((s) => s.toLowerCase().contains(q)) ||
          info.vibeTags.any((v) => v.toLowerCase().contains(q));
    }).toList(growable: false);

    final filters = ['All', ...ScoringService.careerCategories];

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: CustomPaint(
              painter: _CareerBackdropPainter(isDark: isDark),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 6),

                // 1. Hero: Back arrow + "Career Paths" + Fixed Books & Grad Cap Artwork
                SizedBox(
                  height: 112,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Positioned(
                        right: 6,
                        bottom: 0,
                        width: 158,
                        height: 108,
                        child: CustomPaint(
                          painter: _BooksCapBackdropPainter(isDark: isDark),
                        ),
                      ),
                      Positioned(
                        left: 14,
                        top: 10,
                        right: 136,
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
                                    'Career Paths',
                                    style: textTheme.headlineSmall?.copyWith(
                                      fontSize: 23.5,
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
                                quizProvider.scores.isEmpty
                                    ? 'Explore personalized career\npaths based on your interests.'
                                    : 'Your top match: ${sorted.first.key}',
                                style: textTheme.bodySmall?.copyWith(
                                  color: quizProvider.scores.isEmpty
                                      ? (isDark
                                            ? scheme.onSurfaceVariant
                                            : const Color(0xFF4A4560))
                                      : (isDark
                                            ? scheme.primary
                                            : const Color(0xFF6B2FD0)),
                                  fontWeight: quizProvider.scores.isEmpty
                                      ? FontWeight.w400
                                      : FontWeight.w700,
                                  fontSize: 13,
                                  height: 1.35,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Fixed Books + 3D Graduation Cap Hero Artwork (zero 3-line sparkles)
                      Positioned(
                        right: 12,
                        bottom: 0,
                        width: 126,
                        height: 108,
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Positioned(
                              right: 0,
                              bottom: 2,
                              width: 112,
                              height: 62,
                              child: Image.asset(
                                'assets/images/home_books.png',
                                fit: BoxFit.contain,
                                errorBuilder: (_, _, _) =>
                                    const SizedBox.shrink(),
                              ),
                            ),
                            Positioned(
                              right: 12,
                              top: 2,
                              width: 92,
                              height: 62,
                              child: CustomPaint(
                                painter: _GradCapOverlayPainter(isDark: isDark),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // 3. White Pill Search Bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  child: Container(
                    height: 48,
                    padding: const EdgeInsets.only(left: 14, right: 8),
                    decoration: BoxDecoration(
                      color: scheme.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: scheme.outlineVariant.withAlpha(185),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.cardShadow(brightness),
                          blurRadius: 14,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.search_rounded,
                          size: 21,
                          color: isDark
                              ? scheme.onSurfaceVariant
                              : const Color(0xFF56506E),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextField(
                            controller: _searchController,
                            onChanged: (value) =>
                                setState(() => _query = value),
                            style: TextStyle(
                              fontSize: 13.6,
                              color: scheme.onSurface,
                            ),
                            decoration: InputDecoration(
                              hintText: 'Search career paths...',
                              hintStyle: TextStyle(
                                fontSize: 13.4,
                                color: isDark
                                    ? scheme.onSurfaceVariant
                                    : const Color(0xFF7B7594),
                              ),
                              border: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              filled: false,
                              isDense: true,
                              contentPadding: EdgeInsets.zero,
                            ),
                          ),
                        ),
                        if (_query.isNotEmpty)
                          GestureDetector(
                            onTap: () {
                              _searchController.clear();
                              setState(() => _query = '');
                            },
                            child: Padding(
                              padding: const EdgeInsets.only(right: 6),
                              child: Icon(
                                Icons.close_rounded,
                                size: 18,
                                color: scheme.onSurfaceVariant,
                              ),
                            ),
                          ),
                        Material(
                          color: isDark
                              ? scheme.primaryContainer
                              : const Color(0xFFF0E8FF),
                          borderRadius: BorderRadius.circular(10),
                          clipBehavior: Clip.antiAlias,
                          child: InkWell(
                            enableFeedback: false,
                            onTap: () => setState(() => _selectedFilter = 'All'),
                            child: SizedBox(
                              width: 34,
                              height: 34,
                              child: Icon(
                                Icons.tune_rounded,
                                size: 18,
                                color: isDark
                                    ? scheme.primary
                                    : const Color(0xFF7433D6),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 11),

                // 4. Horizontal Violet Filter Pills
                SizedBox(
                  height: 36,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    itemCount: filters.length,
                    separatorBuilder: (_, _) => const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      final label = filters[index];
                      final selected = _selectedFilter == label;
                      return Material(
                        color: selected
                            ? (isDark
                                  ? scheme.primary
                                  : const Color(0xFF7433D6))
                            : (isDark
                                  ? scheme.surface
                                  : const Color(0xFFEEE7FF)),
                        borderRadius: BorderRadius.circular(18),
                        clipBehavior: Clip.antiAlias,
                        child: InkWell(
                          enableFeedback: false,
                          onTap: () {
                            setState(() {
                              _selectedFilter = label;
                              if (label != 'All') {
                                _expandedKey = label;
                              }
                            });
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 15,
                              vertical: 8,
                            ),
                            child: Text(
                              label,
                              style: TextStyle(
                                fontSize: 12.5,
                                fontWeight: selected
                                    ? FontWeight.w700
                                    : FontWeight.w600,
                                color: selected
                                    ? Colors.white
                                    : (isDark
                                          ? scheme.onSurface
                                          : const Color(0xFF423C5C)),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 12),

                // 5. Reference White Rounded Career Path Cards List
                Expanded(
                  child: filtered.isEmpty
                      ? Center(
                          child: Text(
                            'No career paths matched "$_query".',
                            style: textTheme.bodyMedium?.copyWith(
                              color: scheme.onSurfaceVariant,
                            ),
                          ),
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.fromLTRB(14, 0, 14, 12),
                          itemCount: filtered.length,
                          separatorBuilder: (_, _) =>
                              const SizedBox(height: 11),
                          itemBuilder: (context, index) {
                            final entry = filtered[index];
                            final info =
                                ScoringService.careerCatalog[entry.key]!;
                            final percent = ((entry.value / maxScore) * 100)
                                .round()
                                .clamp(0, 100);
                            final colleges = ScoringService.collegesForCareer(
                              entry.key,
                              catalogProvider.allColleges,
                            );
                            final scholarships =
                                ScoringService.scholarshipsForCareer(
                                  entry.key,
                                  catalogProvider.allScholarships,
                                );
                            final isSaved =
                                quizProvider.savedCareerKey == entry.key;
                            final isExpanded =
                                effectiveExpandedKey == entry.key;

                            return _ReferenceCareerCard(
                              info: info,
                              icon: _iconForCareer(entry.key),
                              score: entry.value,
                              percent: percent,
                              hasQuizScores: quizProvider.scores.isNotEmpty,
                              answers: quizProvider.submittedAnswers,
                              colleges: colleges,
                              scholarships: scholarships,
                              isSaved: isSaved,
                              isExpanded: isExpanded,
                              onToggleExpand: () {
                                setState(() {
                                  _expandedKey = isExpanded ? '' : entry.key;
                                });
                              },
                              onSave: () async {
                                final awardedXp = await quizProvider
                                    .saveCareerPath(entry.key);
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
                              onCollegeTap: (id) =>
                                  context.push(AppRoutes.collegeDetails(id)),
                              onSeeColleges: () =>
                                  context.push(AppRoutes.colleges),
                              onSeeScholarships: () =>
                                  context.push(AppRoutes.scholarships),
                            );
                          },
                        ),
                ),

                // 6. Compact Bottom Action Bar (Dashboard & Score Breakdown)
                Padding(
                  padding: const EdgeInsets.fromLTRB(14, 4, 14, 10),
                  child: Row(
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
                        child: Container(
                          height: 46,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15),
                            gradient: const LinearGradient(
                              colors: [
                                Color(0xFF5D26C6),
                                Color(0xFF8344E4),
                              ],
                            ),
                          ),
                          child: Material(
                            color: Colors.transparent,
                            borderRadius: BorderRadius.circular(15),
                            clipBehavior: Clip.antiAlias,
                            child: InkWell(
                              enableFeedback: false,
                              onTap: () => context.push(AppRoutes.results),
                              child: const Center(
                                child: Text(
                                  'Score Breakdown',
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

class _ReferenceCareerCard extends StatelessWidget {
  const _ReferenceCareerCard({
    required this.info,
    required this.icon,
    required this.score,
    required this.percent,
    required this.hasQuizScores,
    required this.answers,
    required this.colleges,
    required this.scholarships,
    required this.isSaved,
    required this.isExpanded,
    required this.onToggleExpand,
    required this.onSave,
    required this.onCollegeTap,
    required this.onSeeColleges,
    required this.onSeeScholarships,
  });

  final CareerInfo info;
  final IconData icon;
  final int score;
  final int percent;
  final bool hasQuizScores;
  final QuizAnswers answers;
  final List<College> colleges;
  final List<Scholarship> scholarships;
  final bool isSaved;
  final bool isExpanded;
  final VoidCallback onToggleExpand;
  final VoidCallback onSave;
  final ValueChanged<String> onCollegeTap;
  final VoidCallback onSeeColleges;
  final VoidCallback onSeeScholarships;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final brightness = Theme.of(context).brightness;
    final isDark = brightness == Brightness.dark;
    final textTheme = Theme.of(context).textTheme;
    final reasons = [
      ...ScoringService.reasonChipsForCareer(info.key, answers),
      ...info.vibeTags,
    ];

    return Container(
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: isExpanded
              ? (isDark ? scheme.primary : const Color(0xFF8B5CF6))
              : scheme.outlineVariant.withAlpha(175),
          width: isExpanded ? 1.5 : 1.0,
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
        children: [
          Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(22),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              enableFeedback: false,
              onTap: onToggleExpand,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 14,
                ),
                child: Row(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: isDark
                            ? scheme.primaryContainer
                            : const Color(0xFFF3ECFF),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Icon(
                        icon,
                        size: 26,
                        color: isDark
                            ? scheme.primary
                            : const Color(0xFF6B2FD0),
                      ),
                    ),
                    const SizedBox(width: 13),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  info.title,
                                  style: textTheme.titleSmall?.copyWith(
                                    fontSize: 15.2,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: -0.2,
                                    color: isDark
                                        ? scheme.onSurface
                                        : const Color(0xFF17122B),
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (hasQuizScores) ...[
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 3,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isDark
                                        ? scheme.primaryContainer
                                        : const Color(0xFFEEE5FF),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    '$percent%',
                                    style: TextStyle(
                                      fontSize: 11.2,
                                      fontWeight: FontWeight.w800,
                                      color: isDark
                                          ? scheme.primary
                                          : const Color(0xFF6B2FD0),
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 3),
                          Text(
                            info.shortDescription,
                            style: textTheme.bodySmall?.copyWith(
                              color: isDark
                                  ? scheme.onSurfaceVariant
                                  : const Color(0xFF56506E),
                              fontSize: 12.2,
                              height: 1.32,
                            ),
                            maxLines: isExpanded ? 4 : 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        color: isDark
                            ? scheme.surfaceContainerHighest
                            : const Color(0xFFF4EEFF),
                        borderRadius: BorderRadius.circular(11),
                      ),
                      child: Icon(
                        isExpanded
                            ? Icons.keyboard_arrow_up_rounded
                            : Icons.arrow_forward_rounded,
                        size: 18,
                        color: isDark
                            ? scheme.primary
                            : const Color(0xFF7433D6),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          if (isExpanded) ...[
            Divider(
              height: 1,
              color: scheme.outlineVariant.withAlpha(140),
              indent: 14,
              endIndent: 14,
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Key skills',
                    style: textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 7),
                  Wrap(
                    spacing: 7,
                    runSpacing: 7,
                    children: info.skills
                        .map(
                          (skill) => _TagPill(
                            text: skill,
                            bg: isDark
                                ? scheme.primaryContainer
                                : const Color(0xFFF1E9FF),
                            fg: isDark
                                ? scheme.onPrimaryContainer
                                : const Color(0xFF5420B0),
                          ),
                        )
                        .toList(),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Why this suits you',
                    style: textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 7),
                  Wrap(
                    spacing: 7,
                    runSpacing: 7,
                    children: reasons
                        .map(
                          (r) => _TagPill(
                            text: r,
                            bg: scheme.surfaceContainerHighest,
                            fg: scheme.onSurface,
                          ),
                        )
                        .toList(),
                  ),
                  if (colleges.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Text(
                      'Good colleges to explore',
                      style: textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 7),
                    Wrap(
                      spacing: 7,
                      runSpacing: 7,
                      children: colleges
                          .take(3)
                          .map(
                            (c) => GestureDetector(
                              onTap: () => onCollegeTap(c.id),
                              child: _IconTagPill(
                                icon: Icons.school_rounded,
                                text: c.name,
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ],
                  if (scholarships.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Text(
                      'Matching scholarships',
                      style: textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 7),
                    Wrap(
                      spacing: 7,
                      runSpacing: 7,
                      children: scholarships
                          .take(3)
                          .map(
                            (s) => GestureDetector(
                              onTap: onSeeScholarships,
                              child: _IconTagPill(
                                icon: Icons.workspace_premium_rounded,
                                text: s.name,
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ],
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: FilledButton(
                          onPressed: isSaved ? null : onSave,
                          style: FilledButton.styleFrom(
                            enableFeedback: false,
                            minimumSize: const Size(0, 44),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: Text(isSaved ? 'Path Saved' : 'Save This Path'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton(
                          onPressed: onSeeColleges,
                          style: OutlinedButton.styleFrom(
                            enableFeedback: false,
                            minimumSize: const Size(0, 44),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: const Text('Explore Colleges'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ],
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
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 11.8,
          fontWeight: FontWeight.w600,
          color: fg,
        ),
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
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: scheme.primary),
          const SizedBox(width: 5),
          Flexible(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 11.8,
                fontWeight: FontWeight.w600,
                color: scheme.onSurface,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class _CareerBackdropPainter extends CustomPainter {
  const _CareerBackdropPainter({required this.isDark});

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

    final topLeft = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width * 0.44, 0)
      ..quadraticBezierTo(
        size.width * 0.24,
        size.height * 0.08,
        0,
        size.height * 0.14,
      )
      ..close();
    canvas.drawPath(
      topLeft,
      Paint()
        ..color = isDark
            ? const Color(0xFF281F4A).withAlpha(140)
            : const Color(0xFFEBE1FF).withAlpha(185),
    );
  }

  @override
  bool shouldRepaint(covariant _CareerBackdropPainter oldDelegate) =>
      oldDelegate.isDark != isDark;
}

class _BooksCapBackdropPainter extends CustomPainter {
  const _BooksCapBackdropPainter({required this.isDark});

  final bool isDark;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final blob = Path()
      ..moveTo(w * 0.12, h)
      ..cubicTo(w * 0.04, h * 0.46, w * 0.26, h * 0.18, w * 0.62, h * 0.22)
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
  bool shouldRepaint(covariant _BooksCapBackdropPainter oldDelegate) =>
      oldDelegate.isDark != isDark;
}

/// Crisp 3D dark-slate/violet graduation cap with golden tassel resting on top of the stacked books.
class _GradCapOverlayPainter extends CustomPainter {
  const _GradCapOverlayPainter({required this.isDark});

  final bool isDark;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Cap crown band
    final crown = Path()
      ..moveTo(w * 0.24, h * 0.45)
      ..lineTo(w * 0.52, h * 0.62)
      ..lineTo(w * 0.78, h * 0.46)
      ..lineTo(w * 0.76, h * 0.76)
      ..quadraticBezierTo(w * 0.51, h * 0.92, w * 0.26, h * 0.76)
      ..close();
    canvas.drawPath(
      crown,
      Paint()
        ..shader = const LinearGradient(
          colors: [Color(0xFF473A6B), Color(0xFF2B2246)],
        ).createShader(Rect.fromLTWH(w * 0.24, h * 0.44, w * 0.55, h * 0.48)),
    );

    // Mortarboard diamond top
    final top = Path()
      ..moveTo(w * 0.52, h * 0.08)
      ..lineTo(w * 0.94, h * 0.34)
      ..lineTo(w * 0.52, h * 0.60)
      ..lineTo(w * 0.10, h * 0.34)
      ..close();
    canvas.drawPath(
      top,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF6B5B96), Color(0xFF3A2E5C)],
        ).createShader(Rect.fromLTWH(0, 0, w, h * 0.62)),
    );

    // Subtle top bevel edge
    canvas.drawLine(
      Offset(w * 0.52, h * 0.10),
      Offset(w * 0.90, h * 0.33),
      Paint()
        ..color = Colors.white.withAlpha(75)
        ..strokeWidth = 1.4
        ..strokeCap = StrokeCap.round,
    );

    // Golden tassel cord & drop hanging cleanly on the right
    final cord = Path()
      ..moveTo(w * 0.53, h * 0.34)
      ..quadraticBezierTo(w * 0.78, h * 0.36, w * 0.80, h * 0.66);
    canvas.drawPath(
      cord,
      Paint()
        ..color = const Color(0xFFF59E0B)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.6
        ..strokeCap = StrokeCap.round,
    );
    canvas.drawCircle(
      Offset(w * 0.80, h * 0.71),
      w * 0.055,
      Paint()..color = const Color(0xFFFBBF24),
    );
    final drop = Path()
      ..moveTo(w * 0.76, h * 0.74)
      ..lineTo(w * 0.84, h * 0.74)
      ..lineTo(w * 0.86, h * 0.90)
      ..lineTo(w * 0.74, h * 0.90)
      ..close();
    canvas.drawPath(drop, Paint()..color = const Color(0xFFF59E0B));
  }

  @override
  bool shouldRepaint(covariant _GradCapOverlayPainter oldDelegate) =>
      oldDelegate.isDark != isDark;
}
