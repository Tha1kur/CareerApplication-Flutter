import 'dart:async';

import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

import '../core/constants/app_routes.dart';
import '../core/theme/app_colors.dart';
import '../models/scholarship.dart';
import '../models/tracked_scholarship.dart';
import '../providers/catalog_provider.dart';
import '../providers/quiz_gamification_provider.dart';
import '../providers/tracker_provider.dart';
import '../widgets/empty_state_view.dart';

class ApplicationTrackerScreen extends StatelessWidget {
  const ApplicationTrackerScreen({super.key});

  Future<void> _showAddDialog(
    BuildContext context,
    List<Scholarship> allCatalog,
    List<TrackedScholarship> tracked,
  ) async {
    final trackedIds = tracked.map((e) => e.scholarshipId).toSet();
    final untracked = allCatalog
        .where((s) => !trackedIds.contains(s.id))
        .toList(growable: false);

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Add Scholarship to Tracker'),
          content: SizedBox(
            width: double.maxFinite,
            child: untracked.isEmpty
                ? const Text(
                    'All catalog scholarships are already in your tracker!',
                  )
                : ListView.separated(
                    shrinkWrap: true,
                    itemCount: untracked.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final s = untracked[index];
                      return Card(
                        clipBehavior: Clip.antiAlias,
                        child: ListTile(
                          title: Text(s.name),
                          subtitle: Text(
                            '${s.category} • ${s.amount ?? 'Varies'}',
                          ),
                          trailing: const Icon(Icons.add_rounded),
                          onTap: () async {
                            unawaited(HapticFeedback.mediumImpact());
                            await context
                                .read<TrackerProvider>()
                                .trackScholarship(s);
                            if (dialogContext.mounted) {
                              Navigator.of(dialogContext).pop();
                            }
                          },
                        ),
                      );
                    },
                  ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showNotesDialog(
    BuildContext context,
    TrackedScholarship item,
  ) async {
    final controller = TextEditingController(text: item.notes);
    final saved = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Application Notes & Reference ID'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.scholarshipName,
                style: Theme.of(context).textTheme.titleSmall
                    ?.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: controller,
                maxLines: 4,
                decoration: const InputDecoration(
                  hintText: 'e.g. App ID #NSP2026-884, interview date Nov 12…',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(controller.text),
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
    controller.dispose();

    if (saved == null || !context.mounted) return;
    await context.read<TrackerProvider>().saveNotes(item.scholarshipId, saved);
  }

  @override
  Widget build(BuildContext context) {
    final tracker = context.watch<TrackerProvider>();
    final catalog = context.watch<CatalogProvider>();
    final quizProvider = context.read<QuizGamificationProvider>();
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final trackedList = tracker.items;
    final filtered = tracker.filteredItems;
    final savedScholarships = catalog.savedScholarships;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.assignment_turned_in_rounded, color: scheme.primary),
            const SizedBox(width: 8),
            const Text('Application Tracker'),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Add Scholarship to Tracker',
        onPressed: () =>
            _showAddDialog(context, catalog.allScholarships, trackedList),
        child: const Icon(Icons.add_rounded),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Stage filter chips
            Container(
              width: double.infinity,
              color: scheme.surfaceContainerHighest.withAlpha(110),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    FilterChip(
                      label: Text('All (${trackedList.length})'),
                      selected: tracker.selectedStageFilter == null,
                      onSelected: (_) => tracker.setStageFilter(null),
                    ),
                    const SizedBox(width: 8),
                    for (final stage in ApplicationStage.values) ...[
                      FilterChip(
                        label: Text(
                          '${stage.label} (${tracker.countForStage(stage)})',
                        ),
                        selected: tracker.selectedStageFilter == stage,
                        onSelected: (_) => tracker.setStageFilter(stage),
                      ),
                      const SizedBox(width: 8),
                    ],
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Personal local checklist — does not submit external applications automatically.',
                  style: textTheme.labelSmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ),
            ),
            Expanded(
              child: trackedList.isEmpty
                  ? EmptyStateView(
                      icon: Icons.assignment_turned_in_rounded,
                      title: 'No Tracked Applications Yet',
                      subtitle: 'Track scholarship deadlines, document readiness, and notes locally across 4 stages.',
                      actionLabel: savedScholarships.isNotEmpty
                          ? 'Import Saved (${savedScholarships.length})'
                          : 'Add From Catalog',
                      onAction: () async {
                        if (savedScholarships.isNotEmpty) {
                          unawaited(HapticFeedback.mediumImpact());
                          await tracker.importSavedScholarships(
                            savedScholarships,
                          );
                        } else {
                          await _showAddDialog(
                            context,
                            catalog.allScholarships,
                            trackedList,
                          );
                        }
                      },
                      secondaryActionLabel: 'Explore Catalog',
                      onSecondaryAction: () =>
                          context.push(AppRoutes.scholarships),
                    )
                  : filtered.isEmpty
                  ? const EmptyStateView(
                      icon: Icons.filter_list_off_rounded,
                      title: 'No applications in this stage',
                      subtitle: 'Switch the stage filter above or update an application stage.',
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 88),
                      itemCount: filtered.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 14),
                      itemBuilder: (context, index) {
                        final item = filtered[index];
                        return _TrackedScholarshipCard(
                          item: item,
                          onStageChange: (newStage) async {
                            unawaited(HapticFeedback.mediumImpact());
                            await tracker.updateStage(
                              item.scholarshipId,
                              newStage,
                            );
                            if (newStage == ApplicationStage.awarded) {
                              final earned = await quizProvider
                                  .grantScholarshipAwardedReward(
                                    item.scholarshipId,
                                  );
                              if (earned && context.mounted) {
                                ScaffoldMessenger.of(context)
                                  ..hideCurrentSnackBar()
                                  ..showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Scholarship Awarded! +100 XP & badge earned',
                                      ),
                                    ),
                                  );
                              }
                            }
                          },
                          onToggleDocument: (doc) {
                            unawaited(HapticFeedback.selectionClick());
                            unawaited(
                              tracker.toggleDocument(item.scholarshipId, doc),
                            );
                          },
                          onEditNotes: () => _showNotesDialog(context, item),
                          onUntrack: () => unawaited(
                            tracker.untrackScholarship(item.scholarshipId),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TrackedScholarshipCard extends StatefulWidget {
  const _TrackedScholarshipCard({
    required this.item,
    required this.onStageChange,
    required this.onToggleDocument,
    required this.onEditNotes,
    required this.onUntrack,
  });

  final TrackedScholarship item;
  final ValueChanged<ApplicationStage> onStageChange;
  final ValueChanged<String> onToggleDocument;
  final VoidCallback onEditNotes;
  final VoidCallback onUntrack;

  @override
  State<_TrackedScholarshipCard> createState() =>
      _TrackedScholarshipCardState();
}

class _TrackedScholarshipCardState extends State<_TrackedScholarshipCard> {
  bool _expandedChecklist = false;

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final stageBg = switch (item.stage) {
      ApplicationStage.discovered => scheme.surfaceContainerHighest,
      ApplicationStage.docsReady => scheme.secondaryContainer,
      ApplicationStage.applied => scheme.primaryContainer,
      ApplicationStage.awarded => AppColors.success.withAlpha(35),
    };
    final stageFg = switch (item.stage) {
      ApplicationStage.discovered => scheme.onSurfaceVariant,
      ApplicationStage.docsReady => scheme.onSecondaryContainer,
      ApplicationStage.applied => scheme.onPrimaryContainer,
      ApplicationStage.awarded => AppColors.success,
    };

    return Card(
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
                        item.scholarshipName,
                        style: textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${item.provider} • Deadline: ${item.deadline}',
                        style: textTheme.bodySmall?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: stageBg,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    item.stage.label,
                    style: textTheme.labelSmall?.copyWith(
                      color: stageFg,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: scheme.tertiaryContainer.withAlpha(150),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                'Grant Value: ${item.amount}',
                style: textTheme.labelSmall?.copyWith(
                  color: scheme.onTertiaryContainer,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Application Stage:',
              style: textTheme.labelSmall?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 6),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: ApplicationStage.values.map((stage) {
                final selected = item.stage == stage;
                return ChoiceChip(
                  label: Text(stage.label),
                  selected: selected,
                  onSelected: (_) => widget.onStageChange(stage),
                );
              }).toList(),
            ),
            const Divider(height: 22),
            InkWell(
              onTap: () =>
                  setState(() => _expandedChecklist = !_expandedChecklist),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Document Checklist (${item.completedStandardDocsCount}/${kStandardRequiredDocuments.length})',
                    style: textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    _expandedChecklist ? 'Hide' : 'Manage',
                    style: textTheme.labelMedium?.copyWith(
                      color: scheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: item.documentProgressFraction,
                minHeight: 6,
                valueColor: AlwaysStoppedAnimation<Color>(
                  item.documentProgressFraction >= 1.0
                      ? AppColors.success
                      : scheme.primary,
                ),
              ),
            ),
            if (_expandedChecklist) ...[
              const SizedBox(height: 10),
              for (final doc in kStandardRequiredDocuments)
                InkWell(
                  onTap: () => widget.onToggleDocument(doc),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 5),
                    child: Row(
                      children: [
                        Icon(
                          item.completedDocuments.contains(doc)
                              ? Icons.check_circle_rounded
                              : Icons.radio_button_unchecked_rounded,
                          size: 20,
                          color: item.completedDocuments.contains(doc)
                              ? AppColors.success
                              : scheme.outline,
                        ),
                        const SizedBox(width: 8),
                        Expanded(child: Text(doc, style: textTheme.bodySmall)),
                      ],
                    ),
                  ),
                ),
            ],
            if (item.notes.isNotEmpty) ...[
              const SizedBox(height: 10),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: scheme.surfaceContainerHighest.withAlpha(140),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  'Notes: ${item.notes}',
                  style: textTheme.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ),
            ],
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                OutlinedButton.icon(
                  icon: const Icon(Icons.edit_outlined, size: 16),
                  label: Text(item.notes.isEmpty ? 'Add Note' : 'Edit Note'),
                  onPressed: widget.onEditNotes,
                ),
                IconButton(
                  tooltip: 'Remove from tracker',
                  icon: Icon(Icons.delete_outline_rounded, color: scheme.error),
                  onPressed: widget.onUntrack,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
