import 'dart:async';

import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

import '../core/constants/app_routes.dart';
import '../core/router/app_navigation.dart';
import '../core/theme/app_colors.dart';
import '../models/college.dart';
import '../providers/catalog_provider.dart';
import '../providers/quiz_gamification_provider.dart';
import '../widgets/empty_state_view.dart';

/// Exact reference CareerGuide Colleges screen (PDF Page 7):
/// - No repeated brand top bar (secondary screen starts cleanly with <- Colleges)
/// - Fixed classical campus illustration with golden flag & shrubs (zero 3-line sparkles, zero float)
/// - Persisted pill search bar + violet stream filter pills
/// - Reference-styled white college cards with emblem tile, city | courses meta, bookmark toggle,
///   and compare up to 3 colleges bar (zero tap click sounds).
class CollegesScreen extends StatefulWidget {
  const CollegesScreen({super.key});

  @override
  State<CollegesScreen> createState() => _CollegesScreenState();
}

class _CollegesScreenState extends State<CollegesScreen> {
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    final initialQuery = context.read<CatalogProvider>().collegeSearchQuery;
    _searchController = TextEditingController(text: initialQuery);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      unawaited(
        context.read<QuizGamificationProvider>().markCollegesExplored(),
      );
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String _shortCodeFor(College college) {
    final id = college.id.toLowerCase();
    if (id.contains('iitb')) return 'IITB';
    if (id.contains('iitk')) return 'IITK';
    if (id.contains('nid')) return 'NID';
    if (id.contains('iim')) return 'IIMA';
    final words = college.name
        .split(RegExp(r'\s+'))
        .where((w) => w.isNotEmpty)
        .toList();
    if (words.length >= 2) {
      return words.take(3).map((w) => w[0].toUpperCase()).join();
    }
    return college.name.isNotEmpty ? college.name[0].toUpperCase() : 'C';
  }

  @override
  Widget build(BuildContext context) {
    final catalog = context.watch<CatalogProvider>();
    final items = catalog.filteredColleges;
    final savedIds = catalog.savedCollegeIds;
    final compareIds = catalog.compareCollegeIds;
    final scheme = Theme.of(context).colorScheme;
    final brightness = Theme.of(context).brightness;
    final isDark = brightness == Brightness.dark;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      bottomNavigationBar: compareIds.isEmpty
          ? null
          : SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(14, 4, 14, 10),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: scheme.surface,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: scheme.outlineVariant.withAlpha(180),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.cardShadow(brightness),
                        blurRadius: 18,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Compare (${compareIds.length}/3 selected)',
                          style: textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                            fontSize: 13.5,
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: catalog.clearCompareSelection,
                        child: const Text('Clear'),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(14),
                          gradient: const LinearGradient(
                            colors: [Color(0xFF5D26C6), Color(0xFF8344E4)],
                          ),
                        ),
                        child: Material(
                          color: Colors.transparent,
                          borderRadius: BorderRadius.circular(14),
                          clipBehavior: Clip.antiAlias,
                          child: InkWell(
                            enableFeedback: false,
                            onTap: () => context.push(
                              AppRoutes.compareWithIds(compareIds),
                            ),
                            child: const Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 9,
                              ),
                              child: Text(
                                'Compare Now',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12.8,
                                  fontWeight: FontWeight.w700,
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
            ),
      body: Stack(
        children: [
          Positioned.fill(
            child: CustomPaint(
              painter: _CollegesBackdropPainter(isDark: isDark),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 6),

                // 1. Hero Header Row: Back arrow + "Colleges" + Fixed Campus Illustration
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
                          painter: _CampusBlobPainter(isDark: isDark),
                        ),
                      ),
                      Positioned(
                        left: 14,
                        top: 10,
                        right: 138,
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
                                    'Colleges',
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
                                'Explore, compare and find\ncolleges that match your goals.',
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
                      Positioned(
                        right: 14,
                        bottom: 0,
                        width: 124,
                        height: 106,
                        child: CustomPaint(
                          painter: _CampusBuildingArtPainter(isDark: isDark),
                        ),
                      ),
                    ],
                  ),
                ),

