import 'dart:async';
import 'dart:math' as math;

import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

import '../core/constants/app_routes.dart';
import '../core/theme/app_colors.dart';
import '../core/utils/external_link_helper.dart';
import '../models/college.dart';
import '../models/scholarship.dart';
import '../providers/catalog_provider.dart';
import '../providers/quiz_gamification_provider.dart';
import '../services/scoring_service.dart';
import '../widgets/career_guide_top_bar.dart';
import '../widgets/empty_state_view.dart';

enum _SavedFilter { all, colleges, scholarships }

/// Exact reference CareerGuide Saved Opportunities screen (PDF Page 8):
/// - Root bottom-nav tab with CareerGuideTopBar & PopScope back-to-Home
/// - Fixed bookmark-with-star hero illustration (zero floating, zero 3-line sparkles)
/// - Pill filter tabs (All / Colleges / Scholarships) backed by real persistent IDs
/// - Reference-styled white cards with category pill, filled violet bookmark & quick-action menu
class SavedScreen extends StatefulWidget {
  const SavedScreen({super.key});

  @override
  State<SavedScreen> createState() => _SavedScreenState();
}

class _SavedScreenState extends State<SavedScreen> {
  _SavedFilter _filter = _SavedFilter.all;

  @override
  Widget build(BuildContext context) {
    final catalog = context.watch<CatalogProvider>();
    final quizProvider = context.watch<QuizGamificationProvider>();
    final savedColleges = catalog.savedColleges;
    final savedScholarships = catalog.savedScholarships;
    final savedCareerKey = quizProvider.savedCareerKey;
    final savedCareerInfo = savedCareerKey.isNotEmpty
        ? ScoringService.careerCatalog[savedCareerKey]
        : null;

    final scheme = Theme.of(context).colorScheme;
    final brightness = Theme.of(context).brightness;
    final isDark = brightness == Brightness.dark;
    final textTheme = Theme.of(context).textTheme;

    final showCareer = _filter == _SavedFilter.all && savedCareerInfo != null;
    final visibleColleges = _filter == _SavedFilter.scholarships
        ? const <College>[]
        : savedColleges;
    final visibleScholarships = _filter == _SavedFilter.colleges
        ? const <Scholarship>[]
        : savedScholarships;
    final isEmpty =
        !showCareer && visibleColleges.isEmpty && visibleScholarships.isEmpty;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) context.go(AppRoutes.home);
      },
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Stack(
          children: [
            Positioned.fill(
              child: CustomPaint(
                painter: _SavedBackdropPainter(isDark: isDark),
              ),
            ),
            SafeArea(
              bottom: false,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Brand Top Bar (primary bottom-nav screen)
                  const CareerGuideTopBar(),

                  // 2. Hero Header: "Saved" + Fixed Bookmark-Star Illustration
                  SizedBox(
                    height: 112,
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Positioned(
                          right: 6,
                          bottom: 0,
                          width: 152,
                          height: 108,
                          child: CustomPaint(
                            painter: _BookmarkBlobPainter(isDark: isDark),
                          ),
                        ),
                        Positioned(
                          left: 18,
                          top: 12,
                          right: 138,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Saved Opportunities',
                                style: textTheme.headlineSmall?.copyWith(
                                  fontSize: 22.5,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: -0.5,
                                  color: isDark
                                      ? scheme.onSurface
                                      : const Color(0xFF17122B),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 5),
                              Text(
                                'All your saved colleges,\nscholarships and paths in one place.',
                                style: textTheme.bodySmall?.copyWith(
                                  color: isDark
                                      ? scheme.onSurfaceVariant
                                      : const Color(0xFF4A4560),
                                  fontSize: 12.8,
                                  height: 1.35,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Positioned(
                          right: 14,
                          bottom: 0,
                          width: 118,
                          height: 106,
                          child: CustomPaint(
                            painter: _SavedBookmarkArtPainter(isDark: isDark),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 6),

                  // 3. Exact Reference Pill Category Filter Row
                  SizedBox(
                    height: 40,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      children: [
                        _SavedPillTab(
                          label: 'All',
                          selected: _filter == _SavedFilter.all,
                          onTap: () =>
                              setState(() => _filter = _SavedFilter.all),
                        ),
                        const SizedBox(width: 9),
                        _SavedPillTab(
                          label: 'Colleges (${savedColleges.length})',
                          icon: Icons.account_balance_rounded,
                          selected: _filter == _SavedFilter.colleges,
                          onTap: () =>
                              setState(() => _filter = _SavedFilter.colleges),
                        ),
                        const SizedBox(width: 9),
                        _SavedPillTab(
                          label: 'Scholarships (${savedScholarships.length})',
                          icon: Icons.workspace_premium_rounded,
                          selected: _filter == _SavedFilter.scholarships,
                          onTap: () => setState(
                            () => _filter = _SavedFilter.scholarships,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),

                  // 4. Saved Items List or Clean Empty State
                  Expanded(
                    child: isEmpty
                        ? Padding(
                            padding: const EdgeInsets.only(bottom: 92),
                            child: EmptyStateView(
                              icon: _filter == _SavedFilter.scholarships
                                  ? Icons.workspace_premium_rounded
                                  : Icons.bookmark_border_rounded,
                              title: _filter == _SavedFilter.colleges
                                  ? 'No saved colleges yet'
                                  : _filter == _SavedFilter.scholarships
                                  ? 'No saved scholarships yet'
                                  : 'No saved opportunities yet',
                              subtitle: _filter == _SavedFilter.scholarships
                                  ? 'Bookmark scholarships to track grants, eligibility, and deadlines.'
                                  : 'Bookmark colleges, scholarships, or a career path to see them here.',
                              actionLabel: _filter == _SavedFilter.scholarships
                                  ? 'Browse Scholarships'
                                  : 'Explore Colleges',
                              onAction: () => context.push(
                                _filter == _SavedFilter.scholarships
                                    ? AppRoutes.scholarships
                                    : AppRoutes.colleges,
                              ),
                            ),
                          )
                        : ListView(
                            padding: const EdgeInsets.fromLTRB(14, 0, 14, 102),
                            children: [
                              if (showCareer) ...[
                                _ReferenceSavedCard(
                                  badge: 'Career',
                                  title: savedCareerInfo.title,
                                  subtitle: savedCareerInfo.shortDescription,
                                  icon: Icons.school_rounded,
                                  onTap: () => context.push(
                                    AppRoutes.recommendationsWithCareer(
                                      savedCareerInfo.key,
                                    ),
                                  ),
                                  onRemove: () => unawaited(
                                    quizProvider.saveCareerPath(''),
                                  ),
                                  menuItems: const [
                                    PopupMenuItem(
                                      value: 'view',
                                      child: Text('View Career Path'),
                                    ),
                                    PopupMenuItem(
                                      value: 'mentor',
                                      child: Text('Open AI Roadmap'),
                                    ),
                                  ],
                                  onMenuSelected: (value) {
                                    if (value == 'view') {
                                      context.push(
                                        AppRoutes.recommendationsWithCareer(
                                          savedCareerInfo.key,
                                        ),
                                      );
                                    } else if (value == 'mentor') {
                                      context.push(AppRoutes.aiMentor);
                                    }
                                  },
                                ),
                                const SizedBox(height: 11),
                              ],
                              for (final college in visibleColleges) ...[
                                _ReferenceSavedCard(
                                  badge: 'College',
                                  title: college.name,
                                  subtitle:
                                      '${college.formattedLocation}${college.rank != null ? ' • Rank #${college.rank}' : ''}${(college.avgFees ?? '').isNotEmpty ? ' • ${college.avgFees}' : ''}',
                                  icon: Icons.account_balance_rounded,
                                  onTap: () => context.push(
                                    AppRoutes.collegeDetails(college.id),
                                  ),
                                  onRemove: () => unawaited(
                                    catalog.toggleSavedCollege(college.id),
                                  ),
                                  menuItems: const [
                                    PopupMenuItem(
                                      value: 'details',
                                      child: Text('View Details'),
                                    ),
                                    PopupMenuItem(
                                      value: 'compare',
                                      child: Text('Compare'),
                                    ),
                                    PopupMenuItem(
                                      value: 'remove',
                                      child: Text('Remove Bookmark'),
                                    ),
                                  ],
                                  onMenuSelected: (value) {
                                    if (value == 'details') {
                                      context.push(
                                        AppRoutes.collegeDetails(college.id),
                                      );
                                    } else if (value == 'compare') {
                                      context.push(
                                        AppRoutes.compareWithIds([college.id]),
                                      );
                                    } else if (value == 'remove') {
                                      unawaited(
                                        catalog.toggleSavedCollege(college.id),
                                      );
                                    }
                                  },
                                ),
                                const SizedBox(height: 11),
                              ],
                              for (final s in visibleScholarships) ...[
                                _ReferenceSavedCard(
                                  badge: s.isHistoricalSample
                                      ? 'Scholarship • 2025 Sample'
                                      : 'Scholarship',
                                  title: s.name,
                                  subtitle:
                                      '${s.category} • Grant: ${s.amount ?? 'Varies'} • Deadline: ${s.deadline ?? 'Rolling'}',
                                  icon: Icons.workspace_premium_rounded,
                                  onTap: () =>
                                      context.push(AppRoutes.scholarships),
                                  onRemove: () => unawaited(
                                    catalog.toggleSavedScholarship(s.id),
                                  ),
                                  menuItems: const [
                                    PopupMenuItem(
                                      value: 'tracker',
                                      child: Text('Open Tracker'),
                                    ),
                                    PopupMenuItem(
                                      value: 'apply',
                                      child: Text('Apply Link'),
                                    ),
                                    PopupMenuItem(
                                      value: 'remove',
                                      child: Text('Remove Bookmark'),
                                    ),
                                  ],
                                  onMenuSelected: (value) {
                                    if (value == 'tracker') {
                                      context.push(
                                        AppRoutes.applicationTracker,
                                      );
                                    } else if (value == 'apply') {
                                      unawaited(
                                        launchExternalUrlSafely(
                                          context,
                                          s.applyLink ?? '',
                                        ),
                                      );
                                    } else if (value == 'remove') {
                                      unawaited(
                                        catalog.toggleSavedScholarship(s.id),
                                      );
                                    }
                                  },
                                ),
                                const SizedBox(height: 11),
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
    );
  }
}

class _SavedPillTab extends StatelessWidget {
  const _SavedPillTab({
    required this.label,
    required this.selected,
    required this.onTap,
    this.icon,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final brightness = Theme.of(context).brightness;
    final isDark = brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: selected
            ? (isDark ? scheme.primary : const Color(0xFF7433D6))
            : scheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: selected
              ? Colors.transparent
              : scheme.outlineVariant.withAlpha(180),
        ),
        boxShadow: selected
            ? [
                BoxShadow(
                  color: const Color(0xFF6B2FD0).withAlpha(48),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ]
            : [
                BoxShadow(
                  color: AppColors.cardShadow(brightness),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          enableFeedback: false,
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (icon != null) ...[
                  Icon(
                    icon,
                    size: 16,
                    color: selected
                        ? Colors.white
                        : (isDark ? scheme.primary : const Color(0xFF6B2FD0)),
                  ),
                  const SizedBox(width: 6),
                ],
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12.6,
                    fontWeight: FontWeight.w700,
                    color: selected
                        ? Colors.white
                        : (isDark ? scheme.onSurface : const Color(0xFF2F2A46)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ReferenceSavedCard extends StatelessWidget {
  const _ReferenceSavedCard({
    required this.badge,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
    required this.onRemove,
    required this.menuItems,
    required this.onMenuSelected,
  });

  final String badge;
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;
  final VoidCallback onRemove;
  final List<PopupMenuEntry<String>> menuItems;
  final ValueChanged<String> onMenuSelected;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final brightness = Theme.of(context).brightness;
    final isDark = brightness == Brightness.dark;
    final textTheme = Theme.of(context).textTheme;

    return Container(
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
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(22),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          enableFeedback: false,
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(13, 13, 8, 13),
            child: Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: isDark
                        ? scheme.primaryContainer
                        : const Color(0xFFF3ECFF),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Icon(
                    icon,
                    size: 26,
                    color: isDark ? scheme.primary : const Color(0xFF6B2FD0),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2.5,
                        ),
                        decoration: BoxDecoration(
                          color: isDark
                              ? scheme.primaryContainer
                              : const Color(0xFFF0E8FF),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          badge,
                          style: TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w700,
                            color: isDark
                                ? scheme.primary
                                : const Color(0xFF6B2FD0),
                          ),
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        title,
                        style: textTheme.titleSmall?.copyWith(
                          fontSize: 14.8,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.2,
                          color: isDark
                              ? scheme.onSurface
                              : const Color(0xFF17122B),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 3),
                      Text(
                        subtitle,
                        style: textTheme.bodySmall?.copyWith(
                          color: isDark
                              ? scheme.onSurfaceVariant
                              : const Color(0xFF56506E),
                          fontSize: 12,
                          height: 1.32,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 4),
                IconButton(
                  tooltip: 'Remove from saved',
                  visualDensity: VisualDensity.compact,
                  onPressed: onRemove,
                  icon: Icon(
                    Icons.bookmark_rounded,
                    size: 22,
                    color: isDark ? scheme.primary : const Color(0xFF7433D6),
                  ),
                ),
                PopupMenuButton<String>(
                  tooltip: 'More options',
                  padding: EdgeInsets.zero,
                  icon: Icon(
                    Icons.more_vert_rounded,
                    size: 20,
                    color: scheme.onSurfaceVariant,
                  ),
                  onSelected: onMenuSelected,
                  itemBuilder: (_) => menuItems,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SavedBackdropPainter extends CustomPainter {
  const _SavedBackdropPainter({required this.isDark});

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

    final topLeft = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width * 0.44, 0)
      ..quadraticBezierTo(
        size.width * 0.24,
        size.height * 0.08,
        0,
        size.height * 0.14,
      )
      ..close();
    canvas.drawPath(
      topLeft,
      Paint()
        ..color = isDark
            ? const Color(0xFF281F4A).withAlpha(140)
            : const Color(0xFFEBE1FF).withAlpha(185),
    );
  }

  @override
  bool shouldRepaint(covariant _SavedBackdropPainter oldDelegate) =>
      oldDelegate.isDark != isDark;
}

class _BookmarkBlobPainter extends CustomPainter {
  const _BookmarkBlobPainter({required this.isDark});

  final bool isDark;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final blob = Path()
      ..moveTo(w * 0.12, h)
      ..cubicTo(w * 0.04, h * 0.48, w * 0.24, h * 0.18, w * 0.62, h * 0.22)
      ..cubicTo(w * 0.92, h * 0.25, w * 1.02, h * 0.56, w * 0.92, h)
      ..close();
    canvas.drawPath(
      blob,
      Paint()
        ..color = isDark
            ? const Color(0xFF31245E).withAlpha(155)
            : const Color(0xFFE6DCFE).withAlpha(215),
    );
  }

  @override
  bool shouldRepaint(covariant _BookmarkBlobPainter oldDelegate) =>
      oldDelegate.isDark != isDark;
}

/// Exact reference 3D Bookmark card with golden star & side lavender sprigs (PDF Page 8, zero 3-line sparkles).
class _SavedBookmarkArtPainter extends CustomPainter {
  const _SavedBookmarkArtPainter({required this.isDark});

  final bool isDark;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Botanical purple/lavender sprigs behind card
    final darkLeaf = Paint()
      ..color = isDark ? const Color(0xFF5A4296) : const Color(0xFF7B57C9);
    final lightLeaf = Paint()
      ..color = isDark ? const Color(0xFF7B5EC4) : const Color(0xFFA78DF0);

    void drawLeaf(
      Offset base,
      double angle,
      double len,
      double width,
      Paint paint,
    ) {
      canvas.save();
      canvas.translate(base.dx, base.dy);
      canvas.rotate(angle);
      final p = Path()
        ..moveTo(0, 0)
        ..quadraticBezierTo(-width, -len * 0.48, 0, -len)
        ..quadraticBezierTo(width, -len * 0.48, 0, 0)
        ..close();
      canvas.drawPath(p, paint);
      canvas.restore();
    }

    drawLeaf(Offset(w * 0.22, h * 0.90), -0.82, h * 0.30, w * 0.055, darkLeaf);
    drawLeaf(Offset(w * 0.24, h * 0.90), -0.45, h * 0.36, w * 0.055, lightLeaf);
    drawLeaf(Offset(w * 0.78, h * 0.90), 0.55, h * 0.38, w * 0.058, lightLeaf);
    drawLeaf(Offset(w * 0.80, h * 0.90), 0.95, h * 0.28, w * 0.052, darkLeaf);

    // 3D book/card back edge (rich violet side thickness)
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.24, h * 0.22, w * 0.58, h * 0.70),
        Radius.circular(w * 0.12),
      ),
      Paint()..color = const Color(0xFF7C4CE0),
    );

    // Front soft white-lavender book cover face
    final coverRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(w * 0.21, h * 0.17, w * 0.57, h * 0.72),
      Radius.circular(w * 0.12),
    );
    canvas.drawRRect(
      coverRect,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? const [Color(0xFF33275E), Color(0xFF251C47)]
              : const [Color(0xFFFFFFFF), Color(0xFFEDE4FF)],
        ).createShader(coverRect.outerRect),
    );
    canvas.drawRRect(
      coverRect,
      Paint()
        ..color = isDark ? const Color(0xFF5A4296) : const Color(0xFFD9C8FA)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.6,
    );

    // Violet notched bookmark ribbon draped over top edge
    final ribbon = Path()
      ..moveTo(w * 0.36, h * 0.11)
      ..lineTo(w * 0.63, h * 0.11)
      ..lineTo(w * 0.63, h * 0.53)
      ..lineTo(w * 0.495, h * 0.44)
      ..lineTo(w * 0.36, h * 0.53)
      ..close();
    canvas.drawPath(
      ribbon,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF8B52F0), Color(0xFF5D26C6)],
        ).createShader(Rect.fromLTWH(w * 0.36, h * 0.11, w * 0.27, h * 0.43)),
    );

    // Bright warm golden-amber 5-point star centered below bookmark
    final center = Offset(w * 0.495, h * 0.67);
    final outerR = w * 0.13;
    final innerR = w * 0.058;
    final star = Path();
    for (var i = 0; i < 10; i++) {
      final angle = -math.pi / 2 + i * math.pi / 5;
      final r = i.isEven ? outerR : innerR;
      final x = center.dx + math.cos(angle) * r;
      final y = center.dy + math.sin(angle) * r;
      if (i == 0) {
        star.moveTo(x, y);
      } else {
        star.lineTo(x, y);
      }
    }
    star.close();
    canvas.drawPath(star, Paint()..color = const Color(0xFFF59E0B));
  }

  @override
  bool shouldRepaint(covariant _SavedBookmarkArtPainter oldDelegate) =>
      oldDelegate.isDark != isDark;
}
