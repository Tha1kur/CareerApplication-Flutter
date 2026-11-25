import 'dart:async';

import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

import '../core/constants/app_routes.dart';
import '../core/utils/external_link_helper.dart';
import '../providers/catalog_provider.dart';
import '../widgets/empty_state_view.dart';

class SavedScreen extends StatelessWidget {
  const SavedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final catalog = context.watch<CatalogProvider>();
    final savedColleges = catalog.savedColleges;
    final savedScholarships = catalog.savedScholarships;
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Saved Opportunities'),
              Text(
                '${savedColleges.length} Colleges • ${savedScholarships.length} Scholarships',
                style: textTheme.bodySmall?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          bottom: TabBar(
            tabs: [
              Tab(
                icon: const Icon(Icons.school_rounded),
                text: 'Colleges (${savedColleges.length})',
              ),
              Tab(
                icon: const Icon(Icons.bookmark_rounded),
                text: 'Scholarships (${savedScholarships.length})',
              ),
            ],
          ),
        ),
        body: SafeArea(
          child: TabBarView(
            children: [
              // Colleges Tab
              if (savedColleges.isEmpty)
                EmptyStateView(
                  icon: Icons.school_rounded,
                  title: 'No saved colleges yet',
                  subtitle: 'Explore institutes and bookmark them to keep track of fees, ranks, and admission info.',
                  actionLabel: 'Explore Colleges',
                  onAction: () => context.push(AppRoutes.colleges),
                )
              else
                ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: savedColleges.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final college = savedColleges[index];
                    return Card(
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        college.name,
                                        style: textTheme.titleMedium?.copyWith(
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
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
                                  tooltip: 'Remove from saved',
                                  icon: Icon(
                                    Icons.favorite_rounded,
                                    color: scheme.primary,
                                  ),
                                  onPressed: () {
                                    unawaited(HapticFeedback.mediumImpact());
                                    unawaited(
                                      catalog.toggleSavedCollege(college.id),
                                    );
                                  },
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                if (college.rank != null)
                                  Text(
                                    'NIRF Rank: #${college.rank}',
                                    style: textTheme.labelSmall?.copyWith(
                                      color: scheme.primary,
                                    ),
                                  ),
                                if ((college.avgFees ?? '').isNotEmpty)
                                  Text(
                                    'Avg Fees: ${college.avgFees}',
                                    style: textTheme.labelSmall?.copyWith(
                                      color: scheme.onSurfaceVariant,
                                    ),
                                  ),
                              ],
                            ),
                            const Divider(height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                OutlinedButton.icon(
                                  icon: const Icon(
                                    Icons.compare_arrows_rounded,
                                    size: 16,
                                  ),
                                  label: const Text('Compare'),
                                  onPressed: () => context.push(
                                    AppRoutes.compareWithIds([college.id]),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                FilledButton(
                                  onPressed: () => context.push(
                                    AppRoutes.collegeDetails(college.id),
                                  ),
                                  child: const Text('View Details'),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),

              // Scholarships Tab
              if (savedScholarships.isEmpty)
                EmptyStateView(
                  icon: Icons.bookmark_rounded,
                  title: 'No saved scholarships yet',
                  subtitle: 'Save scholarship opportunities to review amounts, eligibility, and import them into your tracker.',
                  actionLabel: 'Browse Scholarships',
                  onAction: () => context.push(AppRoutes.scholarships),
                )
              else
                ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: savedScholarships.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final s = savedScholarships[index];
                    return Card(
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        s.name,
                                        style: textTheme.titleMedium?.copyWith(
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      Text(
                                        s.category,
                                        style: textTheme.labelSmall?.copyWith(
                                          color: scheme.secondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  tooltip: 'Remove scholarship',
                                  icon: Icon(
                                    Icons.bookmark_remove_rounded,
                                    color: scheme.primary,
                                  ),
                                  onPressed: () {
                                    unawaited(HapticFeedback.mediumImpact());
                                    unawaited(
                                      catalog.toggleSavedScholarship(s.id),
                                    );
                                  },
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Grant: ${s.amount ?? 'Varies'}',
                              style: textTheme.bodySmall,
                            ),
                            Text(
                              'Deadline: ${s.deadline ?? 'Rolling'}${s.isHistoricalSample ? ' (Sample • Expired)' : ''}',
                              style: textTheme.bodySmall?.copyWith(
                                color: s.isHistoricalSample
                                    ? scheme.error
                                    : scheme.onSurfaceVariant,
                              ),
                            ),
                            if ((s.eligibility ?? '').isNotEmpty) ...[
                              const SizedBox(height: 4),
                              Text(
                                'Eligibility: ${s.eligibility}',
                                style: textTheme.bodySmall,
                              ),
                            ],
                            const Divider(height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                OutlinedButton(
                                  onPressed: () => context.push(
                                    AppRoutes.applicationTracker,
                                  ),
                                  child: const Text('Open Tracker'),
                                ),
                                const SizedBox(width: 8),
                                FilledButton(
                                  onPressed: () => unawaited(
                                    launchExternalUrlSafely(
                                      context,
                                      s.applyLink ?? '',
                                    ),
                                  ),
                                  child: const Text('Apply Now'),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }
}
