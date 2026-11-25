import 'dart:async';

import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

import '../core/constants/app_routes.dart';
import '../core/utils/external_link_helper.dart';
import '../models/scholarship.dart';
import '../providers/catalog_provider.dart';
import '../providers/quiz_gamification_provider.dart';
import '../widgets/empty_state_view.dart';
import '../widgets/gradient_hero_card.dart';

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
    final items = catalog.filteredScholarships;
    final savedIds = catalog.savedScholarshipIds;
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Scholarships'),
            Text(
              !catalog.isLoaded
                  ? 'Looking up scholarships…'
                  : items.isEmpty
                  ? 'No scholarships match your filters'
                  : '${items.length} sample opportunities',
              style: textTheme.bodySmall?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Saved Scholarships',
            icon: const Icon(Icons.bookmark_rounded),
            onPressed: () {
              unawaited(HapticFeedback.selectionClick());
              context.push(AppRoutes.saved);
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          child: Column(
            children: [
              GradientHeroCard(
                horizontalGradient: true,
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Find funding for your path',
                      style: textTheme.titleMedium?.copyWith(
                        color: scheme.onPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Demo catalog with 2025 historical sample dates. Filter by category or search by eligibility.',
                      style: textTheme.bodySmall?.copyWith(
                        color: scheme.onPrimary.withAlpha(240),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _searchController,
                onChanged: (value) =>
                    unawaited(catalog.setScholarshipSearchQuery(value)),
                textInputAction: TextInputAction.search,
                decoration: InputDecoration(
                  labelText: 'Search scholarships or eligibility…',
                  prefixIcon: const Icon(Icons.search_rounded),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          tooltip: 'Clear search',
                          icon: const Icon(Icons.clear_rounded),
                          onPressed: () {
                            _searchController.clear();
                            unawaited(catalog.setScholarshipSearchQuery(''));
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
                  itemCount: CatalogProvider.scholarshipCategories.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final cat = CatalogProvider.scholarshipCategories[index];
                    final selected =
                        catalog.scholarshipCategoryFilter.toLowerCase() ==
                        cat.toLowerCase();
                    return FilterChip(
                      label: Text(cat),
                      selected: selected,
                      onSelected: (_) =>
                          unawaited(catalog.setScholarshipCategoryFilter(cat)),
                    );
                  },
                ),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: !catalog.isLoaded
                    ? const Center(child: CircularProgressIndicator())
                    : items.isEmpty
                    ? EmptyStateView(
                        icon: Icons.search_off_rounded,
                        title: 'No scholarships match your filters',
                        subtitle: 'Try switching the category or clearing the search term.',
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
                        padding: const EdgeInsets.only(bottom: 16),
                        itemCount: items.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final item = items[index];
                          return _ScholarshipCard(
                            item: item,
                            isSaved: savedIds.contains(item.id),
                            onToggleBookmark: () {
                              unawaited(HapticFeedback.mediumImpact());
                              unawaited(
                                catalog.toggleSavedScholarship(item.id),
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
      ),
    );
  }
}

class _ScholarshipCard extends StatelessWidget {
  const _ScholarshipCard({
    required this.item,
    required this.isSaved,
    required this.onToggleBookmark,
    required this.onApply,
  });

  final Scholarship item;
  final bool isSaved;
  final VoidCallback onToggleBookmark;
  final VoidCallback onApply;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  backgroundColor: scheme.primaryContainer,
                  child: Icon(
                    Icons.star_rounded,
                    color: scheme.onPrimaryContainer,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.name,
                        style: textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Wrap(
                        spacing: 6,
                        runSpacing: 4,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Text(
                            item.category,
                            style: textTheme.labelSmall?.copyWith(
                              color: scheme.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          if (item.isHistoricalSample)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: scheme.errorContainer,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                'Sample • Expired (2025)',
                                style: textTheme.labelSmall?.copyWith(
                                  color: scheme.onErrorContainer,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: isSaved ? 'Remove bookmark' : 'Save scholarship',
                  icon: Icon(
                    isSaved
                        ? Icons.bookmark_rounded
                        : Icons.bookmark_border_rounded,
                    color: isSaved ? scheme.primary : scheme.onSurfaceVariant,
                  ),
                  onPressed: onToggleBookmark,
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              'Amount: ${item.amount ?? 'Amount varies'}',
              style: textTheme.bodySmall?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              'Deadline: ${item.deadline ?? 'Deadline not announced'}',
              style: textTheme.bodySmall?.copyWith(
                color: item.isHistoricalSample
                    ? scheme.error
                    : scheme.onSurfaceVariant,
              ),
            ),
            if ((item.eligibility ?? '').isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(
                'Who can apply: ${item.eligibility}',
                style: textTheme.bodySmall,
              ),
            ],
            if ((item.description ?? '').isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                item.description!,
                style: textTheme.bodySmall?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            const SizedBox(height: 12),
            FilledButton.icon(
              icon: const Icon(Icons.open_in_new_rounded, size: 18),
              label: const Text('Apply Now'),
              onPressed: onApply,
            ),
          ],
        ),
      ),
    );
  }
}
