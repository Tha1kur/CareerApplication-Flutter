import 'dart:async';

import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

import '../core/constants/app_routes.dart';
import '../core/utils/external_link_helper.dart';
import '../models/college.dart';
import '../providers/catalog_provider.dart';
import '../repositories/college_repository.dart';
import '../widgets/empty_state_view.dart';

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

  Future<void> _showAddCollegeDialog(List<College> allColleges) async {
    final available = allColleges
        .where((c) => !_selectedIds.contains(c.id))
        .toList(growable: false);

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Add College to Compare'),
          content: SizedBox(
            width: double.maxFinite,
            child: available.isEmpty
                ? const Text('All available colleges are already added.')
                : ListView.separated(
                    shrinkWrap: true,
                    itemCount: available.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final col = available[index];
                      return Card(
                        clipBehavior: Clip.antiAlias,
                        child: ListTile(
                          title: Text(col.name),
                          subtitle: Text(col.formattedLocation),
                          trailing: const Icon(Icons.add_rounded),
                          onTap: () {
                            unawaited(HapticFeedback.selectionClick());
                            setState(() {
                              if (_selectedIds.length <
                                  CollegeRepository.maxCompareSelection) {
                                _selectedIds = [..._selectedIds, col.id];
                              }
                            });
                            Navigator.of(dialogContext).pop();
                          },
                        ),
                      );
                    },
                  ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
          ],
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
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Compare Colleges'),
            Text(
              '${selectedColleges.length} of ${CollegeRepository.maxCompareSelection} selected',
              style: textTheme.bodySmall?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        actions: [
          if (selectedColleges.length < CollegeRepository.maxCompareSelection &&
              allColleges.isNotEmpty)
            IconButton(
              tooltip: 'Add college to compare',
              icon: const Icon(Icons.add_rounded),
              onPressed: () => _showAddCollegeDialog(allColleges),
            ),
        ],
      ),
      body: SafeArea(
        child: !catalog.isLoaded
            ? const Center(child: CircularProgressIndicator())
            : selectedColleges.isEmpty
            ? EmptyStateView(
                icon: Icons.compare_arrows_rounded,
                title: 'No colleges selected for comparison',
                subtitle: 'Select up to 3 institutions to compare rank, fees, intake, and focus areas side by side.',
                actionLabel: 'Select Colleges',
                onAction: () => _showAddCollegeDialog(allColleges),
              )
            : ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  if (selectedColleges.length <
                      CollegeRepository.maxCompareSelection) ...[
                    FilledButton.tonalIcon(
                      icon: const Icon(Icons.add_rounded),
                      label: Text(
                        'Add another college to compare (${selectedColleges.length}/3)',
                      ),
                      onPressed: () => _showAddCollegeDialog(allColleges),
                    ),
                    const SizedBox(height: 14),
                  ],
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        for (var i = 0; i < selectedColleges.length; i++) ...[
                          _ComparisonColumnCard(
                            college: selectedColleges[i],
                            onRemove: () {
                              unawaited(HapticFeedback.mediumImpact());
                              setState(() {
                                _selectedIds = _selectedIds
                                    .where((id) => id != selectedColleges[i].id)
                                    .toList();
                              });
                            },
                            onViewDetails: () => context.push(
                              AppRoutes.collegeDetails(selectedColleges[i].id),
                            ),
                            onVisitWebsite: () {
                              final url = selectedColleges[i].website;
                              if (url != null && url.isNotEmpty) {
                                unawaited(
                                  launchExternalUrlSafely(context, url),
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
                  const SizedBox(height: 16),
                  Card(
                    color: scheme.surfaceContainerHighest.withAlpha(140),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Comparison Insights',
                            style: textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
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
                  ),
                ],
              ),
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
    final textTheme = Theme.of(context).textTheme;
    final featuredPrograms = college.courses.isNotEmpty
        ? college.courses
        : college.tags;

    return SizedBox(
      width: 270,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(14),
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
                            fontWeight: FontWeight.w700,
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
              const Divider(height: 18),
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
              const Divider(height: 18),
              Text(
                'Featured Programs / Tags',
                style: textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.w600,
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
              const Divider(height: 18),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: onViewDetails,
                  child: const Text('View Full Profile'),
                ),
              ),
              if ((college.website ?? '').isNotEmpty) ...[
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: onVisitWebsite,
                    child: const Text('Visit Website'),
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
            style: textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w600),
            textAlign: TextAlign.end,
          ),
        ),
      ],
    );
  }
}
