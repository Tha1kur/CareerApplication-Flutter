import 'dart:async';

import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

import '../core/constants/app_routes.dart';
import '../core/router/app_navigation.dart';
import '../core/theme/app_colors.dart';
import '../core/utils/external_link_helper.dart';
import '../providers/catalog_provider.dart';
import '../widgets/empty_state_view.dart';

/// Cohesive CareerGuide Lavender & White College Details screen:
/// - Secondary screen (no repeated brand top bar) with <- back, Compare & Bookmark circles
/// - Rich violet institution hero card + floating white stats, About, Courses & Focus Tags cards
class CollegeDetailsScreen extends StatelessWidget {
  const CollegeDetailsScreen({super.key, required this.collegeId});

  final String collegeId;

  @override
  Widget build(BuildContext context) {
    final catalog = context.watch<CatalogProvider>();
    final college = catalog.collegeById(collegeId);
    final isSaved = catalog.savedCollegeIds.contains(collegeId);
    final scheme = Theme.of(context).colorScheme;
    final brightness = Theme.of(context).brightness;
    final isDark = brightness == Brightness.dark;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: CustomPaint(
              painter: _DetailsBackdropPainter(isDark: isDark),
            ),
          ),
          SafeArea(
            child: Column(
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
                          onTap: () =>
                              context.safePop(fallback: AppRoutes.colleges),
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
                          'College Details',
                          style: textTheme.headlineSmall?.copyWith(
                            fontSize: 21.5,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.4,
                            color: isDark
                                ? scheme.onSurface
                                : const Color(0xFF17122B),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (college != null) ...[
                        _HeaderActionTile(
                          tooltip: 'Compare this college',
                          icon: Icons.compare_arrows_rounded,
                          onTap: () => context.push(
                            AppRoutes.compareWithIds([college.id]),
                          ),
                        ),
                        const SizedBox(width: 8),
                        _HeaderActionTile(
                          tooltip: isSaved ? 'Remove bookmark' : 'Bookmark',
                          icon: isSaved
                              ? Icons.bookmark_rounded
                              : Icons.bookmark_border_rounded,
                          active: isSaved,
                          onTap: () =>
                              unawaited(catalog.toggleSavedCollege(college.id)),
                        ),
                      ],
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                // 2. Body
                Expanded(
                  child: !catalog.isLoaded
                      ? const Center(child: CircularProgressIndicator())
                      : college == null
                      ? EmptyStateView(
                          icon: Icons.school_outlined,
                          title: 'College not found',
                          subtitle:
                              'We could not find an institution matching ID "$collegeId".',
                          actionLabel: 'Browse Colleges',
                          onAction: () =>
                              context.safePop(fallback: AppRoutes.colleges),
                        )
                      : ListView(
                          padding: const EdgeInsets.fromLTRB(14, 0, 14, 24),
                          children: [
                            // Rich Violet Institution Hero Card
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
                                    color: const Color(0xFF6B2FD0)
                                        .withAlpha(isDark ? 70 : 58),
                                    blurRadius: 20,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      if (college.rank != null)
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 10,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                          child: Text(
                                            'Rank #${college.rank}',
                                            style: const TextStyle(
                                              color: Color(0xFF6729CC),
                                              fontSize: 11.5,
                                              fontWeight: FontWeight.w800,
                                            ),
                                          ),
                                        ),
                                      if ((college.type ?? '').isNotEmpty) ...[
                                        const SizedBox(width: 8),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 10,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.white.withAlpha(42),
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                          child: Text(
                                            college.type!,
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 11.5,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    college.name,
                                    style: textTheme.headlineSmall?.copyWith(
                                      color: Colors.white,
                                      fontSize: 20.5,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: -0.3,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.location_on_outlined,
                                        size: 15,
                                        color: Colors.white,
                                      ),
                                      const SizedBox(width: 4),
                                      Expanded(
                                        child: Text(
                                          college.formattedLocation,
                                          style: TextStyle(
                                            color: Colors.white.withAlpha(235),
                                            fontSize: 13.2,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 14),

                            // Key Facts White Card
                            Container(
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
                                children: [
                                  _DetailRow(
                                    label: 'NIRF / Catalog Rank',
                                    value: college.rank != null
                                        ? '#${college.rank}'
                                        : 'N/A',
                                  ),
                                  Divider(
                                    height: 20,
                                    color: scheme.outlineVariant.withAlpha(140),
                                  ),
                                  _DetailRow(
                                    label: 'Intake Level',
                                    value: college.intake ?? 'N/A',
                                  ),
                                  Divider(
                                    height: 20,
                                    color: scheme.outlineVariant.withAlpha(140),
                                  ),
                                  _DetailRow(
                                    label: 'Average Fees',
                                    value: college.avgFees ?? 'N/A',
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 12),

                            // About & Focus Tags White Card
                            Container(
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
                                    'About',
                                    style: textTheme.titleMedium?.copyWith(
                                      fontSize: 15.5,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    college.description ??
                                        'No description provided.',
                                    style: textTheme.bodyMedium?.copyWith(
                                      color: scheme.onSurfaceVariant,
                                      height: 1.42,
                                    ),
                                  ),
                                  if (college.courses.isNotEmpty) ...[
                                    const SizedBox(height: 14),
                                    Text(
                                      'Programs Offered',
                                      style: textTheme.titleSmall?.copyWith(
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Wrap(
                                      spacing: 7,
                                      runSpacing: 7,
                                      children: college.courses
                                          .map(
                                            (course) => Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 10,
                                                    vertical: 5,
                                                  ),
                                              decoration: BoxDecoration(
                                                color: isDark
                                                    ? scheme.primaryContainer
                                                    : const Color(0xFFF0E8FF),
                                                borderRadius:
                                                    BorderRadius.circular(14),
                                              ),
                                              child: Text(
                                                course,
                                                style: TextStyle(
                                                  fontSize: 11.8,
                                                  fontWeight: FontWeight.w700,
                                                  color: isDark
                                                      ? scheme.primary
                                                      : const Color(0xFF5D26C6),
                                                ),
                                              ),
                                            ),
                                          )
                                          .toList(),
                                    ),
                                  ],
                                  if (college.tags.isNotEmpty) ...[
                                    const SizedBox(height: 14),
                                    Text(
                                      'Focus Areas & Tags',
                                      style: textTheme.titleSmall?.copyWith(
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Wrap(
                                      spacing: 7,
                                      runSpacing: 7,
                                      children: college.tags
                                          .map(
                                            (tag) => Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 10,
                                                    vertical: 5,
                                                  ),
                                              decoration: BoxDecoration(
                                                color: scheme
                                                    .surfaceContainerHighest,
                                                borderRadius:
                                                    BorderRadius.circular(14),
                                              ),
                                              child: Text(
                                                tag,
                                                style: TextStyle(
                                                  fontSize: 11.8,
                                                  fontWeight: FontWeight.w600,
                                                  color: scheme.onSurface,
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

                            SizedBox(
                              width: double.infinity,
                              height: 48,
                              child: OutlinedButton.icon(
                                icon: const Icon(Icons.compare_arrows_rounded),
                                label: const Text(
                                  'Compare this College',
                                  style: TextStyle(fontWeight: FontWeight.w700),
                                ),
                                style: OutlinedButton.styleFrom(
                                  enableFeedback: false,
                                  backgroundColor: scheme.surface,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                                onPressed: () => context.push(
                                  AppRoutes.compareWithIds([college.id]),
                                ),
                              ),
                            ),
                            if ((college.website ?? '').isNotEmpty) ...[
                              const SizedBox(height: 10),
                              Container(
                                width: double.infinity,
                                height: 50,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(16),
                                  gradient: const LinearGradient(
                                    colors: [
                                      Color(0xFF5D26C6),
                                      Color(0xFF8344E4),
                                    ],
                                  ),
                                ),
                                child: Material(
                                  color: Colors.transparent,
                                  borderRadius: BorderRadius.circular(16),
                                  clipBehavior: Clip.antiAlias,
                                  child: InkWell(
                                    enableFeedback: false,
                                    onTap: () => unawaited(
                                      launchExternalUrlSafely(
                                        context,
                                        college.website!,
                                      ),
                                    ),
                                    child: const Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.open_in_new_rounded,
                                          color: Colors.white,
                                          size: 18,
                                        ),
                                        SizedBox(width: 8),
                                        Text(
                                          'Visit Website / Apply',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 15,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
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

class _HeaderActionTile extends StatelessWidget {
  const _HeaderActionTile({
    required this.tooltip,
    required this.icon,
    required this.onTap,
    this.active = false,
  });

  final String tooltip;
  final IconData icon;
  final VoidCallback onTap;
  final bool active;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Tooltip(
      message: tooltip,
      child: Material(
        color: active
            ? (isDark ? scheme.primary : const Color(0xFF7433D6))
            : (isDark ? scheme.primaryContainer : const Color(0xFFF0E8FF)),
        borderRadius: BorderRadius.circular(12),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          enableFeedback: false,
          onTap: onTap,
          child: SizedBox(
            width: 38,
            height: 38,
            child: Icon(
              icon,
              size: 20,
              color: active
                  ? Colors.white
                  : (isDark ? scheme.primary : const Color(0xFF6B2FD0)),
            ),
          ),
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: textTheme.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
        ),
        Text(
          value,
          style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
        ),
      ],
    );
  }
}

class _DetailsBackdropPainter extends CustomPainter {
  const _DetailsBackdropPainter({required this.isDark});

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
  bool shouldRepaint(covariant _DetailsBackdropPainter oldDelegate) =>
      oldDelegate.isDark != isDark;
}
