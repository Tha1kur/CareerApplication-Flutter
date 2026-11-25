import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

import '../core/constants/app_routes.dart';
import '../core/router/app_navigation.dart';
import '../core/theme/app_colors.dart';
import '../providers/catalog_provider.dart';
import '../providers/quiz_gamification_provider.dart';
import 'duotone_icons.dart';

/// Exact reference CareerGuide top bar:
/// Left: larger CareerGuide cap+book emblem & wordmark
/// Right: elevated white circular Notification bell (with red dot) + Profile silhouette circle
class CareerGuideTopBar extends StatelessWidget {
  const CareerGuideTopBar({
    super.key,
    this.showBackButton = false,
    this.onBack,
  });

  final bool showBackButton;
  final VoidCallback? onBack;

  void _openNotificationsAndSettingsSheet(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final quizProvider = context.read<QuizGamificationProvider>();
    final catalogProvider = context.read<CatalogProvider>();
    final progress = quizProvider.progress;

    final updates = <({String title, String subtitle, IconData icon, String route})>[
      if (!progress.completedQuiz)
        (
          title: 'Aptitude Quiz Pending',
          subtitle:
              'Complete the 8-question quiz to unlock personalized matches.',
          icon: Icons.quiz_outlined,
          route: AppRoutes.quiz,
        ),
      if (progress.completedQuiz && quizProvider.savedCareerKey.isEmpty)
        (
          title: 'Save Your Career Path',
          subtitle:
              'Review your quiz matches and save your preferred path (+50 XP).',
          icon: Icons.explore_outlined,
          route: AppRoutes.recommendations,
        ),
      if (!progress.exploredColleges)
        (
          title: 'Explore Colleges',
          subtitle: 'Browse & compare top institutes to earn College Explorer (+30 XP).',
          icon: Icons.school_outlined,
          route: AppRoutes.colleges,
        ),
      if (!progress.checkedScholarships)
        (
          title: 'Check Scholarships',
          subtitle: 'Explore funding opportunities and earn +40 XP.',
          icon: Icons.workspace_premium_outlined,
          route: AppRoutes.scholarships,
        ),
      if (catalogProvider.savedCollegeIds.isNotEmpty ||
          catalogProvider.savedScholarshipIds.isNotEmpty)
        (
          title: 'Saved Opportunities',
          subtitle:
              '${catalogProvider.savedCollegeIds.length} colleges & ${catalogProvider.savedScholarshipIds.length} scholarships bookmarked.',
          icon: Icons.bookmark_outline_rounded,
          route: AppRoutes.saved,
        ),
    ];

    showModalBottomSheet<void>(
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
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Career Updates',
                          style: textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      TextButton.icon(
                        onPressed: () {
                          Navigator.of(sheetContext).pop();
                          context.pushUnique(AppRoutes.settings);
                        },
                        icon: const Icon(Icons.settings_outlined, size: 18),
                        label: const Text('Settings'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                if (updates.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 14,
                    ),
                    child: Text(
                      'All key career milestones are complete! Check your XP Dashboard or open Settings.',
                      style: textTheme.bodyMedium?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  )
                else
                  Flexible(
                    child: ListView.separated(
                      shrinkWrap: true,
                      itemCount: updates.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final item = updates[index];
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
                                item.icon,
                                color: scheme.primary,
                                size: 20,
                              ),
                            ),
                            title: Text(
                              item.title,
                              style: textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            subtitle: Text(
                              item.subtitle,
                              style: textTheme.bodySmall?.copyWith(
                                color: scheme.onSurfaceVariant,
                              ),
                            ),
                            trailing: Icon(
                              Icons.arrow_forward_ios_rounded,
                              size: 14,
                              color: scheme.primary,
                            ),
                            onTap: () {
                              Navigator.of(sheetContext).pop();
                              context.pushUnique(item.route);
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
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final shadowColor = AppColors.cardShadow(Theme.of(context).brightness);
    final quizProvider = context.watch<QuizGamificationProvider>();
    final hasPendingSteps =
        !quizProvider.progress.completedQuiz ||
        !quizProvider.progress.exploredColleges ||
        !quizProvider.progress.checkedScholarships;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 4),
      child: Row(
        children: [
          if (showBackButton) ...[
            _CircleHeaderButton(
              tooltip: 'Back',
              shadowColor: shadowColor,
              onTap: onBack ?? () => context.safePop(),
              child: Icon(
                Icons.arrow_back_rounded,
                size: 20,
                color: scheme.primary,
              ),
            ),
            const SizedBox(width: 10),
          ],
          const CareerGuideLogo(),
          const Spacer(),
          // Exact Reference Notification Bell Circle with crisp red badge dot
          _CircleHeaderButton(
            tooltip: 'Notifications',
            shadowColor: shadowColor,
            onTap: () => _openNotificationsAndSettingsSheet(context),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(
                  Icons.notifications_none_rounded,
                  size: 24,
                  color: isDark ? scheme.onSurface : const Color(0xFF1A1630),
                ),
                if (hasPendingSteps)
                  Positioned(
                    right: -1,
                    top: -2,
                    child: Container(
                      width: 9,
                      height: 9,
                      decoration: BoxDecoration(
                        color: const Color(0xFFEF4444),
                        shape: BoxShape.circle,
                        border: Border.all(color: scheme.surface, width: 1.4),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          // Exact Reference Profile Circle (white rim + soft lavender disc + violet silhouette)
          _CircleHeaderButton(
            tooltip: 'Profile',
            shadowColor: shadowColor,
            onTap: () => context.pushUnique(AppRoutes.profile),
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: isDark
                    ? scheme.primaryContainer
                    : const Color(0xFFEFE7FF),
                shape: BoxShape.circle,
              ),
              clipBehavior: Clip.antiAlias,
              child: CustomPaint(
                painter: _ProfileSilhouettePainter(
                  color: isDark ? scheme.primary : const Color(0xFF7B3CE0),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CircleHeaderButton extends StatelessWidget {
  const _CircleHeaderButton({
    required this.tooltip,
    required this.shadowColor,
    required this.onTap,
    required this.child,
  });

  final String tooltip;
  final Color shadowColor;
  final VoidCallback onTap;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Tooltip(
      message: tooltip,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: scheme.surface,
          shape: BoxShape.circle,
          border: Border.all(color: scheme.outlineVariant.withAlpha(180)),
          boxShadow: [
            BoxShadow(
              color: shadowColor,
              blurRadius: 14,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          shape: const CircleBorder(),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            enableFeedback: false,
            onTap: onTap,
            child: Center(child: child),
          ),
        ),
      ),
    );
  }
}

class _ProfileSilhouettePainter extends CustomPainter {
  const _ProfileSilhouettePainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    final w = size.width;
    final h = size.height;

    // Head circle
    canvas.drawCircle(Offset(w * 0.50, h * 0.36), w * 0.175, paint);

    // Rounded shoulders bust sitting cleanly at bottom edge
    final shoulders = Path()
      ..moveTo(w * 0.16, h * 0.96)
      ..quadraticBezierTo(w * 0.18, h * 0.62, w * 0.50, h * 0.62)
      ..quadraticBezierTo(w * 0.82, h * 0.62, w * 0.84, h * 0.96)
      ..close();
    canvas.drawPath(shoulders, paint);
  }

  @override
  bool shouldRepaint(covariant _ProfileSilhouettePainter oldDelegate) =>
      oldDelegate.color != color;
}
