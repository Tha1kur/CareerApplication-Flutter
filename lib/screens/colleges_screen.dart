import 'dart:async';

import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

import '../core/constants/app_routes.dart';
import '../models/college.dart';
import '../providers/catalog_provider.dart';
import '../providers/quiz_gamification_provider.dart';
import '../widgets/empty_state_view.dart';
import '../widgets/gradient_hero_card.dart';

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

  @override
  Widget build(BuildContext context) {
    final catalog = context.watch<CatalogProvider>();
    final items = catalog.filteredColleges;
    final savedIds = catalog.savedCollegeIds;
    final compareIds = catalog.compareCollegeIds;
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Colleges'),
            Text(
              !catalog.isLoaded
                  ? 'Finding colleges…'
                  : items.isEmpty
                  ? 'No colleges match your filters'
                  : '${items.length} sample options found',
              style: textTheme.bodySmall?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Compare Colleges',
            icon: const Icon(Icons.compare_arrows_rounded),
            onPressed: () {
              unawaited(HapticFeedback.selectionClick());
              context.push(AppRoutes.compareWithIds(compareIds));
            },
          ),
          IconButton(
            tooltip: 'Saved Colleges',
            icon: const Icon(Icons.bookmark_rounded),
            onPressed: () {
              unawaited(HapticFeedback.selectionClick());
              context.push(AppRoutes.saved);
            },
          ),
        ],
      ),
      bottomNavigationBar: compareIds.isEmpty
          ? null
          : SafeArea(
              child: Material(
                elevation: 8,
                color: scheme.surface,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Compare (${compareIds.length}/3 selected)',
                          style: textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      OutlinedButton(
                        onPressed: () {
                          unawaited(HapticFeedback.mediumImpact());
                          catalog.clearCompareSelection();
                        },
                        child: const Text('Clear'),
                      ),
                      const SizedBox(width: 8),
                      FilledButton(
                        onPressed: () {
                          unawaited(HapticFeedback.selectionClick());
                          context.push(AppRoutes.compareWithIds(compareIds));
                        },
                        child: const Text('Compare Now'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          child: Column(
            children: [
              GradientHeroCard(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 24,
                      backgroundColor: scheme.onPrimary.withAlpha(38),
                      child: Icon(
                        Icons.school_rounded,
                        color: scheme.onPrimary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Explore colleges',
                            style: textTheme.titleMedium?.copyWith(
                              color: scheme.onPrimary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Demo catalog • Filter by stream and search by name, city, or tags.',
                            style: textTheme.bodySmall?.copyWith(
                              color: scheme.onPrimary.withAlpha(235),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _searchController,
                onChanged: (value) =>
                    unawaited(catalog.setCollegeSearchQuery(value)),
                textInputAction: TextInputAction.search,
                decoration: InputDecoration(
                  labelText: 'Search colleges, city, tags…',
                  prefixIcon: const Icon(Icons.search_rounded),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          tooltip: 'Clear search',
                          icon: const Icon(Icons.clear_rounded),
                          onPressed: () {
                            _searchController.clear();
                            unawaited(catalog.setCollegeSearchQuery(''));
                          },
                        )
                      : null,
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                height: 40,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: CatalogProvider.collegeStreamFilters.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final filter = CatalogProvider.collegeStreamFilters[index];
                    final selected =
                        catalog.collegeTypeFilter.toLowerCase() ==
                        filter.toLowerCase();
                    return FilterChip(
                      label: Text(filter),
                      selected: selected,
                      onSelected: (_) =>
                          unawaited(catalog.setCollegeTypeFilter(filter)),
                    );
                  },
                ),
              ),
              const SizedBox(height: 10),
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
                        padding: const EdgeInsets.only(bottom: 16),
                        itemCount: items.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final college = items[index];
                          return _CollegeCard(
                            college: college,
                            isSaved: savedIds.contains(college.id),
                            isCompared: compareIds.contains(college.id),
                            onTap: () => context.push(
                              AppRoutes.collegeDetails(college.id),
                            ),
                            onToggleSave: () {
                              unawaited(HapticFeedback.mediumImpact());
                              unawaited(catalog.toggleSavedCollege(college.id));
                            },
                            onToggleCompare: () {
                              unawaited(HapticFeedback.selectionClick());
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
      ),
    );
  }
}

class _CollegeCard extends StatelessWidget {
  const _CollegeCard({
    required this.college,
    required this.isSaved,
    required this.isCompared,
    required this.onTap,
    required this.onToggleSave,
    required this.onToggleCompare,
  });

  final College college;
  final bool isSaved;
  final bool isCompared;
  final VoidCallback onTap;
  final VoidCallback onToggleSave;
  final VoidCallback onToggleCompare;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final chips = college.courses.isNotEmpty ? college.courses : college.tags;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
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
                      color: scheme.primaryContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      college.name.isNotEmpty
                          ? college.name[0].toUpperCase()
                          : 'C',
                      style: textTheme.titleMedium?.copyWith(
                        color: scheme.onPrimaryContainer,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          college.name,
                          style: textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          college.formattedLocation,
                          style: textTheme.bodySmall?.copyWith(
                            color: scheme.onSurfaceVariant,
                          ),
                        ),
                        if ((college.type ?? '').isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Text(
                            college.type!,
                            style: textTheme.labelSmall?.copyWith(
                              color: scheme.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      if (college.rank != null)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: scheme.secondaryContainer,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            'Rank #${college.rank}',
                            style: textTheme.labelSmall?.copyWith(
                              color: scheme.onSecondaryContainer,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            tooltip: 'Compare',
                            visualDensity: VisualDensity.compact,
                            icon: Icon(
                              Icons.compare_arrows_rounded,
                              size: 20,
                              color: isCompared
                                  ? scheme.primary
                                  : scheme.onSurfaceVariant,
                            ),
                            onPressed: onToggleCompare,
                          ),
                          IconButton(
                            tooltip: isSaved ? 'Remove bookmark' : 'Bookmark',
                            visualDensity: VisualDensity.compact,
                            icon: Icon(
                              isSaved
                                  ? Icons.favorite_rounded
                                  : Icons.favorite_border_rounded,
                              size: 20,
                              color: isSaved
                                  ? scheme.primary
                                  : scheme.onSurfaceVariant,
                            ),
                            onPressed: onToggleSave,
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
              if ((college.description ?? '').isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  college.description!,
                  style: textTheme.bodySmall,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              if (chips.isNotEmpty) ...[
                const SizedBox(height: 10),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: chips
                      .take(5)
                      .map(
                        (tag) => Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: scheme.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(tag, style: textTheme.labelSmall),
                        ),
                      )
                      .toList(),
                ),
              ],
              if ((college.avgFees ?? '').isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  'Avg. fees: ${college.avgFees}',
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
