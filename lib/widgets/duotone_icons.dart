import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';

import '../core/theme/app_colors.dart';

/// Exact CareerGuide brand wordmark with 3D violet graduation cap over winged open book.
class CareerGuideLogo extends StatelessWidget {
  const CareerGuideLogo({
    super.key,
    this.iconWidth = 44,
    this.iconHeight = 36,
    this.fontSize = 22.5,
  });

  final double iconWidth;
  final double iconHeight;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: iconWidth,
          height: iconHeight,
          child: CustomPaint(
            painter: _BrandEmblemPainter(
              primary: isDark ? AppColors.darkPrimary : const Color(0xFF7B3BE0),
              deep: isDark ? const Color(0xFF9F7AEA) : const Color(0xFF561FB8),
              lavender: isDark
                  ? const Color(0xFF5B3FA6)
                  : const Color(0xFFA77DF6),
              pageColor: isDark ? const Color(0xFF282046) : Colors.white,
              gold: AppColors.accentGold,
            ),
          ),
        ),
        const SizedBox(width: 8),
        RichText(
          text: TextSpan(
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.6,
            ),
            children: [
              TextSpan(
                text: 'Career',
                style: TextStyle(
                  color: isDark ? scheme.onSurface : const Color(0xFF19152E),
                ),
              ),
              TextSpan(
                text: 'Guide',
                style: TextStyle(
                  color: isDark ? scheme.primary : const Color(0xFF7433D6),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Exact reference duotone feature icons (zero 3-line sparkle artifacts).
enum DuotoneIconKind {
  aptitudeQuiz,
  careerPaths,
  colleges,
  scholarships,
  aiMentor,
  moreModules,
}

class DuotoneFeatureIcon extends StatelessWidget {
  const DuotoneFeatureIcon({super.key, required this.kind, this.size = 56});

  final DuotoneIconKind kind;
  final double size;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = isDark ? AppColors.darkPrimary : const Color(0xFF7433D6);
    final deep = isDark ? const Color(0xFF9F7AEA) : const Color(0xFF5420B0);
    final soft = isDark ? const Color(0xFF2F2359) : const Color(0xFFF1EBFE);
    final mid = isDark ? const Color(0xFF5B3FA6) : const Color(0xFFC5AFFB);
    final backTint = isDark ? const Color(0xFF3E2D73) : const Color(0xFFE2D5FD);

    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: switch (kind) {
          DuotoneIconKind.aptitudeQuiz => _QuizIconPainter(
            primary: primary,
            deep: deep,
            soft: soft,
            mid: mid,
            backTint: backTint,
            cardFill: isDark ? const Color(0xFF251D44) : Colors.white,
          ),
          DuotoneIconKind.careerPaths => _CompassIconPainter(
            primary: primary,
            deep: deep,
            soft: soft,
            backTint: backTint,
            dialFill: isDark
                ? const Color(0xFF251D44)
                : const Color(0xFFF7F4FF),
          ),
          DuotoneIconKind.colleges => _CollegeIconPainter(
            primary: primary,
            deep: deep,
            soft: soft,
            mid: mid,
            backTint: backTint,
            wallFill: isDark ? const Color(0xFF282046) : Colors.white,
          ),
          DuotoneIconKind.scholarships => _ScholarshipIconPainter(
            primary: primary,
            deep: deep,
            mid: mid,
          ),
          DuotoneIconKind.aiMentor => _AiMentorIconPainter(
            primary: primary,
            deep: deep,
            backTint: backTint,
          ),
          DuotoneIconKind.moreModules => _MoreGridIconPainter(
            primary: primary,
            deep: deep,
            mid: mid,
          ),
        },
      ),
    );
  }
}

class _BrandEmblemPainter extends CustomPainter {
  const _BrandEmblemPainter({
    required this.primary,
    required this.deep,
    required this.lavender,
    required this.pageColor,
    required this.gold,
  });

  final Color primary;
  final Color deep;
  final Color lavender;
  final Color pageColor;
  final Color gold;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Open winged book base (lower half)
    final leftCover = Path()
      ..moveTo(w * 0.05, h * 0.88)
      ..quadraticBezierTo(w * 0.25, h * 0.68, w * 0.49, h * 0.82)
      ..lineTo(w * 0.49, h * 0.92)
      ..quadraticBezierTo(w * 0.25, h * 0.80, w * 0.05, h * 0.94)
      ..close();
    final rightCover = Path()
      ..moveTo(w * 0.95, h * 0.88)
      ..quadraticBezierTo(w * 0.75, h * 0.68, w * 0.51, h * 0.82)
      ..lineTo(w * 0.51, h * 0.92)
      ..quadraticBezierTo(w * 0.75, h * 0.80, w * 0.95, h * 0.94)
      ..close();
    canvas.drawPath(leftCover, Paint()..color = deep);
    canvas.drawPath(rightCover, Paint()..color = deep);

    // Upper winged book pages (purple top + crisp white curved page layer)
    final leftPageTop = Path()
      ..moveTo(w * 0.11, h * 0.75)
      ..quadraticBezierTo(w * 0.28, h * 0.54, w * 0.48, h * 0.72)
      ..lineTo(w * 0.48, h * 0.85)
      ..quadraticBezierTo(w * 0.28, h * 0.69, w * 0.08, h * 0.86)
      ..close();
    final rightPageTop = Path()
      ..moveTo(w * 0.89, h * 0.75)
      ..quadraticBezierTo(w * 0.72, h * 0.54, w * 0.52, h * 0.72)
      ..lineTo(w * 0.52, h * 0.85)
      ..quadraticBezierTo(w * 0.72, h * 0.69, w * 0.92, h * 0.86)
      ..close();
    canvas.drawPath(leftPageTop, Paint()..color = primary);
    canvas.drawPath(rightPageTop, Paint()..color = primary);

    // Inner white curved page highlight lines
    final pageStroke = Paint()
      ..color = pageColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(
      Path()
        ..moveTo(w * 0.14, h * 0.81)
        ..quadraticBezierTo(w * 0.30, h * 0.67, w * 0.46, h * 0.79),
      pageStroke,
    );
    canvas.drawPath(
      Path()
        ..moveTo(w * 0.86, h * 0.81)
        ..quadraticBezierTo(w * 0.70, h * 0.67, w * 0.54, h * 0.79),
      pageStroke,
    );

    // Graduation cap crown (band under diamond)
    final crown = Path()
      ..moveTo(w * 0.28, h * 0.37)
      ..lineTo(w * 0.50, h * 0.50)
      ..lineTo(w * 0.72, h * 0.37)
      ..lineTo(w * 0.71, h * 0.56)
      ..quadraticBezierTo(w * 0.50, h * 0.67, w * 0.29, h * 0.56)
      ..close();
    canvas.drawPath(crown, Paint()..color = deep);

    // Graduation cap diamond top with gradient
    final capPath = Path()
      ..moveTo(w * 0.50, h * 0.07)
      ..lineTo(w * 0.87, h * 0.28)
      ..lineTo(w * 0.50, h * 0.49)
      ..lineTo(w * 0.13, h * 0.28)
      ..close();
    final capGradient = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [lavender, primary],
      ).createShader(Rect.fromLTWH(0, 0, w, h * 0.55));
    canvas.drawPath(capPath, capGradient);

    // Subtle top edge highlight on cap
    canvas.drawLine(
      Offset(w * 0.50, h * 0.09),
      Offset(w * 0.83, h * 0.27),
      Paint()
        ..color = Colors.white.withAlpha(80)
        ..strokeWidth = 1.2
        ..strokeCap = StrokeCap.round,
    );

    // Golden tassel string & drop on right side
    final tasselPath = Path()
      ..moveTo(w * 0.52, h * 0.28)
      ..quadraticBezierTo(w * 0.73, h * 0.29, w * 0.78, h * 0.48);
    canvas.drawPath(
      tasselPath,
      Paint()
        ..color = gold
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0
        ..strokeCap = StrokeCap.round,
    );
    canvas.drawCircle(
      Offset(w * 0.78, h * 0.52),
      w * 0.052,
      Paint()..color = gold,
    );
  }

  @override
  bool shouldRepaint(covariant _BrandEmblemPainter oldDelegate) =>
      oldDelegate.primary != primary;
}

