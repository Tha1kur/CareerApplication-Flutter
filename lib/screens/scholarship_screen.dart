import 'dart:async';

import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

import '../core/constants/app_routes.dart';
import '../core/router/app_navigation.dart';
import '../core/theme/app_colors.dart';
import '../core/utils/external_link_helper.dart';
import '../models/scholarship.dart';
import '../providers/catalog_provider.dart';
import '../providers/quiz_gamification_provider.dart';
import '../providers/tracker_provider.dart';
import '../widgets/duotone_icons.dart';
import '../widgets/empty_state_view.dart';

/// Cohesive CareerGuide Lavender & White Scholarships screen:
/// - Secondary screen (no repeated CareerGuide top bar) starting with <- Scholarships
/// - Fixed duotone graduation cap & gold star medal hero artwork (zero floating, zero 3-line sparkles)
/// - Persisted pill search bar + violet category filter chips
/// - Reference-styled white cards with honest 2025 sample badge, bookmark toggle, Track & Apply Now
class ScholarshipScreen extends StatefulWidget {
  const ScholarshipScreen({super.key});

  @override
  State<ScholarshipScreen> createState() => _ScholarshipScreenState();
}

class _ScholarshipScreenState extends State<ScholarshipScreen> {
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    final initialQuery = context.read<CatalogProvider>().scholarshipSearchQuery;
    _searchController = TextEditingController(text: initialQuery);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      unawaited(
        context.read<QuizGamificationProvider>().markScholarshipsChecked(),
      );
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final catalog = context.watch<CatalogProvider>();
    final tracker = context.watch<TrackerProvider>();
    final items = catalog.filteredScholarships;
    final savedIds = catalog.savedScholarshipIds;
    final trackedIds = tracker.items.map((e) => e.scholarshipId).toSet();

    final scheme = Theme.of(context).colorScheme;
    final brightness = Theme.of(context).brightness;
    final isDark = brightness == Brightness.dark;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: CustomPaint(
              painter: _ScholarshipsBackdropPainter(isDark: isDark),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 6),

