import 'dart:async';

import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

import '../core/constants/app_routes.dart';
import '../core/router/app_navigation.dart';
import '../core/utils/external_link_helper.dart';
import '../providers/catalog_provider.dart';
import '../widgets/empty_state_view.dart';

class CollegeDetailsScreen extends StatelessWidget {
  const CollegeDetailsScreen({super.key, required this.collegeId});

  final String collegeId;

  @override
  Widget build(BuildContext context) {
    final catalog = context.watch<CatalogProvider>();
    final college = catalog.collegeById(collegeId);
    final isSaved = catalog.savedCollegeIds.contains(collegeId);
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          college?.name ?? 'College Details',
          overflow: TextOverflow.ellipsis,
        ),
        actions: college == null
            ? null
            : [
                IconButton(
                  tooltip: 'Compare this college',
                  icon: const Icon(Icons.compare_arrows_rounded),
                  onPressed: () {
                    unawaited(HapticFeedback.selectionClick());
                    context.push(AppRoutes.compareWithIds([college.id]));
                  },
                ),
                IconButton(
                  tooltip: isSaved ? 'Remove bookmark' : 'Bookmark',
                  icon: Icon(
                    isSaved
                        ? Icons.favorite_rounded
                        : Icons.favorite_border_rounded,
                    color: isSaved ? scheme.primary : null,
                  ),
                  onPressed: () {
                    unawaited(HapticFeedback.mediumImpact());
                    unawaited(catalog.toggleSavedCollege(college.id));
                  },
                ),
              ],
      ),
      body: SafeArea(
        child: !catalog.isLoaded
            ? const Center(child: CircularProgressIndicator())
            : college == null
            ? EmptyStateView(
                icon: Icons.school_outlined,
                title: 'College not found',
                subtitle:
                    'We could not find an institution matching ID "$collegeId".',
                actionLabel: 'Browse Colleges',
                onAction: () => context.safePop(fallback: AppRoutes.colleges),
              )
            : ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Text(
                    college.name,
                    style: textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${college.formattedLocation}${(college.type ?? '').isNotEmpty ? ' • ${college.type}' : ''}',
                    style: textTheme.bodyMedium?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        children: [
                          _DetailRow(
                            label: 'NIRF / Catalog Rank',
                            value: college.rank != null
                                ? '#${college.rank}'
                                : 'N/A',
                          ),
                          const Divider(height: 18),
                          _DetailRow(
                            label: 'Intake Level',
                            value: college.intake ?? 'N/A',
                          ),
                          const Divider(height: 18),
                          _DetailRow(
                            label: 'Average Fees',
                            value: college.avgFees ?? 'N/A',
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'About',
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    college.description ?? 'No description provided.',
                    style: textTheme.bodyMedium,
                  ),
                  if (college.tags.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Text(
                      'Focus Areas & Tags',
                      style: textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: college.tags
                          .map((tag) => Chip(label: Text(tag)))
                          .toList(),
                    ),
                  ],
                  const SizedBox(height: 20),
                  OutlinedButton.icon(
                    icon: const Icon(Icons.compare_arrows_rounded),
                    label: const Text('Compare this College'),
                    onPressed: () {
                      unawaited(HapticFeedback.selectionClick());
                      context.push(AppRoutes.compareWithIds([college.id]));
                    },
                  ),
                  if ((college.website ?? '').isNotEmpty) ...[
                    const SizedBox(height: 10),
                    FilledButton.icon(
                      icon: const Icon(Icons.open_in_new_rounded),
                      label: const Text('Visit Website / Apply'),
                      onPressed: () => unawaited(
                        launchExternalUrlSafely(context, college.website!),
                      ),
                    ),
                  ],
                ],
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
          style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}