class _QuizIconPainter extends CustomPainter {
  const _QuizIconPainter({
    required this.primary,
    required this.deep,
    required this.soft,
    required this.mid,
    required this.backTint,
    required this.cardFill,
  });

  final Color primary;
  final Color deep;
  final Color soft;
  final Color mid;
  final Color backTint;
  final Color cardFill;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Tilted lavender backing sheet on left
    canvas.save();
    canvas.translate(w * 0.34, h * 0.54);
    canvas.rotate(-0.15);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset.zero, width: w * 0.56, height: h * 0.72),
        Radius.circular(w * 0.11),
      ),
      Paint()..color = backTint,
    );
    canvas.restore();

    // Foreground rounded checklist sheet
    final docRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(w * 0.15, h * 0.08, w * 0.62, h * 0.80),
      Radius.circular(w * 0.12),
    );
    canvas.drawRRect(docRect, Paint()..color = cardFill);
    canvas.drawRRect(
      docRect,
      Paint()
        ..color = primary.withAlpha(220)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.2,
    );

    // 3 purple checkmarks + horizontal lines
    final checkPaint = Paint()
      ..color = primary
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.6
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final linePaint = Paint()
      ..color = mid
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round;

    for (var i = 0; i < 3; i++) {
      final y = h * (0.29 + i * 0.195);
      final p = Path()
        ..moveTo(w * 0.25, y)
        ..lineTo(w * 0.30, y + h * 0.045)
        ..lineTo(w * 0.39, y - h * 0.045);
      canvas.drawPath(p, checkPaint);
      canvas.drawLine(Offset(w * 0.45, y), Offset(w * 0.66, y), linePaint);
    }

    // Bright yellow-amber pencil angled diagonally on bottom-right
    canvas.save();
    canvas.translate(w * 0.77, h * 0.56);
    canvas.rotate(math.pi / 4.2);

    // Eraser cap (deep violet)
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(0, -h * 0.24),
          width: w * 0.18,
          height: h * 0.13,
        ),
        Radius.circular(w * 0.045),
      ),
      Paint()..color = deep,
    );
    // Yellow pencil body
    canvas.drawRect(
      Rect.fromCenter(center: Offset.zero, width: w * 0.18, height: h * 0.40),
      Paint()..color = const Color(0xFFF59E0B),
    );
    // Highlight stripe on pencil body
    canvas.drawRect(
      Rect.fromCenter(
        center: Offset(-w * 0.04, 0),
        width: w * 0.045,
        height: h * 0.40,
      ),
      Paint()..color = const Color(0xFFFCD34D),
    );
    // Wooden cone tip
    final cone = Path()
      ..moveTo(-w * 0.09, h * 0.20)
      ..lineTo(w * 0.09, h * 0.20)
      ..lineTo(0, h * 0.34)
      ..close();
    canvas.drawPath(cone, Paint()..color = const Color(0xFFFDE68A));
    // Dark graphite point
    final lead = Path()
      ..moveTo(-w * 0.04, h * 0.275)
      ..lineTo(w * 0.04, h * 0.275)
      ..lineTo(0, h * 0.34)
      ..close();
    canvas.drawPath(lead, Paint()..color = const Color(0xFF2D2545));

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _QuizIconPainter oldDelegate) =>
      oldDelegate.primary != primary;
}

