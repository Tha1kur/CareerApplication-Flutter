import 'dart:async';

import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../core/constants/app_routes.dart';
import '../core/router/app_navigation.dart';
import '../core/theme/app_colors.dart';
import '../core/utils/external_link_helper.dart';

class _ParentTip {
  const _ParentTip(this.title, this.body);
  final String title;
  final String body;
}

class _ParentResource {
  const _ParentResource(this.title, this.url);
  final String title;
  final String url;
}

/// Cohesive CareerGuide Lavender & White Parental Guidance screen:
/// - Secondary screen (no repeated brand top bar) starting with <- For Parents
/// - Rich violet hero banner, floating white expandable tips & official resource cards
class ParentalScreen extends StatelessWidget {
  const ParentalScreen({super.key});

  static const List<_ParentTip> _tips = [
    _ParentTip(
      'Start early & listen',
      'Have open conversations about what your child enjoys, their strengths and interests. Avoid forcing one single career path.',
    ),
    _ParentTip(
      'Focus on skills, not just marks',
      'Encourage projects, competitions, internships and communication practice. These matter more than marks alone.',
    ),
    _ParentTip(
      'Help explore options',
      'Use quizzes, visit colleges, talk to professionals and explore job videos together.',
    ),
    _ParentTip(
      'Mental health matters',
      'Reduce pressure. Help them balance study, hobbies, sleep and relaxation.',
    ),
    _ParentTip(
      'Financial planning',
      'Start planning early for college fees, scholarships and loans so money stress reduces.',
    ),
  ];

