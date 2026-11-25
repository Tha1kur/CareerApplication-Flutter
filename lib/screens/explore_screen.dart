import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

import '../core/constants/app_routes.dart';
import '../core/theme/app_colors.dart';
import '../models/college.dart';
import '../models/scholarship.dart';
import '../providers/catalog_provider.dart';
import '../providers/quiz_gamification_provider.dart';
import '../widgets/career_guide_top_bar.dart';

/// Exact reference CareerGuide Explore screen (PDF Page 4):
/// - Fixed layout, zero floating animations, zero 3-line sparkles, zero tap click sounds
/// - Real interactive local search across bundled colleges, scholarships & career domains
/// - Exact signpost hero, 4 shortcut cards, 4 Trending Careers cards & Personalized Career Path banner
class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';
  String _searchScope = 'All';

  static const _careerDomains = <({String title, String tags, String route})>[
    (
      title: 'Software Developer & Engineering',
      tags: 'engineering software developer coding computer science btech iit',
      route: AppRoutes.recommendations,
    ),
    (
      title: 'Data Analyst & Science Research',
      tags: 'science data analyst analytics research biology physics math',
      route: AppRoutes.recommendations,
    ),
    (
      title: 'UI/UX Designer & Creative Arts',
      tags: 'design ui ux designer creative product nid arts media',
      route: AppRoutes.recommendations,
    ),
    (
      title: 'AI/ML Engineer & Tech Innovation',
      tags: 'ai ml artificial intelligence machine learning engineering tech',
      route: AppRoutes.recommendations,
    ),
    (
      title: 'Business, Management & Startups',
      tags: 'management entrepreneurship mba iim finance startup business',
      route: AppRoutes.recommendations,
    ),
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _openFilterSheet() {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    const scopes = ['All', 'Careers', 'Colleges', 'Scholarships'];

    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      backgroundColor: scheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(18, 0, 18, 22),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Filter Explore Search',
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: scopes.map((scope) {
                    final selected = _searchScope == scope;
                    return ChoiceChip(
                      label: Text(scope),
                      selected: selected,
                      onSelected: (_) {
                        setState(() => _searchScope = scope);
                        Navigator.of(sheetContext).pop();
                      },
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final brightness = Theme.of(context).brightness;
    final isDark = brightness == Brightness.dark;
    final textTheme = Theme.of(context).textTheme;
    final catalog = context.watch<CatalogProvider>();
    final quizProvider = context.watch<QuizGamificationProvider>();

    final q = _query.trim().toLowerCase();
    final isSearching = q.isNotEmpty;

    final matchedCareers =
        isSearching && (_searchScope == 'All' || _searchScope == 'Careers')
        ? _careerDomains
              .where(
                (c) =>
                    c.title.toLowerCase().contains(q) ||
                    c.tags.toLowerCase().contains(q),
              )
              .toList()
        : const <({String title, String tags, String route})>[];

    final matchedColleges =
        isSearching && (_searchScope == 'All' || _searchScope == 'Colleges')
        ? catalog.allColleges
              .where(
                (c) =>
                    c.id.toLowerCase().contains(q) ||
                    c.name.toLowerCase().contains(q) ||
                    (c.city ?? '').toLowerCase().contains(q) ||
                    (c.state ?? '').toLowerCase().contains(q) ||
                    c.courses.any(
                      (course) => course.toLowerCase().contains(q),
                    ) ||
                    c.tags.any((tag) => tag.toLowerCase().contains(q)),
              )
              .toList()
        : const <College>[];

    final matchedScholarships =
        isSearching && (_searchScope == 'All' || _searchScope == 'Scholarships')
        ? catalog.allScholarships
              .where(
                (s) =>
                    s.name.toLowerCase().contains(q) ||
                    s.category.toLowerCase().contains(q) ||
                    s.tags.any((tag) => tag.toLowerCase().contains(q)),
              )
              .toList()
        : const <Scholarship>[];

    final personalizedRoute = quizProvider.progress.completedQuiz
        ? AppRoutes.aiMentor
        : AppRoutes.quiz;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) context.go(AppRoutes.home);
      },
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Stack(
          children: [
            Positioned.fill(
              child: CustomPaint(
                painter: _ExploreBackdropPainter(isDark: isDark),
              ),
            ),
            SafeArea(
              bottom: false,
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(bottom: 94),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 1. Exact Top Bar
                    const CareerGuideTopBar(),

                    // 2. Hero: "Explore Your / Career Options" + Fixed Signpost Illustration
                    SizedBox(
                      height: 136,
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Positioned(
                            right: 6,
                            bottom: 0,
                            width: 170,
                            height: 126,
                            child: CustomPaint(
                              painter: _SignpostBackdropPainter(isDark: isDark),
                            ),
                          ),
                          Positioned(
                            left: 18,
                            top: 12,
                            right: 146,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                RichText(
                                  text: TextSpan(
                                    style: textTheme.headlineSmall?.copyWith(
                                      fontSize: 25,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: -0.6,
                                      height: 1.15,
                                    ),
                                    children: [
                                      TextSpan(
                                        text: 'Explore Your\n',
                                        style: TextStyle(
                                          color: isDark
                                              ? scheme.onSurface
                                              : const Color(0xFF17122B),
                                        ),
                                      ),
                                      TextSpan(
                                        text: 'Career Options',
                                        style: TextStyle(
                                          color: isDark
                                              ? scheme.primary
                                              : const Color(0xFF7433D6),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  'Discover streams, careers, and\nopportunities that fit you.',
                                  style: textTheme.bodySmall?.copyWith(
                                    color: isDark
                                        ? scheme.onSurfaceVariant
                                        : const Color(0xFF4A4560),
                                    height: 1.35,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Positioned(
                            right: 12,
                            bottom: 0,
                            width: 138,
                            height: 132,
                            child: CustomPaint(
                              painter: _ExploreSignpostPainter(isDark: isDark),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // 3. White Pill Search Bar + Filter Sliders Button
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      child: Container(
                        height: 52,
                        padding: const EdgeInsets.only(left: 14, right: 8),
                        decoration: BoxDecoration(
                          color: scheme.surface,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: scheme.outlineVariant.withAlpha(185),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.cardShadow(brightness),
                              blurRadius: 16,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.search_rounded,
                              size: 22,
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
                                  fontSize: 13.8,
                                  color: scheme.onSurface,
                                ),
                                decoration: InputDecoration(
                                  hintText: _searchScope == 'All'
                                      ? 'Search careers, colleges, scholarships...'
                                      : 'Search $_searchScope...',
                                  hintStyle: TextStyle(
                                    fontSize: 13.5,
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
                            if (isSearching)
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
                              borderRadius: BorderRadius.circular(11),
                              clipBehavior: Clip.antiAlias,
                              child: InkWell(
                                enableFeedback: false,
                                onTap: _openFilterSheet,
                                child: SizedBox(
                                  width: 36,
                                  height: 36,
                                  child: Icon(
                                    Icons.tune_rounded,
                                    size: 19,
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

                    // Live Search Results (only shown when user types in search bar)
                    if (isSearching) ...[
                      const SizedBox(height: 12),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: scheme.surface,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: scheme.outlineVariant.withAlpha(180),
                            ),
                          ),
                          child: Material(
                            type: MaterialType.transparency,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (matchedCareers.isEmpty &&
                                    matchedColleges.isEmpty &&
                                    matchedScholarships.isEmpty)
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 8,
                                      horizontal: 4,
                                    ),
                                    child: Text(
                                      'No local matches for "$_query". Try "IIT", "Design", "Engineering", or "Scholarship".',
                                      style: textTheme.bodySmall?.copyWith(
                                        color: scheme.onSurfaceVariant,
                                      ),
                                    ),
                                  )
                                else ...[
                                  for (final c in matchedCareers)
                                    _SearchResultTile(
                                      icon: Icons.school_rounded,
                                      title: c.title,
                                      subtitle: 'Career Path',
                                      onTap: () => context.push(c.route),
                                    ),
                                  for (final col in matchedColleges)
                                    _SearchResultTile(
                                      icon: Icons.account_balance_rounded,
                                      title: col.name,
                                      subtitle: col.formattedLocation,
                                      onTap: () => context.push(
                                        AppRoutes.collegeDetails(col.id),
                                      ),
                                    ),
                                  for (final sch in matchedScholarships)
                                    _SearchResultTile(
                                      icon: Icons.workspace_premium_rounded,
                                      title: sch.name,
                                      subtitle:
                                          '${sch.category}${sch.amount != null ? ' • ${sch.amount}' : ''}',
                                      onTap: () =>
                                          context.push(AppRoutes.scholarships),
                                    ),
                                ],
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],

                    const SizedBox(height: 14),

                    // 4. 4-Column Category Shortcuts Row (Exact Reference Look)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      child: Row(
                        children: [
                          Expanded(
                            child: _CategoryShortcutCard(
                              label: 'Careers',
                              icon: Icons.school_rounded,
                              onTap: () =>
                                  context.push(AppRoutes.recommendations),
                            ),
                          ),
                          const SizedBox(width: 9),
                          Expanded(
                            child: _CategoryShortcutCard(
                              label: 'Colleges',
                              icon: Icons.account_balance_rounded,
                              onTap: () => context.push(AppRoutes.colleges),
                            ),
                          ),
                          const SizedBox(width: 9),
                          Expanded(
                            child: _CategoryShortcutCard(
                              label: 'Scholarships',
                              icon: Icons.layers_rounded,
                              onTap: () => context.push(AppRoutes.scholarships),
                            ),
                          ),
                          const SizedBox(width: 9),
                          Expanded(
                            child: _CategoryShortcutCard(
                              label: 'AI Mentor',
                              icon: Icons.work_rounded,
                              onTap: () => context.push(AppRoutes.aiMentor),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 18),

                    // 5. "Trending Careers" Section + 4-Card Row
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              'Trending Careers',
                              style: textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w800,
                                fontSize: 16.5,
                                letterSpacing: -0.3,
                                color: isDark
                                    ? scheme.onSurface
                                    : const Color(0xFF17122B),
                              ),
                            ),
                          ),
                          _ViewAllLink(
                            onTap: () =>
                                context.push(AppRoutes.recommendations),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 10),

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      child: Row(
                        children: [
                          Expanded(
                            child: _TrendingCareerCard(
                              title: 'Software\nDeveloper',
                              icon: Icons.laptop_mac_rounded,
                              onTap: () => context.push(
                                AppRoutes.recommendationsWithCareer(
                                  'Engineering',
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 9),
                          Expanded(
                            child: _TrendingCareerCard(
                              title: 'Data\nAnalyst',
                              icon: Icons.bar_chart_rounded,
                              onTap: () => context.push(
                                AppRoutes.recommendationsWithCareer('Science'),
                              ),
                            ),
                          ),
                          const SizedBox(width: 9),
                          Expanded(
                            child: _TrendingCareerCard(
                              title: 'UI/UX\nDesigner',
                              icon: Icons.draw_rounded,
                              onTap: () => context.push(
                                AppRoutes.recommendationsWithCareer('Design'),
                              ),
                            ),
                          ),
                          const SizedBox(width: 9),
                          Expanded(
                            child: _TrendingCareerCard(
                              title: 'AI/ML\nEngineer',
                              icon: Icons.memory_rounded,
                              onTap: () => context.push(
                                AppRoutes.recommendationsWithCareer(
                                  'Engineering',
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 18),

                    // 6. "Recommended for You" Header + Exact Bottom Banner Card
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              'Recommended for You',
                              style: textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w800,
                                fontSize: 16.5,
                                letterSpacing: -0.3,
                                color: isDark
                                    ? scheme.onSurface
                                    : const Color(0xFF17122B),
                              ),
                            ),
                          ),
                          _ViewAllLink(
                            onTap: () => context.push(AppRoutes.aiMentor),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 10),

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      child: Container(
                        padding: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          color: scheme.surface,
                          borderRadius: BorderRadius.circular(22),
                          border: Border.all(
                            color: scheme.outlineVariant.withAlpha(180),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.cardShadow(brightness),
                              blurRadius: 16,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(17),
                          child: CustomPaint(
                            painter: _RecommendedBannerPainter(isDark: isDark),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                enableFeedback: false,
                                onTap: () => context.push(personalizedRoute),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 11,
                                  ),
                                  child: Row(
                                    children: [
                                      SizedBox(
                                        width: 72,
                                        height: 52,
                                        child: Image.asset(
                                          'assets/images/home_books.png',
                                          fit: BoxFit.contain,
                                          errorBuilder: (_, _, _) => Icon(
                                            Icons.menu_book_rounded,
                                            color: scheme.primary,
                                            size: 32,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Container(
                                        width: 1,
                                        height: 44,
                                        color: isDark
                                            ? Colors.white.withAlpha(32)
                                            : const Color(0xFFDAD0F4),
                                      ),
                                      const SizedBox(width: 11),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Personalized Career Path',
                                              style: textTheme.titleSmall
                                                  ?.copyWith(
                                                    fontWeight: FontWeight.w800,
                                                    fontSize: 14.5,
                                                    letterSpacing: -0.2,
                                                    color: isDark
                                                        ? scheme.onSurface
                                                        : const Color(
                                                            0xFF17122B,
                                                          ),
                                                  ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            const SizedBox(height: 3),
                                            Text(
                                              'Get a career roadmap based on\nyour interests and strengths.',
                                              style: textTheme.bodySmall
                                                  ?.copyWith(
                                                    color: isDark
                                                        ? scheme
                                                              .onSurfaceVariant
                                                        : const Color(
                                                            0xFF56506E,
                                                          ),
                                                    fontSize: 12,
                                                    height: 1.32,
                                                  ),
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Container(
                                        width: 42,
                                        height: 42,
                                        decoration: BoxDecoration(
                                          gradient: const LinearGradient(
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                            colors: [
                                              Color(0xFF8C4DF0),
                                              Color(0xFF6629CC),
                                            ],
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            13,
                                          ),
                                        ),
                                        child: const Icon(
                                          Icons.arrow_forward_rounded,
                                          color: Colors.white,
                                          size: 20,
                                        ),
                                      ),
                                    ],
                                  ),
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
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryShortcutCard extends StatelessWidget {
  const _CategoryShortcutCard({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final brightness = Theme.of(context).brightness;
    final isDark = brightness == Brightness.dark;

    return Container(
      height: 92,
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: scheme.outlineVariant.withAlpha(170)),
        boxShadow: [
          BoxShadow(
            color: AppColors.cardShadow(brightness),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(18),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          enableFeedback: false,
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 10),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: isDark
                        ? scheme.primaryContainer
                        : const Color(0xFFF3ECFF),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    size: 24,
                    color: isDark ? scheme.primary : const Color(0xFF6A2CCB),
                  ),
                ),
                const SizedBox(height: 7),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 11.4,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.2,
                    color: isDark ? scheme.onSurface : const Color(0xFF17122B),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TrendingCareerCard extends StatelessWidget {
  const _TrendingCareerCard({
    required this.title,
    required this.icon,
    required this.onTap,
  });

  final String title;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final brightness = Theme.of(context).brightness;
    final isDark = brightness == Brightness.dark;

    return Container(
      height: 104,
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: scheme.outlineVariant.withAlpha(170)),
        boxShadow: [
          BoxShadow(
            color: AppColors.cardShadow(brightness),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(18),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          enableFeedback: false,
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 10),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: isDark
                        ? scheme.primaryContainer
                        : const Color(0xFFF3ECFF),
                    borderRadius: BorderRadius.circular(13),
                  ),
                  child: Icon(
                    icon,
                    size: 22,
                    color: isDark ? scheme.primary : const Color(0xFF6A2CCB),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 11.2,
                    fontWeight: FontWeight.w700,
                    height: 1.2,
                    letterSpacing: -0.15,
                    color: isDark ? scheme.onSurface : const Color(0xFF17122B),
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ViewAllLink extends StatelessWidget {
  const _ViewAllLink({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = isDark ? scheme.primary : const Color(0xFF7433D6);

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(10),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        enableFeedback: false,
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'View All',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
              ),
              const SizedBox(width: 3),
              Icon(Icons.arrow_forward_rounded, size: 15, color: color),
            ],
          ),
        ),
      ),
    );
  }
}

class _SearchResultTile extends StatelessWidget {
  const _SearchResultTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return ListTile(
      enableFeedback: false,
      dense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 6),
      leading: Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          color: scheme.primaryContainer,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, size: 18, color: scheme.primary),
      ),
      title: Text(
        title,
        style: const TextStyle(fontSize: 13.2, fontWeight: FontWeight.w700),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(fontSize: 11.5, color: scheme.onSurfaceVariant),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: Icon(
        Icons.arrow_forward_ios_rounded,
        size: 13,
        color: scheme.primary,
      ),
      onTap: onTap,
    );
  }
}

class _ExploreBackdropPainter extends CustomPainter {
  const _ExploreBackdropPainter({required this.isDark});

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
  bool shouldRepaint(covariant _ExploreBackdropPainter oldDelegate) =>
      oldDelegate.isDark != isDark;
}

class _SignpostBackdropPainter extends CustomPainter {
  const _SignpostBackdropPainter({required this.isDark});

  final bool isDark;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final blob = Path()
      ..moveTo(w * 0.10, h)
      ..cubicTo(w * 0.04, h * 0.56, w * 0.24, h * 0.24, w * 0.58, h * 0.24)
      ..cubicTo(w * 0.90, h * 0.24, w * 1.02, h * 0.52, w * 0.94, h)
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
  bool shouldRepaint(covariant _SignpostBackdropPainter oldDelegate) =>
      oldDelegate.isDark != isDark;
}

class _RecommendedBannerPainter extends CustomPainter {
  const _RecommendedBannerPainter({required this.isDark});

  final bool isDark;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    canvas.drawRect(
      rect,
      Paint()
        ..color = isDark ? const Color(0xFF231C42) : const Color(0xFFF6F2FF),
    );
    final wave = Path()
      ..moveTo(size.width * 0.68, size.height)
      ..quadraticBezierTo(
        size.width * 0.80,
        size.height * 0.38,
        size.width,
        size.height * 0.16,
      )
      ..lineTo(size.width, size.height)
      ..close();
    canvas.drawPath(
      wave,
      Paint()
        ..color = isDark
            ? const Color(0xFF2F2557).withAlpha(150)
            : const Color(0xFFECE3FE).withAlpha(200),
    );
  }

  @override
  bool shouldRepaint(covariant _RecommendedBannerPainter oldDelegate) =>
      oldDelegate.isDark != isDark;
}

/// Exact reference directional signpost illustration (PDF Page 4, zero 3-line sparkles):
/// Dark violet post + 3 directional arrow boards (lavender right, golden-amber right,
/// deep violet left) + stylized purple/lavender base foliage & grass hill.
class _ExploreSignpostPainter extends CustomPainter {
  const _ExploreSignpostPainter({required this.isDark});

  final bool isDark;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // 1. Back stylized lavender botanical sprigs on left & right base
    final leftSprig = Paint()
      ..color = isDark ? const Color(0xFF5A4296) : const Color(0xFF8368B8);
    final rightSprig = Paint()
      ..color = isDark ? const Color(0xFF7B5EC4) : const Color(0xFFA792DA);

    void drawLeaf(
      Offset base,
      double angle,
      double len,
      double width,
      Paint paint,
    ) {
      canvas.save();
      canvas.translate(base.dx, base.dy);
      canvas.rotate(angle);
      final p = Path()
        ..moveTo(0, 0)
        ..quadraticBezierTo(-width, -len * 0.45, 0, -len)
        ..quadraticBezierTo(width, -len * 0.45, 0, 0)
        ..close();
      canvas.drawPath(p, paint);
      canvas.restore();
    }

    // Left foliage cluster
    drawLeaf(Offset(w * 0.25, h * 0.96), -0.78, h * 0.24, w * 0.045, leftSprig);
    drawLeaf(Offset(w * 0.28, h * 0.96), -0.45, h * 0.30, w * 0.048, leftSprig);
    drawLeaf(
      Offset(w * 0.32, h * 0.96),
      -0.15,
      h * 0.22,
      w * 0.040,
      rightSprig,
    );

    // Right foliage cluster
    drawLeaf(Offset(w * 0.72, h * 0.96), 0.32, h * 0.28, w * 0.046, rightSprig);
    drawLeaf(Offset(w * 0.75, h * 0.96), 0.68, h * 0.25, w * 0.048, rightSprig);
    drawLeaf(Offset(w * 0.77, h * 0.96), 1.02, h * 0.19, w * 0.040, leftSprig);

    // 2. Vertical dark-violet wooden post
    final postRect = RRect.fromRectAndCorners(
      Rect.fromLTWH(w * 0.46, h * 0.09, w * 0.095, h * 0.87),
      topLeft: const Radius.circular(6),
      topRight: const Radius.circular(6),
    );
    canvas.drawRRect(
      postRect,
      Paint()
        ..shader = const LinearGradient(
          colors: [Color(0xFF4A3768), Color(0xFF2D2045)],
        ).createShader(postRect.outerRect),
    );

    // Subtle post drop shadows under boards
    final shadowPaint = Paint()..color = const Color(0xFF221636).withAlpha(70);

    // 3. Top signboard: Soft lavender-violet arrow pointing RIGHT
    final topBoard = Path()
      ..moveTo(w * 0.23, h * 0.21)
      ..lineTo(w * 0.74, h * 0.17)
      ..lineTo(w * 0.85, h * 0.265)
      ..lineTo(w * 0.75, h * 0.37)
      ..lineTo(w * 0.24, h * 0.38)
      ..close();
    canvas.drawPath(topBoard.shift(const Offset(0, 3)), shadowPaint);
    canvas.drawPath(
      topBoard,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF9E7CF6), Color(0xFF7B4BE0)],
        ).createShader(Rect.fromLTWH(w * 0.22, h * 0.16, w * 0.65, h * 0.24)),
    );
    // Crisp top bevel highlight
    canvas.drawLine(
      Offset(w * 0.25, h * 0.22),
      Offset(w * 0.73, h * 0.185),
      Paint()
        ..color = Colors.white.withAlpha(85)
        ..strokeWidth = 1.6
        ..strokeCap = StrokeCap.round,
    );

    // 4. Middle signboard: Bright golden-amber arrow pointing RIGHT
    final midBoard = Path()
      ..moveTo(w * 0.30, h * 0.43)
      ..lineTo(w * 0.79, h * 0.41)
      ..lineTo(w * 0.90, h * 0.505)
      ..lineTo(w * 0.79, h * 0.60)
      ..lineTo(w * 0.30, h * 0.59)
      ..close();
    canvas.drawPath(midBoard.shift(const Offset(0, 3)), shadowPaint);
    canvas.drawPath(
      midBoard,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFBBF24), Color(0xFFF59E0B)],
        ).createShader(Rect.fromLTWH(w * 0.30, h * 0.40, w * 0.62, h * 0.22)),
    );
    canvas.drawLine(
      Offset(w * 0.32, h * 0.445),
      Offset(w * 0.78, h * 0.425),
      Paint()
        ..color = Colors.white.withAlpha(110)
        ..strokeWidth = 1.6
        ..strokeCap = StrokeCap.round,
    );

    // 5. Bottom signboard: Deep royal violet arrow pointing LEFT
    final botBoard = Path()
      ..moveTo(w * 0.73, h * 0.64)
      ..lineTo(w * 0.27, h * 0.62)
      ..lineTo(w * 0.16, h * 0.71)
      ..lineTo(w * 0.27, h * 0.80)
      ..lineTo(w * 0.73, h * 0.81)
      ..close();
    canvas.drawPath(botBoard.shift(const Offset(0, 3)), shadowPaint);
    canvas.drawPath(
      botBoard,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [Color(0xFF7D3FE2), Color(0xFF5A22BA)],
        ).createShader(Rect.fromLTWH(w * 0.15, h * 0.62, w * 0.60, h * 0.20)),
    );
    canvas.drawLine(
      Offset(w * 0.28, h * 0.635),
      Offset(w * 0.71, h * 0.652),
      Paint()
        ..color = Colors.white.withAlpha(75)
        ..strokeWidth = 1.5
        ..strokeCap = StrokeCap.round,
    );

    // 6. Small grass mound & base shadow flush at bottom edge
    final mound = Path()
      ..moveTo(w * 0.16, h)
      ..quadraticBezierTo(w * 0.32, h * 0.89, w * 0.50, h * 0.92)
      ..quadraticBezierTo(w * 0.68, h * 0.88, w * 0.84, h)
      ..close();
    canvas.drawPath(
      mound,
      Paint()
        ..color = isDark ? const Color(0xFF3E5E4F) : const Color(0xFF7EA172),
    );
  }

  @override
  bool shouldRepaint(covariant _ExploreSignpostPainter oldDelegate) =>
      oldDelegate.isDark != isDark;
}