class _CompassIconPainter extends CustomPainter {
  const _CompassIconPainter({
    required this.primary,
    required this.deep,
    required this.soft,
    required this.backTint,
    required this.dialFill,
  });

  final Color primary;
  final Color deep;
  final Color soft;
  final Color backTint;
  final Color dialFill;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final center = Offset(w * 0.52, h * 0.56);
    final r = w * 0.39;

    // Soft lavender offset backdrop circle on bottom-left (reference style)
    canvas.drawCircle(
      Offset(w * 0.40, h * 0.62),
      r * 0.88,
      Paint()..color = backTint,
    );

    // Top crown connector & loop
    canvas.drawRect(
      Rect.fromCenter(
        center: Offset(center.dx, h * 0.16),
        width: w * 0.12,
        height: h * 0.08,
      ),
      Paint()..color = deep,
    );
    canvas.drawCircle(
      Offset(center.dx, h * 0.09),
      w * 0.072,
      Paint()
        ..color = deep
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.0,
    );

    // Compass dial face + bold violet rim
    canvas.drawCircle(center, r, Paint()..color = dialFill);
    canvas.drawCircle(
      center,
      r,
      Paint()
        ..color = deep
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4.4,
    );

    // Subtle cardinal tick dots
    final tickPaint = Paint()..color = primary.withAlpha(110);
    canvas.drawCircle(Offset(center.dx, center.dy - r * 0.72), 1.6, tickPaint);
    canvas.drawCircle(Offset(center.dx, center.dy + r * 0.72), 1.6, tickPaint);
    canvas.drawCircle(Offset(center.dx - r * 0.72, center.dy), 1.6, tickPaint);
    canvas.drawCircle(Offset(center.dx + r * 0.72, center.dy), 1.6, tickPaint);

