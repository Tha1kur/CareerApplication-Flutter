import 'dart:math' as math;

import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

import '../core/constants/app_routes.dart';
import '../core/theme/app_colors.dart';
import '../providers/profile_provider.dart';
import '../providers/quiz_gamification_provider.dart';
import '../widgets/career_guide_top_bar.dart';
import '../widgets/duotone_icons.dart';
import '../widgets/floating_bottom_nav.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  void _openMoreModulesSheet(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      backgroundColor: scheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (sheetContext) {
        final items = [
          (
            title: 'Application Tracker',
            subtitle: 'Manage scholarship stages, checklists & notes',
            icon: Icons.assignment_turned_in_rounded,
            route: AppRoutes.applicationTracker,
          ),
          (
            title: 'Student & Mentor Community',
            subtitle: 'Browse sample Q&A threads or ask locally',
            icon: Icons.forum_rounded,
            route: AppRoutes.community,
          ),
          (
            title: 'Compare Colleges',
            subtitle: 'Compare up to 3 institutes side by side',
            icon: Icons.compare_arrows_rounded,
            route: AppRoutes.compare,
          ),
          (
            title: 'XP & Badges Dashboard',
            subtitle: 'Track levels, XP milestones & earned badges',
            icon: Icons.emoji_events_rounded,
            route: AppRoutes.dashboard,
          ),
          (
            title: 'Quiz Results & History',
            subtitle: 'Review your career score breakdown & past attempts',
            icon: Icons.analytics_rounded,
            route: AppRoutes.results,
          ),
          (
            title: 'Parental Guidance',
            subtitle: 'Tips & official career resources for parents',
            icon: Icons.menu_book_rounded,
            route: AppRoutes.parental,
          ),
          (
            title: 'Settings',
            subtitle: 'Theme appearance & local data controls',
            icon: Icons.settings_outlined,
            route: AppRoutes.settings,
          ),
        ];

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
                    'More CareerGuide Tools',
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Flexible(
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: items.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final item = items[index];
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
                            context.push(item.route);
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
    final quizProvider = context.watch<QuizGamificationProvider>();
    final profile = context.watch<ProfileProvider>().profile;
    final progress = quizProvider.progress;
    final scheme = Theme.of(context).colorScheme;
    final brightness = Theme.of(context).brightness;
    final isDark = brightness == Brightness.dark;
    final textTheme = Theme.of(context).textTheme;

    final userName = profile.name.trim().isNotEmpty
        ? profile.name.trim()
        : 'Explorer';
    final savedCareerTitle = quizProvider.savedCareerTitle;

    // Real 5-step career journey progress derived strictly from local state
    final stepsDone = [
      !profile.isEmpty,
      progress.completedQuiz,
      quizProvider.savedCareerKey.isNotEmpty,
      progress.exploredColleges,
      progress.checkedScholarships,
    ].where((done) => done).length;
    final progressFraction = stepsDone / 5.0;
    final progressPercent = (progressFraction * 100).round();

    final nextRoute = !progress.completedQuiz
        ? AppRoutes.quiz
        : quizProvider.savedCareerKey.isEmpty
        ? AppRoutes.recommendations
        : !progress.exploredColleges
        ? AppRoutes.colleges
        : !progress.checkedScholarships
        ? AppRoutes.scholarships
        : AppRoutes.dashboard;

    final assessmentTitle = !progress.completedQuiz
        ? 'Continue Your Assessment'
        : savedCareerTitle.isNotEmpty
        ? 'Saved: $savedCareerTitle'
        : 'Review Your Match Results';
    final assessmentSubtitle = !progress.completedQuiz
        ? 'Complete your aptitude quiz to\nunlock personalized career paths.'
        : 'Explore your score breakdown,\nhistory & tailored AI roadmap.';
    final assessmentRoute = !progress.completedQuiz
        ? AppRoutes.quiz
        : AppRoutes.results;

    return Scaffold(
      extendBody: true,
      bottomNavigationBar: FloatingBottomNav(
        currentTab: CareerGuideTab.home,
        onExploreTap: () => _openMoreModulesSheet(context),
      ),
      body: Stack(
        children: [
          // Soft Lavender-White Background + Organic Reference Patterns
          Positioned.fill(
            child: CustomPaint(painter: _HomeBackdropPainter(isDark: isDark)),
          ),
          SafeArea(
            bottom: false,
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 92),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Exact Reference Top Bar (larger logo + notification bell + profile disc)
                  const CareerGuideTopBar(),

                  // 2. Greeting Hero + Fixed Reference Student (sits flush above progress card)
                  SizedBox(
                    height: 136,
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        // Subtle light-lavender organic pattern right behind the student
                        Positioned(
                          right: 6,
                          bottom: 0,
                          width: 172,
                          height: 126,
                          child: CustomPaint(
                            painter: _StudentBackdropPainter(isDark: isDark),
                          ),
                        ),
                        // Left greeting copy (no waving hand emoji, exact 3-line break)
                        Positioned(
                          left: 18,
                          top: 12,
                          right: 140,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              RichText(
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                text: TextSpan(
                                  style: textTheme.headlineSmall?.copyWith(
                                    fontSize: 25.5,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: -0.6,
                                    height: 1.15,
                                  ),
                                  children: [
                                    TextSpan(
                                      text: 'Hello, ',
                                      style: TextStyle(
                                        color: isDark
                                            ? scheme.onSurface
                                            : const Color(0xFF17122B),
                                      ),
                                    ),
                                    TextSpan(
                                      text: '$userName!',
                                      style: TextStyle(
                                        color: isDark
                                            ? scheme.primary
                                            : const Color(0xFF7433D6),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'Continue your career journey\nand explore the right opportunities\nfor your future.',
                                style: textTheme.bodySmall?.copyWith(
                                  color: isDark
                                      ? scheme.onSurfaceVariant
                                      : const Color(0xFF4A4560),
                                  height: 1.36,
                                  fontSize: 13.2,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Right fixed student illustration sitting flush on purple card edge
                        Positioned(
                          right: 12,
                          bottom: 0,
                          width: 142,
                          height: 136,
                          child: Image.asset(
                            'assets/images/home_student.png',
                            fit: BoxFit.contain,
                            alignment: Alignment.bottomRight,
                            errorBuilder: (_, _, _) => const SizedBox.shrink(),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // 3. Exact Rich Violet "Your Career Progress" Card
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 15,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(24),
                        gradient: const LinearGradient(
                          colors: [
                            Color(0xFF5D26C6),
                            Color(0xFF7E3EE2),
                            Color(0xFF9757EE),
                          ],
                          stops: [0.0, 0.52, 1.0],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF6B2FD0)
                                .withAlpha(isDark ? 72 : 60),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          _ProgressRing(
                            fraction: progressFraction,
                            label: '$progressPercent%',
                          ),
                          const SizedBox(width: 12),
                          Container(
                            width: 1,
                            height: 44,
                            color: Colors.white.withAlpha(55),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Your Career Progress',
                                  style: textTheme.titleSmall?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 15,
                                    letterSpacing: -0.2,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '$stepsDone of 5 key steps completed',
                                  style: textTheme.bodySmall?.copyWith(
                                    color: Colors.white.withAlpha(225),
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Material(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(22),
                            clipBehavior: Clip.antiAlias,
                            child: InkWell(
                              enableFeedback: false,
                              onTap: () => context.push(nextRoute),
                              child: const Padding(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 10,
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      'Continue',
                                      style: TextStyle(
                                        color: Color(0xFF6729CC),
                                        fontSize: 12.8,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                    SizedBox(width: 4),
                                    Icon(
                                      Icons.arrow_forward_rounded,
                                      size: 14.5,
                                      color: Color(0xFF6729CC),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // 4. Exact 3x2 White Feature Cards Grid (padding: EdgeInsets.zero removes extra bottom gap!)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    child: GridView.count(
                      padding: EdgeInsets.zero,
                      crossAxisCount: 3,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      childAspectRatio: 0.85,
                      children: [
                        _HomeGridCard(
                          title: 'Aptitude Quiz',
                          subtitle: 'Discover your strengths',
                          iconKind: DuotoneIconKind.aptitudeQuiz,
                          onTap: () => context.push(AppRoutes.quiz),
                        ),
                        _HomeGridCard(
                          title: 'Career Paths',
                          subtitle: 'Get personalized\nrecommendations',
                          iconKind: DuotoneIconKind.careerPaths,
                          onTap: () => context.push(AppRoutes.recommendations),
                        ),
                        _HomeGridCard(
                          title: 'Colleges',
                          subtitle: 'Explore & compare\ncolleges',
                          iconKind: DuotoneIconKind.colleges,
                          onTap: () => context.push(AppRoutes.colleges),
                        ),
                        _HomeGridCard(
                          title: 'Scholarships',
                          subtitle: 'Find funding\nopportunities',
                          iconKind: DuotoneIconKind.scholarships,
                          onTap: () => context.push(AppRoutes.scholarships),
                        ),
                        _HomeGridCard(
                          title: 'AI Career Mentor',
                          subtitle: 'Your personal\ncareer guide',
                          iconKind: DuotoneIconKind.aiMentor,
                          onTap: () => context.push(AppRoutes.aiMentor),
                        ),
                        _HomeGridCard(
                          title: 'More',
                          subtitle: 'Tracker, Community\nand more',
                          iconKind: DuotoneIconKind.moreModules,
                          onTap: () => _openMoreModulesSheet(context),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),

                  // 5. Exact "Continue Your Assessment" Card (tight gap, inner lavender surface, vertical divider, fixed books)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    child: Container(
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        color: scheme.surface,
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(
                          color: scheme.outlineVariant.withAlpha(180),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.cardShadow(brightness),
                            blurRadius: 16,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(17),
                        child: CustomPaint(
                          painter: _AssessmentCardBackdropPainter(
                            isDark: isDark,
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              enableFeedback: false,
                              onTap: () => context.push(assessmentRoute),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 11,
                                ),
                                child: Row(
                                  children: [
                                    SizedBox(
                                      width: 72,
                                      height: 52,
                                      child: Image.asset(
                                        'assets/images/home_books.png',
                                        fit: BoxFit.contain,
                                        errorBuilder: (_, _, _) => Icon(
                                          Icons.menu_book_rounded,
                                          color: scheme.primary,
                                          size: 32,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Container(
                                      width: 1,
                                      height: 44,
                                      color: isDark
                                          ? Colors.white.withAlpha(32)
                                          : const Color(0xFFDAD0F4),
                                    ),
                                    const SizedBox(width: 11),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            assessmentTitle,
                                            style: textTheme.titleSmall
                                                ?.copyWith(
                                                  fontWeight: FontWeight.w800,
                                                  fontSize: 14.8,
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
                                            assessmentSubtitle,
                                            style: textTheme.bodySmall
                                                ?.copyWith(
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
                                    const SizedBox(width: 10),
                                    Container(
                                      width: 42,
                                      height: 42,
                                      decoration: BoxDecoration(
                                        gradient: const LinearGradient(
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                          colors: [
                                            Color(0xFF8C4DF0),
                                            Color(0xFF6629CC),
                                          ],
                                        ),
                                        borderRadius: BorderRadius.circular(13),
                                      ),
                                      child: const Icon(
                                        Icons.arrow_forward_rounded,
                                        color: Colors.white,
                                        size: 20,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HomeGridCard extends StatelessWidget {
  const _HomeGridCard({
    required this.title,
    required this.subtitle,
    required this.iconKind,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final DuotoneIconKind iconKind;
  final VoidCallback onTap;

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
        border: Border.all(color: scheme.outlineVariant.withAlpha(170)),
        boxShadow: [
          BoxShadow(
            color: AppColors.cardShadow(brightness),
            blurRadius: 16,
            offset: const Offset(0, 6),
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
            padding: const EdgeInsets.fromLTRB(6, 8, 6, 8),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                DuotoneFeatureIcon(kind: iconKind, size: 60),
                const SizedBox(height: 6),
                Text(
                  title,
                  style: textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                    fontSize: 13.0,
                    letterSpacing: -0.25,
                    color: isDark ? scheme.onSurface : const Color(0xFF17122B),
                    height: 1.12,
                  ),
                  textAlign: TextAlign.center,
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
                    fontSize: 10.8,
                    height: 1.22,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ProgressRing extends StatelessWidget {
  const _ProgressRing({required this.fraction, required this.label});

  final double fraction;
  final String label;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 62,
      height: 62,
      child: CustomPaint(
        painter: _WhiteRingPainter(progress: fraction),
        child: Center(
          child: Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15.5,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.3,
            ),
          ),
        ),
      ),
    );
  }
}

class _WhiteRingPainter extends CustomPainter {
  const _WhiteRingPainter({required this.progress});

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    const strokeWidth = 7.0;
    final rect = Rect.fromLTWH(
      strokeWidth / 2,
      strokeWidth / 2,
      size.width - strokeWidth,
      size.height - strokeWidth,
    );

    canvas.drawArc(
      rect,
      -math.pi / 2,
      math.pi * 2,
      false,
      Paint()
        ..color = Colors.white.withAlpha(65)
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth,
    );

    if (progress > 0) {
      canvas.drawArc(
        rect,
        -math.pi / 2,
        math.pi * 2 * progress.clamp(0.0, 1.0),
        false,
        Paint()
          ..color = const Color(0xFFEBCFFF)
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeWidth
          ..strokeCap = StrokeCap.round,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _WhiteRingPainter oldDelegate) =>
      oldDelegate.progress != progress;
}

/// Exact organic lavender background curves matching the reference:
/// - Soft pastel lavender swoosh behind CareerGuide top-left logo
/// - Gentle full-screen lavender-white gradient base
class _HomeBackdropPainter extends CustomPainter {
  const _HomeBackdropPainter({required this.isDark});

  final bool isDark;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final bgPaint = Paint()
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
      ).createShader(rect);
    canvas.drawRect(rect, bgPaint);

    // Top-left pastel lavender curve behind CareerGuide logo
    final topLeftWave = Path()
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
      topLeftWave,
      Paint()
        ..color = isDark
            ? const Color(0xFF281F4A).withAlpha(140)
            : const Color(0xFFEBE1FF).withAlpha(185),
    );

    // Subtle soft diagonal lavender glow across upper right hero
    final upperRightGlow = Path()
      ..moveTo(size.width * 0.36, size.height * 0.32)
      ..quadraticBezierTo(
        size.width * 0.65,
        size.height * 0.10,
        size.width,
        size.height * 0.06,
      )
      ..lineTo(size.width, size.height * 0.32)
      ..close();
    canvas.drawPath(
      upperRightGlow,
      Paint()
        ..color = isDark
            ? const Color(0xFF231B42).withAlpha(130)
            : const Color(0xFFEFE7FF).withAlpha(155),
    );
  }

  @override
  bool shouldRepaint(covariant _HomeBackdropPainter oldDelegate) =>
      oldDelegate.isDark != isDark;
}

/// Soft pastel light-lavender organic pattern right behind the student hero.
class _StudentBackdropPainter extends CustomPainter {
  const _StudentBackdropPainter({required this.isDark});

  final bool isDark;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final blob = Path()
      ..moveTo(w * 0.06, h)
      ..cubicTo(w * 0.02, h * 0.62, w * 0.24, h * 0.34, w * 0.56, h * 0.30)
      ..cubicTo(w * 0.88, h * 0.26, w * 1.02, h * 0.50, w * 0.96, h)
      ..close();

    canvas.drawPath(
      blob,
      Paint()
        ..color = isDark
            ? const Color(0xFF31245E).withAlpha(155)
            : const Color(0xFFE6DCFE).withAlpha(220),
    );
  }

  @override
  bool shouldRepaint(covariant _StudentBackdropPainter oldDelegate) =>
      oldDelegate.isDark != isDark;
}

/// Inner lavender surface + subtle bottom-right diagonal wave inside "Continue Your Assessment" card.
class _AssessmentCardBackdropPainter extends CustomPainter {
  const _AssessmentCardBackdropPainter({required this.isDark});

  final bool isDark;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    canvas.drawRect(
      rect,
      Paint()
        ..color = isDark ? const Color(0xFF231C42) : const Color(0xFFF6F2FF),
    );

    final wave = Path()
      ..moveTo(size.width * 0.68, size.height)
      ..quadraticBezierTo(
        size.width * 0.80,
        size.height * 0.38,
        size.width,
        size.height * 0.16,
      )
      ..lineTo(size.width, size.height)
      ..close();
    canvas.drawPath(
      wave,
      Paint()
        ..color = isDark
            ? const Color(0xFF2F2557).withAlpha(150)
            : const Color(0xFFECE3FE).withAlpha(200),
    );
  }

  @override
  bool shouldRepaint(covariant _AssessmentCardBackdropPainter oldDelegate) =>
      oldDelegate.isDark != isDark;
}