                // 1. Hero Header Row: Back arrow + "Scholarships" + Fixed Cap & Gold Medal Art
                SizedBox(
                  height: 112,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Positioned(
                        right: 6,
                        bottom: 0,
                        width: 152,
                        height: 108,
                        child: CustomPaint(
                          painter: _ScholarshipBlobPainter(isDark: isDark),
                        ),
                      ),
                      Positioned(
                        left: 14,
                        top: 10,
                        right: 132,
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
                                    'Scholarships',
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
                                'Find funding & financial aid\nopportunities for your studies.',
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
                        bottom: 6,
                        child: DuotoneFeatureIcon(
                          kind: DuotoneIconKind.scholarships,
                          size: 94,
                        ),
                      ),
                    ],
                  ),
                ),

                // 2. White Pill Search Bar + Quick Tracker Shortcut
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
                            onChanged: (value) => unawaited(
                              catalog.setScholarshipSearchQuery(value),
                            ),
                            textInputAction: TextInputAction.search,
                            style: TextStyle(
                              fontSize: 13.6,
                              color: scheme.onSurface,
                            ),
                            decoration: InputDecoration(
                              hintText: 'Search scholarships or eligibility...',
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
                              unawaited(catalog.setScholarshipSearchQuery(''));
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
                            onTap: () =>
                                context.push(AppRoutes.applicationTracker),
                            child: Tooltip(
                              message: 'Application Tracker',
                              child: SizedBox(
                                width: 34,
                                height: 34,
                                child: Icon(
                                  Icons.assignment_turned_in_rounded,
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

                // 3. Horizontal Violet Category Filter Pills
                SizedBox(
                  height: 36,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    itemCount: CatalogProvider.scholarshipCategories.length,
                    separatorBuilder: (_, _) => const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      final cat = CatalogProvider.scholarshipCategories[index];
                      final selected =
                          catalog.scholarshipCategoryFilter.toLowerCase() ==
                          cat.toLowerCase();
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
                          onTap: () => unawaited(
                            catalog.setScholarshipCategoryFilter(cat),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 15,
                              vertical: 8,
                            ),
                            child: Text(
                              cat,
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

                // 4. Scholarships Cards List
                Expanded(
                  child: !catalog.isLoaded
                      ? const Center(child: CircularProgressIndicator())
                      : items.isEmpty
                      ? EmptyStateView(
                          icon: Icons.search_off_rounded,
                          title: 'No scholarships match your filters',
                          subtitle:
                              'Try switching the category or clearing the search term.',
                          actionLabel: 'Reset Filters',
                          onAction: () {
                            _searchController.clear();
                            unawaited(catalog.setScholarshipSearchQuery(''));
                            unawaited(
                              catalog.setScholarshipCategoryFilter('All'),
                            );
                          },
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.fromLTRB(14, 0, 14, 16),
                          itemCount: items.length,
                          separatorBuilder: (_, _) =>
                              const SizedBox(height: 11),
                          itemBuilder: (context, index) {
                            final item = items[index];
                            final isTracked = trackedIds.contains(item.id);
                            return _ReferenceScholarshipCard(
                              item: item,
                              isSaved: savedIds.contains(item.id),
                              isTracked: isTracked,
                              onToggleBookmark: () => unawaited(
                                catalog.toggleSavedScholarship(item.id),
                              ),
                              onTrack: () async {
                                if (isTracked) {
                                  context.push(AppRoutes.applicationTracker);
                                  return;
                                }
                                await tracker.trackScholarship(item);
                                if (!context.mounted) return;
                                ScaffoldMessenger.of(context)
                                  ..hideCurrentSnackBar()
                                  ..showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'Added "${item.name}" to Application Tracker',
                                      ),
                                    ),
                                  );
                              },
                              onApply: () => unawaited(
                                launchExternalUrlSafely(
                                  context,
                                  item.applyLink ?? '',
                                ),
                              ),
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

class _ReferenceScholarshipCard extends StatelessWidget {
  const _ReferenceScholarshipCard({
    required this.item,
    required this.isSaved,
    required this.isTracked,
    required this.onToggleBookmark,
    required this.onTrack,
    required this.onApply,
  });

  final Scholarship item;
  final bool isSaved;
  final bool isTracked;
  final VoidCallback onToggleBookmark;
  final VoidCallback onTrack;
  final VoidCallback onApply;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final brightness = Theme.of(context).brightness;
    final isDark = brightness == Brightness.dark;
    final textTheme = Theme.of(context).textTheme;

    return Container(
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
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: isDark
                        ? scheme.primaryContainer
                        : const Color(0xFFF3ECFF),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    Icons.workspace_premium_rounded,
                    size: 25,
                    color: isDark ? scheme.primary : const Color(0xFF6B2FD0),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.name,
                        style: textTheme.titleSmall?.copyWith(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.2,
                          color: isDark
                              ? scheme.onSurface
                              : const Color(0xFF17122B),
                        ),
                      ),
                      const SizedBox(height: 5),
                      Wrap(
                        spacing: 6,
                        runSpacing: 4,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2.5,
                            ),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? scheme.primaryContainer
                                  : const Color(0xFFF0E8FF),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              item.category,
                              style: TextStyle(
                                fontSize: 10.8,
                                fontWeight: FontWeight.w700,
                                color: isDark
                                    ? scheme.primary
                                    : const Color(0xFF6B2FD0),
                              ),
                            ),
                          ),
                          if (item.isHistoricalSample)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2.5,
                              ),
                              decoration: BoxDecoration(
                                color: scheme.errorContainer,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                'Sample • Expired (2025)',
                                style: TextStyle(
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w700,
                                  color: scheme.onErrorContainer,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Tooltip(
                  message: isSaved ? 'Remove bookmark' : 'Save scholarship',
                  child: Material(
                    color: isSaved
                        ? (isDark ? scheme.primary : const Color(0xFF7433D6))
                        : (isDark
                              ? scheme.primaryContainer
                              : const Color(0xFFF3ECFF)),
                    borderRadius: BorderRadius.circular(12),
                    clipBehavior: Clip.antiAlias,
                    child: InkWell(
                      enableFeedback: false,
                      onTap: onToggleBookmark,
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
            const SizedBox(height: 11),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 8),
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xFF231C42)
                    : const Color(0xFFF7F3FF),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Icon(
                          Icons.payments_outlined,
                          size: 15,
                          color: isDark
                              ? scheme.primary
                              : const Color(0xFF6B2FD0),
                        ),
                        const SizedBox(width: 5),
                        Flexible(
                          child: Text(
                            item.amount ?? 'Amount varies',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
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
                  ),
                  const SizedBox(width: 8),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.event_outlined,
                        size: 14,
                        color: item.isHistoricalSample
                            ? scheme.error
                            : scheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        item.deadline ?? 'Rolling',
                        style: TextStyle(
                          fontSize: 11.6,
                          fontWeight: FontWeight.w600,
                          color: item.isHistoricalSample
                              ? scheme.error
                              : scheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if ((item.eligibility ?? '').isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                'Eligibility: ${item.eligibility}',
                style: textTheme.bodySmall?.copyWith(
                  fontSize: 12.2,
                  color: scheme.onSurface,
                ),
              ),
            ],
            if ((item.description ?? '').isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                item.description!,
                style: textTheme.bodySmall?.copyWith(
                  color: scheme.onSurfaceVariant,
                  fontSize: 12,
                  height: 1.35,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 42,
                    child: OutlinedButton.icon(
                      onPressed: onTrack,
                      style: OutlinedButton.styleFrom(
                        enableFeedback: false,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(13),
                        ),
                      ),
                      icon: Icon(
                        isTracked
                            ? Icons.check_circle_outline_rounded
                            : Icons.add_task_rounded,
                        size: 16,
                      ),
                      label: Text(
                        isTracked ? 'In Tracker' : 'Track',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Container(
                    height: 42,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(13),
                      gradient: const LinearGradient(
                        colors: [Color(0xFF5D26C6), Color(0xFF8344E4)],
                      ),
                    ),
                    child: Material(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(13),
                      clipBehavior: Clip.antiAlias,
                      child: InkWell(
                        enableFeedback: false,
                        onTap: onApply,
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Apply Now',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            SizedBox(width: 5),
                            Icon(
                              Icons.open_in_new_rounded,
                              color: Colors.white,
                              size: 15,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ScholarshipsBackdropPainter extends CustomPainter {
  const _ScholarshipsBackdropPainter({required this.isDark});

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
  bool shouldRepaint(covariant _ScholarshipsBackdropPainter oldDelegate) =>
      oldDelegate.isDark != isDark;
}

class _ScholarshipBlobPainter extends CustomPainter {
  const _ScholarshipBlobPainter({required this.isDark});

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
  bool shouldRepaint(covariant _ScholarshipBlobPainter oldDelegate) =>
      oldDelegate.isDark != isDark;
}