  static const List<_ParentResource> _resources = [
    _ParentResource('NCERT Career Guidance PDF', 'https://ncert.nic.in'),
    _ParentResource(
      'National Scholarship Portal',
      'https://scholarships.gov.in',
    ),
    _ParentResource(
      'MyGov – Career & Skill Initiatives',
      'https://www.mygov.in',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final brightness = Theme.of(context).brightness;
    final isDark = brightness == Brightness.dark;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: CustomPaint(
              painter: _ParentalBackdropPainter(isDark: isDark),
            ),
          ),
          SafeArea(
            child: ListView(
              padding: const EdgeInsets.only(bottom: 24),
              children: [
                const SizedBox(height: 8),

                // 1. Clean Secondary Top Row
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
                        child: Text(
                          'For Parents',
                          style: textTheme.headlineSmall?.copyWith(
                            fontSize: 22.5,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.5,
                            color: isDark
                                ? scheme.onSurface
                                : const Color(0xFF17122B),
                          ),
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
                          Icons.menu_book_rounded,
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

                // 2. Rich Violet Hero Banner
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  child: Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24),
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xFF5D26C6),
                          Color(0xFF7E3EE2),
                          Color(0xFF9757EE),
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF6B2FD0)
                              .withAlpha(isDark ? 70 : 58),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Support your child's career journey",
                          style: textTheme.titleLarge?.copyWith(
                            color: Colors.white,
                            fontSize: 19,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Use these tips & official resources to guide them without pressure.',
                          style: TextStyle(
                            color: Colors.white.withAlpha(235),
                            fontSize: 13.2,
                            height: 1.38,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    'Parenting tips',
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                for (final tip in _tips) ...[
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    child: _ExpandableTipCard(tip: tip),
                  ),
                  const SizedBox(height: 10),
                ],

                const SizedBox(height: 8),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    'Resources & PDFs',
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                for (final res in _resources) ...[
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    child: Container(
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: scheme.surface,
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(
                          color: scheme.outlineVariant.withAlpha(175),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.cardShadow(brightness),
                            blurRadius: 14,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 38,
                                height: 38,
                                decoration: BoxDecoration(
                                  color: isDark
                                      ? scheme.primaryContainer
                                      : const Color(0xFFF3ECFF),
                                  borderRadius: BorderRadius.circular(11),
                                ),
                                child: Icon(
                                  Icons.picture_as_pdf_rounded,
                                  size: 20,
                                  color: isDark
                                      ? scheme.primary
                                      : const Color(0xFF6B2FD0),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      res.title,
                                      style: textTheme.titleSmall?.copyWith(
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    Text(
                                      res.url,
                                      style: textTheme.bodySmall?.copyWith(
                                        color: scheme.onSurfaceVariant,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: FilledButton(
                                  onPressed: () => unawaited(
                                    launchExternalUrlSafely(context, res.url),
                                  ),
                                  style: FilledButton.styleFrom(
                                    enableFeedback: false,
                                    minimumSize: const Size(0, 42),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(13),
                                    ),
                                  ),
                                  child: const Text('Open'),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: () async {
                                    await Clipboard.setData(
                                      ClipboardData(text: res.url),
                                    );
                                    if (!context.mounted) return;
                                    ScaffoldMessenger.of(context)
                                      ..hideCurrentSnackBar()
                                      ..showSnackBar(
                                        const SnackBar(
                                          content: Text('Link copied'),
                                        ),
                                      );
                                  },
                                  style: OutlinedButton.styleFrom(
                                    enableFeedback: false,
                                    minimumSize: const Size(0, 42),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(13),
                                    ),
                                  ),
                                  child: const Text('Copy link'),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                ],

                const SizedBox(height: 8),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    'You can take the quiz with your child and review the results together.',
                    style: textTheme.bodySmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  child: Column(
                    children: [
                      Container(
                        width: double.infinity,
                        height: 48,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          gradient: const LinearGradient(
                            colors: [Color(0xFF5D26C6), Color(0xFF8344E4)],
                          ),
                        ),
                        child: Material(
                          color: Colors.transparent,
                          borderRadius: BorderRadius.circular(16),
                          clipBehavior: Clip.antiAlias,
                          child: InkWell(
                            enableFeedback: false,
                            onTap: () => context.push(AppRoutes.quiz),
                            child: const Center(
                              child: Text(
                                'Take quiz with your child',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14.5,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        width: double.infinity,
                        height: 46,
                        child: OutlinedButton(
                          onPressed: () => context.safePop(),
                          style: OutlinedButton.styleFrom(
                            enableFeedback: false,
                            backgroundColor: scheme.surface,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                          child: const Text(
                            'Back to Home',
                            style: TextStyle(fontWeight: FontWeight.w700),
                          ),
                        ),
                      ),
                    ],
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

class _ExpandableTipCard extends StatefulWidget {
  const _ExpandableTipCard({required this.tip});

  final _ParentTip tip;

  @override
  State<_ExpandableTipCard> createState() => _ExpandableTipCardState();
}

class _ExpandableTipCardState extends State<_ExpandableTipCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final brightness = Theme.of(context).brightness;
    final isDark = brightness == Brightness.dark;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: scheme.outlineVariant.withAlpha(175)),
        boxShadow: [
          BoxShadow(
            color: AppColors.cardShadow(brightness),
            blurRadius: 13,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          enableFeedback: false,
          onTap: () => setState(() => _expanded = !_expanded),
          child: AnimatedSize(
            duration: const Duration(milliseconds: 200),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          widget.tip.title,
                          style: textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w800,
                            fontSize: 14.5,
                          ),
                        ),
                      ),
                      Text(
                        _expanded ? 'Hide' : 'Read',
                        style: TextStyle(
                          fontSize: 12.5,
                          color: isDark
                              ? scheme.primary
                              : const Color(0xFF7433D6),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    widget.tip.body,
                    style: textTheme.bodySmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                      height: 1.38,
                    ),
                    maxLines: _expanded ? null : 2,
                    overflow: _expanded
                        ? TextOverflow.visible
                        : TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ParentalBackdropPainter extends CustomPainter {
  const _ParentalBackdropPainter({required this.isDark});

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
  }

  @override
  bool shouldRepaint(covariant _ParentalBackdropPainter oldDelegate) =>
      oldDelegate.isDark != isDark;
}
