import 'dart:async';

import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

import '../core/constants/app_routes.dart';
import '../core/router/app_navigation.dart';
import '../core/theme/app_colors.dart';
import '../core/utils/external_link_helper.dart';
import '../models/college.dart';
import '../providers/catalog_provider.dart';
import '../repositories/college_repository.dart';
import '../widgets/empty_state_view.dart';

/// Cohesive CareerGuide Lavender & White College Comparison screen:
/// - Secondary screen (no repeated brand top bar) starting with <- Compare Colleges
/// - Side-by-side floating white comparison cards (up to 3) + Comparison Insights card
class CollegeComparisonScreen extends StatefulWidget {
  const CollegeComparisonScreen({super.key, this.initialIds = const []});

  final List<String> initialIds;

  @override
  State<CollegeComparisonScreen> createState() =>
      _CollegeComparisonScreenState();
}

class _CollegeComparisonScreenState extends State<CollegeComparisonScreen> {
  List<String> _selectedIds = const [];
  bool _initialized = false;

  void _syncInitialSelection(List<College> allColleges) {
    if (_initialized || allColleges.isEmpty) return;
    _initialized = true;
    final validInitial = widget.initialIds
        .where((id) => allColleges.any((c) => c.id == id))
        .toSet()
        .take(CollegeRepository.maxCompareSelection)
        .toList();

    if (validInitial.isNotEmpty) {
      _selectedIds = validInitial;
    } else if (allColleges.length >= 2) {
      _selectedIds = allColleges.take(2).map((c) => c.id).toList();
    } else {
      _selectedIds = allColleges.map((c) => c.id).toList();
    }
  }