    // Gold upper-right pointer
    final north = Path()
      ..moveTo(center.dx + r * 0.52, center.dy - r * 0.52)
      ..lineTo(center.dx - r * 0.15, center.dy - r * 0.15)
      ..lineTo(center.dx + r * 0.15, center.dy + r * 0.15)
      ..close();
    canvas.drawPath(north, Paint()..color = const Color(0xFFF59E0B));

    // Deep violet lower-left pointer
    final south = Path()
      ..moveTo(center.dx - r * 0.52, center.dy + r * 0.52)
      ..lineTo(center.dx - r * 0.15, center.dy - r * 0.15)
      ..lineTo(center.dx + r * 0.15, center.dy + r * 0.15)
      ..close();
    canvas.drawPath(south, Paint()..color = deep);

    // Crisp white pivot pin
    canvas.drawCircle(center, 3.2, Paint()..color = Colors.white);
  }

  @override
  bool shouldRepaint(covariant _CompassIconPainter oldDelegate) =>
      oldDelegate.primary != primary;
}

class _CollegeIconPainter extends CustomPainter {
  const _CollegeIconPainter({
    required this.primary,
    required this.deep,
    required this.soft,
    required this.mid,
    required this.backTint,
    required this.wallFill,
  });

  final Color primary;
  final Color deep;
  final Color soft;
  final Color mid;
  final Color backTint;
  final Color wallFill;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Flagpole & golden waving flag on roof peak
    canvas.drawLine(
      Offset(w * 0.50, h * 0.05),
      Offset(w * 0.50, h * 0.24),
      Paint()
        ..color = deep
        ..strokeWidth = 2.2
        ..strokeCap = StrokeCap.round,
    );
    final flag = Path()
      ..moveTo(w * 0.50, h * 0.06)
      ..quadraticBezierTo(w * 0.61, h * 0.03, w * 0.72, h * 0.08)
      ..lineTo(w * 0.70, h * 0.17)
      ..quadraticBezierTo(w * 0.59, h * 0.14, w * 0.50, h * 0.17)
      ..close();
    canvas.drawPath(flag, Paint()..color = const Color(0xFFF59E0B));

    // Left & right pastel lavender side wings with tiny window pairs
    final leftWing = RRect.fromRectAndCorners(
      Rect.fromLTWH(w * 0.04, h * 0.57, w * 0.20, h * 0.30),
      topLeft: const Radius.circular(4),
    );
    final rightWing = RRect.fromRectAndCorners(
      Rect.fromLTWH(w * 0.76, h * 0.57, w * 0.20, h * 0.30),
      topRight: const Radius.circular(4),
    );
    canvas.drawRRect(leftWing, Paint()..color = backTint);
    canvas.drawRRect(rightWing, Paint()..color = backTint);

    final winPaint = Paint()..color = deep;
    canvas.drawRect(
      Rect.fromLTWH(w * 0.095, h * 0.66, w * 0.04, h * 0.085),
      winPaint,
    );
    canvas.drawRect(
      Rect.fromLTWH(w * 0.165, h * 0.66, w * 0.04, h * 0.085),
      winPaint,
    );
    canvas.drawRect(
      Rect.fromLTWH(w * 0.795, h * 0.66, w * 0.04, h * 0.085),
      winPaint,
    );
    canvas.drawRect(
      Rect.fromLTWH(w * 0.865, h * 0.66, w * 0.04, h * 0.085),
      winPaint,
    );

    // Main central building body
    canvas.drawRect(
      Rect.fromLTWH(w * 0.21, h * 0.44, w * 0.58, h * 0.43),
      Paint()..color = wallFill,
    );

    // Triangular pediment roof + inner white triangle accent
    final roof = Path()
      ..moveTo(w * 0.15, h * 0.45)
      ..lineTo(w * 0.50, h * 0.21)
      ..lineTo(w * 0.85, h * 0.45)
      ..close();
    canvas.drawPath(roof, Paint()..color = deep);
    final innerRoof = Path()
      ..moveTo(w * 0.27, h * 0.41)
      ..lineTo(w * 0.50, h * 0.27)
      ..lineTo(w * 0.73, h * 0.41)
      ..close();
    canvas.drawPath(innerRoof, Paint()..color = soft);

