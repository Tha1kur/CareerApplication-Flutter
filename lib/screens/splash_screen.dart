import 'dart:async';
import 'dart:math' as math;

import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

import '../app.dart';
import '../core/constants/app_routes.dart';
import '../core/theme/app_colors.dart';
import '../widgets/duotone_icons.dart';

/// Exact reference CareerGuide Splash screen (PDF Page 2 Left):
/// - Real local initialization via AppDependencies.loadAll()
/// - Large CareerGuide cap+book emblem + wordmark + subtitle
/// - Full-bleed panoramic student sunrise mountain journey illustration
/// - Rotating lavender-violet loading ring + "Loading your career journey..."
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _spinnerController;

  @override
  void initState() {
    super.initState();
    _spinnerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1050),
    )..repeat();
    unawaited(_initializeAndNavigate());
  }

  Future<void> _initializeAndNavigate() async {
    final deps = context.read<AppDependencies>();
    final start = DateTime.now();

    if (!deps.themeProvider.isLoaded) {
      await deps.loadAll();
    }
    final hasSeenWelcome = await deps.storage.loadHasSeenWelcome();

    // Ensure Splash is readable on fast devices instead of a jarring 20ms flash
    final elapsed = DateTime.now().difference(start);
    const minSplash = Duration(milliseconds: 1050);
    if (elapsed < minSplash) {
      await Future<void>.delayed(minSplash - elapsed);
    }

    if (!mounted) return;
    context.go(hasSeenWelcome ? AppRoutes.home : AppRoutes.welcome);
  }

  @override
  void dispose() {
    _spinnerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Stack(
        children: [
          // Base soft lavender-white backdrop + organic upper-right curve
          Positioned.fill(
            child: CustomPaint(
              painter: _SplashBackdropPainter(isDark: isDark),
            ),
          ),

          // Lower panoramic student mountain sunrise scene seamlessly blended into top/bottom lavender
          Positioned(
            left: 0,
            right: 0,
            bottom: 92,
            height: MediaQuery.sizeOf(context).height * 0.50,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.asset(
                  'assets/images/splash_scene.png',
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => const SizedBox.shrink(),
                ),
                // Soft top fade into upper lavender canvas
                Align(
                  alignment: Alignment.topCenter,
                  child: Container(
                    height: 92,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: isDark
                            ? [
                                AppColors.darkBackground,
                                AppColors.darkBackground.withAlpha(0),
                              ]
                            : const [
                                Color(0xFFF6F2FF),
                                Color(0x00F6F2FF),
                              ],
                      ),
                    ),
                  ),
                ),
                // Soft bottom curved lavender mist blending into loading area
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    height: 76,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: isDark
                            ? [
                                AppColors.darkBackground,
                                AppColors.darkBackground.withAlpha(0),
                              ]
                            : const [
                                Color(0xFFF3ECFF),
                                Color(0x00F3ECFF),
                              ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Soft curved foreground bottom mist wave behind loading ring (exact reference feel)
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: 155,
            child: CustomPaint(
              painter: _SplashBottomMistPainter(isDark: isDark),
            ),
          ),

          // Foreground Brand Mark (Upper Center) & Loading Ring (Bottom Center)
          SafeArea(
            child: Column(
              children: [
                SizedBox(height: MediaQuery.sizeOf(context).height * 0.10),
                const Center(
                  child: CareerGuideEmblem(width: 118, height: 96),
                ),
                const SizedBox(height: 10),
                RichText(
                  text: TextSpan(
                    style: const TextStyle(
                      fontSize: 33,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.8,
                    ),
                    children: [
                      TextSpan(
                        text: 'Career',
                        style: TextStyle(
                          color: isDark
                              ? scheme.onSurface
                              : const Color(0xFF19152E),
                        ),
                      ),
                      TextSpan(
                        text: 'Guide',
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
                  'Your Personalized Career Journey',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: isDark
                        ? scheme.onSurfaceVariant
                        : const Color(0xFF56506E),
                  ),
                ),
                const Spacer(),
                // Clean rotating gradient loading ring
                SizedBox(
                  width: 30,
                  height: 30,
                  child: AnimatedBuilder(
                    animation: _spinnerController,
                    builder: (context, _) {
                      return Transform.rotate(
                        angle: _spinnerController.value * 2 * math.pi,
                        child: CustomPaint(
                          painter: _GradientRingPainter(
                            color: isDark
                                ? scheme.primary
                                : const Color(0xFF6E32D6),
                            trackColor: isDark
                                ? Colors.white.withAlpha(35)
                                : const Color(0xFFD9C9FA),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Loading your career journey...',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: isDark
                        ? scheme.onSurfaceVariant
                        : const Color(0xFF5A5472),
                  ),
                ),
                const SizedBox(height: 28),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SplashBackdropPainter extends CustomPainter {
  const _SplashBackdropPainter({required this.isDark});

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
          colors: isDark
              ? const [
                  AppColors.darkBackgroundTop,
                  AppColors.darkBackground,
                ]
              : const [
                  Color(0xFFF6F2FF),
                  Color(0xFFF3ECFF),
                ],
        ).createShader(rect),
    );

    // Subtle pastel lavender sweeping corner accent top-right
    final topRight = Path()
      ..moveTo(size.width * 0.54, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width, size.height * 0.24)
      ..quadraticBezierTo(
        size.width * 0.66,
        size.height * 0.16,
        size.width * 0.54,
        0,
      )
      ..close();
    canvas.drawPath(
      topRight,
      Paint()
        ..color = isDark
            ? const Color(0xFF281F4B).withAlpha(140)
            : const Color(0xFFEBE1FF).withAlpha(180),
    );
  }

  @override
  bool shouldRepaint(covariant _SplashBackdropPainter oldDelegate) =>
      oldDelegate.isDark != isDark;
}

class _SplashBottomMistPainter extends CustomPainter {
  const _SplashBottomMistPainter({required this.isDark});

  final bool isDark;

  @override
  void paint(Canvas canvas, Size size) {
    final wave = Path()
      ..moveTo(0, size.height * 0.28)
      ..quadraticBezierTo(
        size.width * 0.50,
        -size.height * 0.08,
        size.width,
        size.height * 0.24,
      )
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    canvas.drawPath(
      wave,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: isDark
              ? [
                  AppColors.darkBackground.withAlpha(235),
                  AppColors.darkBackground,
                ]
              : const [
                  Color(0xF5F6F2FF),
                  Color(0xFFF1E9FF),
                ],
        ).createShader(Offset.zero & size),
    );
  }

  @override
  bool shouldRepaint(covariant _SplashBottomMistPainter oldDelegate) =>
      oldDelegate.isDark != isDark;
}

class _GradientRingPainter extends CustomPainter {
  const _GradientRingPainter({
    required this.color,
    required this.trackColor,
  });

  final Color color;
  final Color trackColor;

  @override
  void paint(Canvas canvas, Size size) {
    const stroke = 2.8;
    final rect = Rect.fromLTWH(
      stroke / 2,
      stroke / 2,
      size.width - stroke,
      size.height - stroke,
    );
    canvas.drawArc(
      rect,
      0,
      math.pi * 2,
      false,
      Paint()
        ..color = trackColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke,
    );
    canvas.drawArc(
      rect,
      -math.pi / 2,
      math.pi * 1.15,
      false,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(covariant _GradientRingPainter oldDelegate) =>
      oldDelegate.color != color;
}
