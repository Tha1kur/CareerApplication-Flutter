import 'dart:async';

import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

import '../core/constants/app_routes.dart';
import '../core/router/app_navigation.dart';
import '../core/theme/app_colors.dart';
import '../models/scholarship.dart';
import '../models/tracked_scholarship.dart';
import '../providers/catalog_provider.dart';
import '../providers/quiz_gamification_provider.dart';
import '../providers/tracker_provider.dart';
import '../widgets/empty_state_view.dart';

/// Cohesive CareerGuide Lavender & White Application Tracker screen:
/// - Secondary screen (no repeated brand top bar) starting with <- Application Tracker
/// - Horizontal violet stage filter pills + floating white tracked scholarship cards
/// - 4-stage ChoiceChips (Awarded awards +100 XP once), expandable checklist, notes & local notice
class ApplicationTrackerScreen extends StatelessWidget {
  const ApplicationTrackerScreen({super.key});

  Future<void> _showAddSheet(
    BuildContext context,
    List<Scholarship> allCatalog,
    List<TrackedScholarship> tracked,
  ) async {
    final trackedIds = tracked.map((e) => e.scholarshipId).toSet();
    final untracked = allCatalog
        .where((s) => !trackedIds.contains(s.id))
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
                    'Add Scholarship to Tracker',
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                if (untracked.isEmpty)
                  Padding(
                    padding: const EdgeInsets.all(10),
                    child: Text(
                      'All catalog scholarships are already in your tracker!',
                      style: textTheme.bodyMedium?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  )
                else
                  Flexible(
                    child: ListView.separated(
                      shrinkWrap: true,
                      itemCount: untracked.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final s = untracked[index];
                        return Material(
                          color: scheme.surfaceContainerHighest.withAlpha(140),
                          borderRadius: BorderRadius.circular(16),
                          clipBehavior: Clip.antiAlias,
                          child: ListTile(
                            enableFeedback: false,
                            leading: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: scheme.primaryContainer,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                Icons.workspace_premium_rounded,
                                color: scheme.primary,
                                size: 20,
                              ),
                            ),
                            title: Text(
                              s.name,
                              style: textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            subtitle: Text(
                              '${s.category} • ${s.amount ?? 'Varies'}',
                              style: textTheme.bodySmall?.copyWith(
                                color: scheme.onSurfaceVariant,
                              ),
                            ),
                            trailing: Icon(
                              Icons.add_circle_rounded,
                              color: scheme.primary,
                            ),
                            onTap: () async {
                              await context
                                  .read<TrackerProvider>()
                                  .trackScholarship(s);
                              if (sheetContext.mounted) {
                                Navigator.of(sheetContext).pop();
                              }
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

  Future<void> _showNotesDialog(
    BuildContext context,
    TrackedScholarship item,
  ) async {
    final controller = TextEditingController(text: item.notes);
    final saved = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          title: const Text('Application Notes & Reference ID'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.scholarshipName,
                style: Theme.of(
                  context,
                ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
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
    final brightness = Theme.of(context).brightness;
    final isDark = brightness == Brightness.dark;
    final textTheme = Theme.of(context).textTheme;

    final trackedList = tracker.items;
    final filtered = tracker.filteredItems;
    final savedScholarships = catalog.savedScholarships;

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        tooltip: 'Add Scholarship to Tracker',
        backgroundColor: const Color(0xFF7433D6),
        foregroundColor: Colors.white,
        onPressed: () =>
            _showAddSheet(context, catalog.allScholarships, trackedList),
        child: const Icon(Icons.add_rounded),
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: CustomPaint(
              painter: _TrackerBackdropPainter(isDark: isDark),
            ),
          ),
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),

                // 1. Clean Secondary Header Row
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
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Application Tracker',
                              style: textTheme.headlineSmall?.copyWith(
                                fontSize: 22.5,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.5,
                                color: isDark
                                    ? scheme.onSurface
                                    : const Color(0xFF17122B),
                              ),
                            ),
                            Text(
                              'Track scholarship stages, docs & notes locally.',
                              style: textTheme.bodySmall?.copyWith(
                                color: scheme.onSurfaceVariant,
                                fontSize: 12.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: isDark
                              ? scheme.primaryContainer
                              : const Color(0xFFF0E8FF),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Icon(
                          Icons.assignment_turned_in_rounded,
                          size: 22,
                          color: isDark
                              ? scheme.primary
                              : const Color(0xFF6B2FD0),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 14),

                // 2. Horizontal Violet Stage Filter Pills
                SizedBox(
                  height: 36,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    children: [
                      _StagePill(
                        label: 'All (${trackedList.length})',
                        selected: tracker.selectedStageFilter == null,
                        onTap: () => tracker.setStageFilter(null),
                      ),
                      const SizedBox(width: 8),
                      for (final stage in ApplicationStage.values) ...[
                        _StagePill(
                          label:
                              '${stage.label} (${tracker.countForStage(stage)})',
                          selected: tracker.selectedStageFilter == stage,
                          onTap: () => tracker.setStageFilter(stage),
                        ),
                        const SizedBox(width: 8),
                      ],
                    ],
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                  child: Text(
                    'Personal local checklist — does not submit external applications automatically.',
                    style: textTheme.labelSmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ),

                // 3. Tracked Items List or Empty State
                Expanded(
                  child: trackedList.isEmpty
                      ? EmptyStateView(
                          icon: Icons.assignment_turned_in_rounded,
                          title: 'No Tracked Applications Yet',
                          subtitle:
                              'Track scholarship deadlines, document readiness, and notes locally across 4 stages.',
                          actionLabel: savedScholarships.isNotEmpty
                              ? 'Import Saved (${savedScholarships.length})'
                              : 'Add From Catalog',
                          onAction: () async {
                            if (savedScholarships.isNotEmpty) {
                              await tracker.importSavedScholarships(
                                savedScholarships,
                              );
                            } else {
                              await _showAddSheet(
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
                          subtitle:
                              'Switch the stage filter above or update an application stage.',
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.fromLTRB(14, 8, 14, 88),
                          itemCount: filtered.length,
                          separatorBuilder: (_, _) =>
                              const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final item = filtered[index];
                            return _TrackedScholarshipCard(
                              item: item,
                              onStageChange: (newStage) async {
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
                              onToggleDocument: (doc) => unawaited(
                                tracker.toggleDocument(item.scholarshipId, doc),
                              ),
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
        ],
      ),
    );
  }
}

class _StagePill extends StatelessWidget {
  const _StagePill({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Material(
      color: selected
          ? (isDark ? scheme.primary : const Color(0xFF7433D6))
          : (isDark ? scheme.surface : const Color(0xFFEEE7FF)),
      borderRadius: BorderRadius.circular(18),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        enableFeedback: false,
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12.2,
              fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
              color: selected
                  ? Colors.white
                  : (isDark ? scheme.onSurface : const Color(0xFF423C5C)),
            ),
          ),
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
    final brightness = Theme.of(context).brightness;
    final isDark = brightness == Brightness.dark;
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

    return Container(
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
                      item.scholarshipName,
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        fontSize: 15.2,
                      ),
                    ),
                    const SizedBox(height: 3),
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
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                decoration: BoxDecoration(
                  color: stageBg,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  item.stage.label,
                  style: textTheme.labelSmall?.copyWith(
                    color: stageFg,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
            decoration: BoxDecoration(
              color: isDark
                  ? const Color(0xFF231C42)
                  : const Color(0xFFF6F2FF),
              borderRadius: BorderRadius.circular(9),
            ),
            child: Text(
              'Grant Value: ${item.amount}',
              style: TextStyle(
                fontSize: 11.8,
                fontWeight: FontWeight.w700,
                color: isDark ? scheme.primary : const Color(0xFF6B2FD0),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Application Stage:',
            style: textTheme.labelSmall?.copyWith(
              color: scheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
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
          Divider(height: 22, color: scheme.outlineVariant.withAlpha(140)),
          InkWell(
            enableFeedback: false,
            onTap: () =>
                setState(() => _expandedChecklist = !_expandedChecklist),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Document Checklist (${item.completedStandardDocsCount}/${kStandardRequiredDocuments.length})',
                  style: textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  _expandedChecklist ? 'Hide' : 'Manage',
                  style: TextStyle(
                    fontSize: 12.5,
                    color: isDark ? scheme.primary : const Color(0xFF7433D6),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(5),
            child: LinearProgressIndicator(
              value: item.documentProgressFraction,
              minHeight: 6,
              backgroundColor: isDark
                  ? Colors.white.withAlpha(24)
                  : const Color(0xFFE5DAFC),
              valueColor: AlwaysStoppedAnimation<Color>(
                item.documentProgressFraction >= 1.0
                    ? AppColors.success
                    : const Color(0xFF7433D6),
              ),
            ),
          ),
          if (_expandedChecklist) ...[
            const SizedBox(height: 10),
            for (final doc in kStandardRequiredDocuments)
              InkWell(
                enableFeedback: false,
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
                color: isDark
                    ? const Color(0xFF231C42)
                    : const Color(0xFFF6F2FF),
                borderRadius: BorderRadius.circular(12),
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
                style: OutlinedButton.styleFrom(
                  enableFeedback: false,
                  minimumSize: const Size(0, 40),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(13),
                  ),
                ),
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
    );
  }
}

class _TrackerBackdropPainter extends CustomPainter {
  const _TrackerBackdropPainter({required this.isDark});

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
  bool shouldRepaint(covariant _TrackerBackdropPainter oldDelegate) =>
      oldDelegate.isDark != isDark;
}