    // Cornice bar under roof
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.18, h * 0.43, w * 0.64, h * 0.06),
        const Radius.circular(2.5),
      ),
      Paint()..color = primary,
    );

    // 4 crisp classical pillars
    final pillarPaint = Paint()..color = primary;
    for (final px in [0.24, 0.34, 0.60, 0.70]) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(w * px, h * 0.50, w * 0.065, h * 0.35),
          const Radius.circular(2.5),
        ),
        pillarPaint,
      );
    }

    // Central arched violet doorway
    canvas.drawRRect(
      RRect.fromRectAndCorners(
        Rect.fromLTWH(w * 0.435, h * 0.57, w * 0.13, h * 0.29),
        topLeft: const Radius.circular(11),
        topRight: const Radius.circular(11),
      ),
      Paint()..color = deep,
    );

    // Base plinth step
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.06, h * 0.84, w * 0.88, h * 0.09),
        const Radius.circular(4.5),
      ),
      Paint()..color = mid,
    );
  }

  @override
  bool shouldRepaint(covariant _CollegeIconPainter oldDelegate) =>
      oldDelegate.primary != primary;
}

class _ScholarshipIconPainter extends CustomPainter {
  const _ScholarshipIconPainter({
    required this.primary,
    required this.deep,
    required this.mid,
  });

  final Color primary;
  final Color deep;
  final Color mid;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Graduation cap crown
    final crown = Path()
      ..moveTo(w * 0.18, h * 0.39)
      ..lineTo(w * 0.47, h * 0.53)
      ..lineTo(w * 0.74, h * 0.40)
      ..lineTo(w * 0.73, h * 0.63)
      ..quadraticBezierTo(w * 0.46, h * 0.76, w * 0.19, h * 0.63)
      ..close();
    canvas.drawPath(crown, Paint()..color = deep);

    // Graduation cap diamond top with rich gradient
    final cap = Path()
      ..moveTo(w * 0.47, h * 0.09)
      ..lineTo(w * 0.93, h * 0.31)
      ..lineTo(w * 0.47, h * 0.52)
      ..lineTo(w * 0.03, h * 0.31)
      ..close();
    final capPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [const Color(0xFF965BF4), primary],
      ).createShader(Rect.fromLTWH(0, h * 0.08, w, h * 0.45));
    canvas.drawPath(cap, capPaint);

    // Hanging purple award ribbons behind gold medal
    final leftRibbon = Path()
      ..moveTo(w * 0.64, h * 0.73)
      ..lineTo(w * 0.57, h * 0.96)
      ..lineTo(w * 0.67, h * 0.90)
      ..lineTo(w * 0.73, h * 0.75)
      ..close();
    final rightRibbon = Path()
      ..moveTo(w * 0.78, h * 0.73)
      ..lineTo(w * 0.86, h * 0.96)
      ..lineTo(w * 0.76, h * 0.90)
      ..lineTo(w * 0.70, h * 0.75)
      ..close();
    canvas.drawPath(leftRibbon, Paint()..color = primary);
    canvas.drawPath(rightRibbon, Paint()..color = mid);

    // Gold tassel cord from cap center to medal
    final cord = Path()
      ..moveTo(w * 0.49, h * 0.31)
      ..quadraticBezierTo(w * 0.72, h * 0.34, w * 0.73, h * 0.52);
    canvas.drawPath(
      cord,
      Paint()
        ..color = const Color(0xFFF59E0B)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.0
        ..strokeCap = StrokeCap.round,
    );

    // Golden-amber medal circle
    final medalCenter = Offset(w * 0.73, h * 0.67);
    final medalR = w * 0.185;
    canvas.drawCircle(
      medalCenter,
      medalR,
      Paint()..color = const Color(0xFFF59E0B),
    );
    canvas.drawCircle(
      medalCenter,
      medalR * 0.82,
      Paint()..color = const Color(0xFFFBBF24),
    );

    // Crisp white 5-point star inside medal
    final star = Path();
    for (var i = 0; i < 10; i++) {
      final angle = -math.pi / 2 + i * math.pi / 5;
      final radius = i.isEven ? medalR * 0.52 : medalR * 0.23;
      final x = medalCenter.dx + math.cos(angle) * radius;
      final y = medalCenter.dy + math.sin(angle) * radius;
      if (i == 0) {
        star.moveTo(x, y);
      } else {
        star.lineTo(x, y);
      }
    }
    star.close();
    canvas.drawPath(star, Paint()..color = Colors.white);
  }

  @override
  bool shouldRepaint(covariant _ScholarshipIconPainter oldDelegate) =>
      oldDelegate.primary != primary;
}

class _AiMentorIconPainter extends CustomPainter {
  const _AiMentorIconPainter({
    required this.primary,
    required this.deep,
    required this.backTint,
  });

