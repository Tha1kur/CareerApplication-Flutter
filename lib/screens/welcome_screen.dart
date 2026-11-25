import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

import '../app.dart';
import '../core/constants/app_routes.dart';
import '../core/theme/app_colors.dart';

/// Exact reference CareerGuide Welcome screen (PDF Page 2 Right):
/// - No pagination dots (single welcome screen only)
/// - Top-right "Skip" action
/// - Left-aligned "Discover Your / Right Career Path" + exact 3-line subtitle
/// - Centered fixed student & educational symbols illustration (no floating, no 3-line sparkles)
/// - Full-width violet gradient "Get Started ->" button + "Already have a profile? Continue"
class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  Future<void> _completeAndGo(BuildContext context, String route) async {
    final deps = context.read<AppDependencies>();
    await deps.storage.setHasSeenWelcome(true);
    if (!context.mounted) return;
    context.go(route);
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: CustomPaint(
              painter: _WelcomeBackdropPainter(isDark: isDark),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top row: NO pagination dots, crisp Skip button right
                  Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Material(
                          color: Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                          clipBehavior: Clip.antiAlias,
                          child: InkWell(
                            enableFeedback: false,
                            onTap: () =>
                                _completeAndGo(context, AppRoutes.home),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 8,
                              ),
                              child: Text(
                                'Skip',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: isDark
                                      ? scheme.primary
                                      : const Color(0xFF6B2ED0),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Exact Reference Two-Line Headline
                  RichText(
                    text: TextSpan(
                      style: const TextStyle(
                        fontSize: 31,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.7,
                        height: 1.15,
                      ),
                      children: [
                        TextSpan(
                          text: 'Discover Your\nRight ',
                          style: TextStyle(
                            color: isDark
                                ? scheme.onSurface
                                : const Color(0xFF17122B),
                          ),
                        ),
                        TextSpan(
                          text: 'Career Path',
                          style: TextStyle(
                            color: isDark
                                ? scheme.primary
                                : const Color(0xFF7433D6),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Exact Reference 3-Line Subtitle
                  Text(
                    'Take assessments, get personalized\nrecommendations and explore colleges,\nscholarships and much more.',
                    style: TextStyle(
                      fontSize: 14,
                      height: 1.42,
                      color: isDark
                          ? scheme.onSurfaceVariant
                          : const Color(0xFF4E4966),
                    ),
                  ),

                  // Centered Fixed Student & Educational Symbols Artwork
                  Expanded(
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Image.asset(
                          'assets/images/welcome_hero.png',
                          fit: BoxFit.contain,
                          errorBuilder: (_, _, _) => Icon(
                            Icons.school_rounded,
                            size: 96,
                            color: scheme.primary,
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Full-Width Rich Violet Gradient "Get Started ->" Pill CTA
                  Container(
                    width: double.infinity,
                    height: 56,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(18),
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xFF5D26C6),
                          Color(0xFF8344E4),
                          Color(0xFF9757EE),
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF6B2FD0)
                              .withAlpha(isDark ? 72 : 64),
                          blurRadius: 18,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(18),
                      clipBehavior: Clip.antiAlias,
                      child: InkWell(
                        enableFeedback: false,
                        onTap: () => _completeAndGo(context, AppRoutes.home),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Get Started',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16.5,
                                fontWeight: FontWeight.w700,
                                letterSpacing: -0.2,
                              ),
                            ),
                            SizedBox(width: 8),
                            Icon(
                              Icons.arrow_forward_rounded,
                              color: Colors.white,
                              size: 20,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Bottom Secondary Action: "Already have a profile? Continue"
                  Center(
                    child: Wrap(
                      alignment: WrapAlignment.center,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(
                          'Already have a profile? ',
                          style: TextStyle(
                            fontSize: 13.5,
                            color: isDark
                                ? scheme.onSurfaceVariant
                                : const Color(0xFF5A5472),
                          ),
                        ),
                        Material(
                          color: Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                          clipBehavior: Clip.antiAlias,
                          child: InkWell(
                            enableFeedback: false,
                            onTap: () =>
                                _completeAndGo(context, AppRoutes.home),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 4,
                                vertical: 4,
                              ),
                              child: Text(
                                'Continue',
                                style: TextStyle(
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.w700,
                                  color: isDark
                                      ? scheme.primary
                                      : const Color(0xFF7433D6),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 18),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _WelcomeBackdropPainter extends CustomPainter {
  const _WelcomeBackdropPainter({required this.isDark});

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
          stops: const [0.0, 0.45, 1.0],
          colors: isDark
              ? const [
                  AppColors.darkBackgroundTop,
                  AppColors.darkBackground,
                  AppColors.darkBackground,
                ]
              : const [Color(0xFFF6F2FF), Color(0xFFFAF8FF), Color(0xFFF3ECFF)],
        ).createShader(rect),
    );

    // Subtle soft lavender upper-right curve
    final topCurve = Path()
      ..moveTo(size.width * 0.56, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width, size.height * 0.22)
      ..quadraticBezierTo(
        size.width * 0.68,
        size.height * 0.14,
        size.width * 0.56,
        0,
      )
      ..close();
    canvas.drawPath(
      topCurve,
      Paint()
        ..color = isDark
            ? const Color(0xFF281F4A).withAlpha(130)
            : const Color(0xFFEBE1FF).withAlpha(165),
    );

    // Subtle soft lavender glow behind central hero
    canvas.drawCircle(
      Offset(size.width * 0.50, size.height * 0.53),
      size.width * 0.40,
      Paint()
        ..color = isDark
            ? const Color(0xFF241B46).withAlpha(130)
            : const Color(0xFFEEE6FF).withAlpha(160),
    );
  }

  @override
  bool shouldRepaint(covariant _WelcomeBackdropPainter oldDelegate) =>
      oldDelegate.isDark != isDark;
}