  Future<void> _showAddCollegeSheet(List<College> allColleges) async {
    final available = allColleges
        .where((c) => !_selectedIds.contains(c.id))
        .toList(growable: false);
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      backgroundColor: scheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: Text(
                    'Add College to Compare',
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                if (available.isEmpty)
                  Padding(
                    padding: const EdgeInsets.all(10),
                    child: Text(
                      'All available colleges are already added.',
                      style: textTheme.bodyMedium?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  )
                else
                  Flexible(
                    child: ListView.separated(
                      shrinkWrap: true,
                      itemCount: available.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final col = available[index];
                        return Material(
                          color: scheme.surfaceContainerHighest.withAlpha(140),
                          borderRadius: BorderRadius.circular(16),
                          clipBehavior: Clip.antiAlias,
                          child: ListTile(
                            enableFeedback: false,
                            title: Text(
                              col.name,
                              style: textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            subtitle: Text(col.formattedLocation),
                            trailing: Icon(
                              Icons.add_circle_rounded,
                              color: scheme.primary,
                            ),
                            onTap: () {
                              setState(() {
                                if (_selectedIds.length <
                                    CollegeRepository.maxCompareSelection) {
                                  _selectedIds = [..._selectedIds, col.id];
                                }
                              });
                              Navigator.of(sheetContext).pop();
                            },
                          ),
                        );
                      },
                    ),
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
    final catalog = context.watch<CatalogProvider>();
    final allColleges = catalog.allColleges;
    _syncInitialSelection(allColleges);

    final selectedColleges = _selectedIds
        .map((id) => catalog.collegeById(id))
        .whereType<College>()
        .toList(growable: false);
    final insights = CollegeRepository.computeComparisonInsights(
      selectedColleges,
    );
    final scheme = Theme.of(context).colorScheme;
    final brightness = Theme.of(context).brightness;
    final isDark = brightness == Brightness.dark;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: CustomPaint(
              painter: _CompareBackdropPainter(isDark: isDark),
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
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Compare Colleges',
                              style: textTheme.headlineSmall?.copyWith(
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.4,
                                color: isDark
                                    ? scheme.onSurface
                                    : const Color(0xFF17122B),
                              ),
                            ),
                            Text(
                              '${selectedColleges.length} of ${CollegeRepository.maxCompareSelection} selected',
                              style: textTheme.bodySmall?.copyWith(
                                color: scheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (selectedColleges.length <
                              CollegeRepository.maxCompareSelection &&
                          allColleges.isNotEmpty)
                        Material(
                          color: isDark
                              ? scheme.primaryContainer
                              : const Color(0xFFF0E8FF),
                          borderRadius: BorderRadius.circular(12),
                          clipBehavior: Clip.antiAlias,
                          child: InkWell(
                            enableFeedback: false,
                            onTap: () => _showAddCollegeSheet(allColleges),
                            child: Tooltip(
                              message: 'Add college to compare',
                              child: SizedBox(
                                width: 38,
                                height: 38,
                                child: Icon(
                                  Icons.add_rounded,
                                  color: isDark
                                      ? scheme.primary
                                      : const Color(0xFF6B2FD0),
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                // 2. Body
                Expanded(
                  child: !catalog.isLoaded
                      ? const Center(child: CircularProgressIndicator())
                      : selectedColleges.isEmpty
                      ? EmptyStateView(
                          icon: Icons.compare_arrows_rounded,
                          title: 'No colleges selected for comparison',
                          subtitle:
                              'Select up to 3 institutions to compare rank, fees, intake, and focus areas side by side.',
                          actionLabel: 'Select Colleges',
                          onAction: () => _showAddCollegeSheet(allColleges),
                        )
                      : ListView(
                          padding: const EdgeInsets.fromLTRB(14, 0, 14, 24),
                          children: [
                            if (selectedColleges.length <
                                CollegeRepository.maxCompareSelection) ...[
                              FilledButton.tonalIcon(
                                icon: const Icon(Icons.add_rounded),
                                label: Text(
                                  'Add another college to compare (${selectedColleges.length}/3)',
                                ),
                                style: FilledButton.styleFrom(
                                  enableFeedback: false,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                                onPressed: () =>
                                    _showAddCollegeSheet(allColleges),
                              ),
                              const SizedBox(height: 12),
                            ],
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  for (
                                    var i = 0;
                                    i < selectedColleges.length;
                                    i++
                                  ) ...[
                                    _ComparisonColumnCard(
                                      college: selectedColleges[i],
                                      onRemove: () {
                                        setState(() {
                                          _selectedIds = _selectedIds
                                              .where(
                                                (id) =>
                                                    id !=
                                                    selectedColleges[i].id,
                                              )
                                              .toList();
                                        });
                                      },
                                      onViewDetails: () => context.push(
                                        AppRoutes.collegeDetails(
                                          selectedColleges[i].id,
                                        ),
                                      ),
                                      onVisitWebsite: () {
                                        final url =
                                            selectedColleges[i].website;
                                        if (url != null && url.isNotEmpty) {
                                          unawaited(
                                            launchExternalUrlSafely(
                                              context,
                                              url,
                                            ),
                                          );
                                        }
                                      },
                                    ),
                                    if (i < selectedColleges.length - 1)
                                      const SizedBox(width: 12),
                                  ],
                                ],
                              ),
                            ),
                            const SizedBox(height: 14),
                            Container(
                              padding: const EdgeInsets.all(16),
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
                                    'Comparison Insights',
                                    style: textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  if (insights.bestRankedCollege != null)
                                    Text(
                                      'Best National Rank: ${insights.bestRankedCollege!.name} (Rank #${insights.bestRankedCollege!.rank})',
                                      style: textTheme.bodyMedium,
                                    ),
                                  if (insights.categories.isNotEmpty) ...[
                                    const SizedBox(height: 6),
                                    Text(
                                      'Institute Categories: ${insights.categories.join(', ')}',
                                      style: textTheme.bodyMedium,
                                    ),
                                  ],
                                  if (insights.cities.isNotEmpty) ...[
                                    const SizedBox(height: 6),
                                    Text(
                                      'Hub Locations: ${insights.cities.join(', ')}',
                                      style: textTheme.bodyMedium,
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
          ),
        ],
      ),
    );
  }
}

class _ComparisonColumnCard extends StatelessWidget {
  const _ComparisonColumnCard({
    required this.college,
    required this.onRemove,
    required this.onViewDetails,
    required this.onVisitWebsite,
  });

  final College college;
  final VoidCallback onRemove;
  final VoidCallback onViewDetails;
  final VoidCallback onVisitWebsite;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final brightness = Theme.of(context).brightness;
    final textTheme = Theme.of(context).textTheme;
    final featuredPrograms = college.courses.isNotEmpty
        ? college.courses
        : college.tags;

    return SizedBox(
      width: 268,
      child: Container(
        padding: const EdgeInsets.all(15),
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        college.name,
                        style: textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                          fontSize: 14.8,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        college.formattedLocation,
                        style: textTheme.bodySmall?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: 'Remove from compare',
                  visualDensity: VisualDensity.compact,
                  icon: const Icon(Icons.close_rounded, size: 18),
                  onPressed: onRemove,
                ),
              ],
            ),
            Divider(height: 18, color: scheme.outlineVariant.withAlpha(140)),
            _MetricRow(
              label: 'NIRF Rank',
              value: college.rank != null ? '#${college.rank}' : 'Not Ranked',
            ),
            const SizedBox(height: 6),
            _MetricRow(
              label: 'Institute Type',
              value: college.type ?? 'General',
            ),
            const SizedBox(height: 6),
            _MetricRow(
              label: 'Average Fees',
              value: college.avgFees ?? 'Contact Institute',
            ),
            const SizedBox(height: 6),
            _MetricRow(label: 'Intake', value: college.intake ?? 'UG / PG'),
            Divider(height: 18, color: scheme.outlineVariant.withAlpha(140)),
            Text(
              'Featured Programs / Tags',
              style: textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 6),
            if (featuredPrograms.isNotEmpty)
              for (final item in featuredPrograms.take(4))
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    children: [
                      Icon(Icons.circle, size: 6, color: scheme.primary),
                      const SizedBox(width: 6),
                      Expanded(child: Text(item, style: textTheme.bodySmall)),
                    ],
                  ),
                )
            else
              Text(
                'Information upon inquiry',
                style: textTheme.bodySmall?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
            Divider(height: 18, color: scheme.outlineVariant.withAlpha(140)),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: onViewDetails,
                style: FilledButton.styleFrom(
                  enableFeedback: false,
                  minimumSize: const Size(0, 42),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(13),
                  ),
                ),
                child: const Text('View Full Profile'),
              ),
            ),
            if ((college.website ?? '').isNotEmpty) ...[
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: onVisitWebsite,
                  style: OutlinedButton.styleFrom(
                    enableFeedback: false,
                    minimumSize: const Size(0, 42),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(13),
                    ),
                  ),
                  child: const Text('Visit Website'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _MetricRow extends StatelessWidget {
  const _MetricRow({required this.label, required this.value});

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
          style: textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
        ),
        Flexible(
          child: Text(
            value,
            style: textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w700),
            textAlign: TextAlign.end,
          ),
        ),
      ],
    );
  }
}

class _CompareBackdropPainter extends CustomPainter {
  const _CompareBackdropPainter({required this.isDark});

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
  bool shouldRepaint(covariant _CompareBackdropPainter oldDelegate) =>
      oldDelegate.isDark != isDark;
}