  final Color primary;
  final Color deep;
  final Color backTint;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Secondary soft lavender speech bubble tucked behind bottom-right
    final backBubble = RRect.fromRectAndRadius(
      Rect.fromLTWH(w * 0.40, h * 0.44, w * 0.54, h * 0.38),
      Radius.circular(w * 0.18),
    );
    canvas.drawRRect(backBubble, Paint()..color = backTint);
    final backTail = Path()
      ..moveTo(w * 0.76, h * 0.78)
      ..lineTo(w * 0.88, h * 0.91)
      ..lineTo(w * 0.64, h * 0.80)
      ..close();
    canvas.drawPath(backTail, Paint()..color = backTint);

    // Primary bold violet rounded speech bubble
    final bubbleRect = Rect.fromLTWH(w * 0.06, h * 0.18, w * 0.72, h * 0.50);
    final bubble = RRect.fromRectAndRadius(
      bubbleRect,
      Radius.circular(w * 0.23),
    );
    final bubblePaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [const Color(0xFF8B4FF0), deep],
      ).createShader(bubbleRect);
    canvas.drawRRect(bubble, bubblePaint);

    // Primary bubble tail bottom-left
    final tail = Path()
      ..moveTo(w * 0.21, h * 0.65)
      ..lineTo(w * 0.14, h * 0.85)
      ..lineTo(w * 0.39, h * 0.66)
      ..close();
    canvas.drawPath(tail, Paint()..color = deep);

    // 3 crisp white chat dots inside primary bubble
    final dotPaint = Paint()..color = Colors.white;
    canvas.drawCircle(Offset(w * 0.28, h * 0.43), w * 0.046, dotPaint);
    canvas.drawCircle(Offset(w * 0.42, h * 0.43), w * 0.046, dotPaint);
    canvas.drawCircle(Offset(w * 0.56, h * 0.43), w * 0.046, dotPaint);

    // Single crisp 4-point golden star accent top-right (zero 3-line dashes!)
    final sc = Offset(w * 0.84, h * 0.18);
    final sr = w * 0.14;
    final star = Path()
      ..moveTo(sc.dx, sc.dy - sr)
      ..quadraticBezierTo(sc.dx, sc.dy, sc.dx + sr, sc.dy)
      ..quadraticBezierTo(sc.dx, sc.dy, sc.dx, sc.dy + sr)
      ..quadraticBezierTo(sc.dx, sc.dy, sc.dx - sr, sc.dy)
      ..quadraticBezierTo(sc.dx, sc.dy, sc.dx, sc.dy - sr)
      ..close();
    canvas.drawPath(star, Paint()..color = const Color(0xFFFBBF24));
  }

  @override
  bool shouldRepaint(covariant _AiMentorIconPainter oldDelegate) =>
      oldDelegate.primary != primary;
}

class _MoreGridIconPainter extends CustomPainter {
  const _MoreGridIconPainter({
    required this.primary,
    required this.deep,
    required this.mid,
  });

  final Color primary;
  final Color deep;
  final Color mid;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final boxSize = w * 0.38;
    final radius = Radius.circular(w * 0.10);

    // Top-left solid violet rounded square
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.09, h * 0.09, boxSize, boxSize),
        radius,
      ),
      Paint()..color = primary,
    );

    // Top-right 45-degree rotated pastel lilac diamond
    canvas.save();
    canvas.translate(w * 0.72, h * 0.28);
    canvas.rotate(math.pi / 4);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset.zero,
          width: boxSize * 0.88,
          height: boxSize * 0.88,
        ),
        radius,
      ),
      Paint()..color = mid,
    );
    canvas.restore();

    // Bottom-left pastel lilac rounded square
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.09, h * 0.53, boxSize, boxSize),
        radius,
      ),
      Paint()..color = mid,
    );

    // Bottom-right deep violet rounded square with 4 crisp white dots
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.53, h * 0.53, boxSize, boxSize),
        radius,
      ),
      Paint()..color = deep,
    );
    final dot = Paint()..color = Colors.white;
    canvas.drawCircle(Offset(w * 0.65, h * 0.65), w * 0.042, dot);
    canvas.drawCircle(Offset(w * 0.79, h * 0.65), w * 0.042, dot);
    canvas.drawCircle(Offset(w * 0.65, h * 0.79), w * 0.042, dot);
    canvas.drawCircle(Offset(w * 0.79, h * 0.79), w * 0.042, dot);
  }

  @override
  bool shouldRepaint(covariant _MoreGridIconPainter oldDelegate) =>
      oldDelegate.primary != primary;
}