                // 2. White Pill Search Bar + Quick Compare Action
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
                                unawaited(catalog.setCollegeSearchQuery(value)),
                            textInputAction: TextInputAction.search,
                            style: TextStyle(
                              fontSize: 13.6,
                              color: scheme.onSurface,
                            ),
                            decoration: InputDecoration(
                              hintText: 'Search colleges, courses...',
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
                        if (_searchController.text.isNotEmpty)
                          GestureDetector(
                            onTap: () {
                              _searchController.clear();
                              unawaited(catalog.setCollegeSearchQuery(''));
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
                            onTap: () => context.push(
                              AppRoutes.compareWithIds(compareIds),
                            ),
                            child: Tooltip(
                              message: 'Compare Colleges',
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
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 11),

                // 3. Horizontal Violet Filter Pills
                SizedBox(
                  height: 36,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    itemCount: CatalogProvider.collegeStreamFilters.length,
                    separatorBuilder: (_, _) => const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      final filter =
                          CatalogProvider.collegeStreamFilters[index];
                      final selected =
                          catalog.collegeTypeFilter.toLowerCase() ==
                          filter.toLowerCase();
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
                          onTap: () =>
                              unawaited(catalog.setCollegeTypeFilter(filter)),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 15,
                              vertical: 8,
                            ),
                            child: Text(
                              filter,
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

                // 4. Reference White Rounded College Cards List
                Expanded(
                  child: !catalog.isLoaded
                      ? const Center(child: CircularProgressIndicator())
                      : catalog.error != null
                      ? EmptyStateView(
                          icon: Icons.error_outline_rounded,
                          title: 'Could not load colleges',
                          subtitle: catalog.error!,
                        )
                      : items.isEmpty
                      ? EmptyStateView(
                          icon: Icons.search_off_rounded,
                          title: 'No colleges match your filters',
                          subtitle: 'Try changing the stream filter or clearing your search query.',
                          actionLabel: 'Reset Filters',
                          onAction: () {
                            _searchController.clear();
                            unawaited(catalog.setCollegeSearchQuery(''));
                            unawaited(catalog.setCollegeTypeFilter('All'));
                          },
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.fromLTRB(14, 0, 14, 16),
                          itemCount: items.length,
                          separatorBuilder: (_, _) =>
                              const SizedBox(height: 11),
                          itemBuilder: (context, index) {
                            final college = items[index];
                            return _ReferenceCollegeCard(
                              college: college,
                              code: _shortCodeFor(college),
                              isSaved: savedIds.contains(college.id),
                              isCompared: compareIds.contains(college.id),
                              onTap: () => context.push(
                                AppRoutes.collegeDetails(college.id),
                              ),
                              onToggleSave: () => unawaited(
                                catalog.toggleSavedCollege(college.id),
                              ),
                              onToggleCompare: () {
                                final ok = catalog.toggleCompareCollege(
                                  college.id,
                                );
                                if (!ok) {
                                  ScaffoldMessenger.of(context)
                                    ..hideCurrentSnackBar()
                                    ..showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'You can compare up to 3 colleges at a time.',
                                        ),
                                      ),
                                    );
                                }
                              },
                            );
                          },
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

class _ReferenceCollegeCard extends StatelessWidget {
  const _ReferenceCollegeCard({
    required this.college,
    required this.code,
    required this.isSaved,
    required this.isCompared,
    required this.onTap,
    required this.onToggleSave,
    required this.onToggleCompare,
  });

  final College college;
  final String code;
  final bool isSaved;
  final bool isCompared;
  final VoidCallback onTap;
  final VoidCallback onToggleSave;
  final VoidCallback onToggleCompare;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final brightness = Theme.of(context).brightness;
    final isDark = brightness == Brightness.dark;
    final textTheme = Theme.of(context).textTheme;

    final cityText = (college.city ?? '').trim().isNotEmpty
        ? college.city!.trim()
        : college.formattedLocation;
    final coursesPreview = college.courses.isNotEmpty
        ? college.courses.take(2).join(', ')
        : (college.type ?? 'Higher Education');

    return Container(
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: isCompared
              ? (isDark ? scheme.primary : const Color(0xFF7433D6))
              : scheme.outlineVariant.withAlpha(175),
          width: isCompared ? 1.5 : 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.cardShadow(brightness),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(22),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          enableFeedback: false,
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(13, 13, 13, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    // Reference-style Institute Crest / Monogram Badge
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: isDark
                            ? scheme.primaryContainer
                            : const Color(0xFFF5F0FF),
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(
                          color: isDark
                              ? scheme.outlineVariant
                              : const Color(0xFFE6DCFE),
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.account_balance_rounded,
                            size: 18,
                            color: isDark
                                ? scheme.primary
                                : const Color(0xFF6B2FD0),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            code,
                            style: TextStyle(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.2,
                              color: isDark
                                  ? scheme.onPrimaryContainer
                                  : const Color(0xFF3E1D8A),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            college.name,
                            style: textTheme.titleSmall?.copyWith(
                              fontSize: 14.8,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.2,
                              color: isDark
                                  ? scheme.onSurface
                                  : const Color(0xFF17122B),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 5),
                          // Exact reference meta row: location | degree icon + courses
                          Row(
                            children: [
                              Icon(
                                Icons.location_on_outlined,
                                size: 13.5,
                                color: isDark
                                    ? scheme.onSurfaceVariant
                                    : const Color(0xFF6B6584),
                              ),
                              const SizedBox(width: 3),
                              Flexible(
                                flex: 2,
                                child: Text(
                                  cityText,
                                  style: TextStyle(
                                    fontSize: 11.8,
                                    color: isDark
                                        ? scheme.onSurfaceVariant
                                        : const Color(0xFF5A5472),
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                ),
                                child: Text(
                                  '|',
                                  style: TextStyle(
                                    fontSize: 11.5,
                                    color: scheme.outlineVariant,
                                  ),
                                ),
                              ),
                              Icon(
                                Icons.school_outlined,
                                size: 13.5,
                                color: isDark
                                    ? scheme.onSurfaceVariant
                                    : const Color(0xFF6B6584),
                              ),
                              const SizedBox(width: 3),
                              Flexible(
                                flex: 3,
                                child: Text(
                                  coursesPreview,
                                  style: TextStyle(
                                    fontSize: 11.8,
                                    color: isDark
                                        ? scheme.onSurfaceVariant
                                        : const Color(0xFF5A5472),
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Exact reference soft-lavender rounded Bookmark button
                    Tooltip(
                      message: isSaved ? 'Remove bookmark' : 'Bookmark',
                      child: Material(
                        color: isSaved
                            ? (isDark
                                  ? scheme.primary
                                  : const Color(0xFF7433D6))
                            : (isDark
                                  ? scheme.primaryContainer
                                  : const Color(0xFFF3ECFF)),
                        borderRadius: BorderRadius.circular(12),
                        clipBehavior: Clip.antiAlias,
                        child: InkWell(
                          enableFeedback: false,
                          onTap: onToggleSave,
                          child: SizedBox(
                            width: 38,
                            height: 38,
                            child: Icon(
                              isSaved
                                  ? Icons.bookmark_rounded
                                  : Icons.bookmark_border_rounded,
                              size: 20,
                              color: isSaved
                                  ? Colors.white
                                  : (isDark
                                        ? scheme.primary
                                        : const Color(0xFF7433D6)),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                // Compact Footer Row: Rank + Avg Fees + Compare Toggle Pill
                Row(
                  children: [
                    if (college.rank != null) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: isDark
                              ? scheme.surfaceContainerHighest
                              : const Color(0xFFF4EEFF),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          'Rank #${college.rank}',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: isDark
                                ? scheme.primary
                                : const Color(0xFF5D26C6),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                    ],
                    if ((college.avgFees ?? '').isNotEmpty)
                      Expanded(
                        child: Text(
                          'Fees: ${college.avgFees}',
                          style: TextStyle(
                            fontSize: 11.4,
                            color: scheme.onSurfaceVariant,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      )
                    else
                      const Spacer(),
                    Material(
                      color: isCompared
                          ? (isDark
                                ? scheme.primaryContainer
                                : const Color(0xFFEDE2FF))
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(10),
                      clipBehavior: Clip.antiAlias,
                      child: InkWell(
                        enableFeedback: false,
                        onTap: onToggleCompare,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 9,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: isCompared
                                  ? (isDark
                                        ? scheme.primary
                                        : const Color(0xFF7433D6))
                                  : scheme.outlineVariant,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                isCompared
                                    ? Icons.check_rounded
                                    : Icons.compare_arrows_rounded,
                                size: 13.5,
                                color: isCompared
                                    ? (isDark
                                          ? scheme.primary
                                          : const Color(0xFF6B2FD0))
                                    : scheme.onSurfaceVariant,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                isCompared ? 'Comparing' : 'Compare',
                                style: TextStyle(
                                  fontSize: 11.2,
                                  fontWeight: FontWeight.w700,
                                  color: isCompared
                                      ? (isDark
                                            ? scheme.primary
                                            : const Color(0xFF6B2FD0))
                                      : scheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CollegesBackdropPainter extends CustomPainter {
  const _CollegesBackdropPainter({required this.isDark});

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
  bool shouldRepaint(covariant _CollegesBackdropPainter oldDelegate) =>
      oldDelegate.isDark != isDark;
}

class _CampusBlobPainter extends CustomPainter {
  const _CampusBlobPainter({required this.isDark});

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
  bool shouldRepaint(covariant _CampusBlobPainter oldDelegate) =>
      oldDelegate.isDark != isDark;
}

/// Exact reference classical campus building with golden flag & side foliage (PDF Page 7, zero 3-line sparkles).
class _CampusBuildingArtPainter extends CustomPainter {
  const _CampusBuildingArtPainter({required this.isDark});

  final bool isDark;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final primary = isDark ? AppColors.darkPrimary : const Color(0xFF7B4BE0);
    final deep = isDark ? const Color(0xFF9F7AEA) : const Color(0xFF5320B0);
    final soft = isDark ? const Color(0xFF282046) : const Color(0xFFF3ECFF);
    final mid = isDark ? const Color(0xFF5B3FA6) : const Color(0xFFC5AFFB);

    // Flagpole & golden waving flag
    canvas.drawLine(
      Offset(w * 0.50, h * 0.08),
      Offset(w * 0.50, h * 0.28),
      Paint()
        ..color = deep
        ..strokeWidth = 2.2
        ..strokeCap = StrokeCap.round,
    );
    final flag = Path()
      ..moveTo(w * 0.50, h * 0.09)
      ..quadraticBezierTo(w * 0.60, h * 0.06, w * 0.69, h * 0.12)
      ..lineTo(w * 0.67, h * 0.21)
      ..quadraticBezierTo(w * 0.58, h * 0.17, w * 0.50, h * 0.21)
      ..close();
    canvas.drawPath(flag, Paint()..color = const Color(0xFFF59E0B));

    // Left & right green shrubs (matching PDF Page 7 reference!)
    final shrubDark = Paint()
      ..color = isDark ? const Color(0xFF2E593F) : const Color(0xFF4D7C3C);
    final shrubLight = Paint()
      ..color = isDark ? const Color(0xFF3E7554) : const Color(0xFF6FA34B);
    canvas.drawCircle(Offset(w * 0.13, h * 0.87), w * 0.09, shrubDark);
    canvas.drawCircle(Offset(w * 0.19, h * 0.84), w * 0.075, shrubLight);
    canvas.drawCircle(Offset(w * 0.87, h * 0.87), w * 0.09, shrubDark);
    canvas.drawCircle(Offset(w * 0.81, h * 0.84), w * 0.075, shrubLight);

    // Building main body
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.22, h * 0.48, w * 0.56, h * 0.42),
        const Radius.circular(4),
      ),
      Paint()..color = soft,
    );

    // Classical triangular pediment roof with gradient
    final roof = Path()
      ..moveTo(w * 0.14, h * 0.49)
      ..lineTo(w * 0.50, h * 0.25)
      ..lineTo(w * 0.86, h * 0.49)
      ..close();
    canvas.drawPath(
      roof,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [primary, deep],
        ).createShader(Rect.fromLTWH(w * 0.14, h * 0.25, w * 0.72, h * 0.25)),
    );
    // White inner pediment accent + circular emblem
    final innerPediment = Path()
      ..moveTo(w * 0.28, h * 0.45)
      ..lineTo(w * 0.50, h * 0.31)
      ..lineTo(w * 0.72, h * 0.45)
      ..close();
    canvas.drawPath(innerPediment, Paint()..color = soft);
    canvas.drawCircle(
      Offset(w * 0.50, h * 0.39),
      w * 0.032,
      Paint()..color = primary,
    );

    // Cornice ledge
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.17, h * 0.47, w * 0.66, h * 0.055),
        const Radius.circular(3),
      ),
      Paint()..color = mid,
    );

    // 4 classical pillars
    final pillarPaint = Paint()..color = primary;
    for (final px in [0.25, 0.35, 0.59, 0.69]) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(w * px, h * 0.53, w * 0.062, h * 0.34),
          const Radius.circular(3),
        ),
        pillarPaint,
      );
    }

    // Central arched doorway
    canvas.drawRRect(
      RRect.fromRectAndCorners(
        Rect.fromLTWH(w * 0.44, h * 0.61, w * 0.12, h * 0.27),
        topLeft: const Radius.circular(12),
        topRight: const Radius.circular(12),
      ),
      Paint()..color = deep,
    );

    // Stepped plinth base flush at bottom
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.18, h * 0.86, w * 0.64, h * 0.07),
        const Radius.circular(3),
      ),
      Paint()..color = mid,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.12, h * 0.92, w * 0.76, h * 0.08),
        const Radius.circular(4),
      ),
      Paint()..color = primary.withAlpha(200),
    );
  }

  @override
  bool shouldRepaint(covariant _CampusBuildingArtPainter oldDelegate) =>
      oldDelegate.isDark != isDark;
}
