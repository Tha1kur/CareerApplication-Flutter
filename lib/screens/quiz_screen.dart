import 'dart:async';
import 'dart:math' as math;

import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

import '../core/constants/app_routes.dart';
import '../core/theme/app_colors.dart';
import '../providers/quiz_gamification_provider.dart';
import '../widgets/empty_state_view.dart';

/// Exact reference CareerGuide Aptitude Quiz screen (PDF Page 5):
/// - Lavender-white aesthetic with top CareerGuide bar
/// - Back arrow + "Aptitude Quiz" hero + fixed clipboard & pencil vector illustration (zero 3-line sparkles)
/// - Circular answered/total "Quiz Progress" card with violet pill action
/// - Real 8-question assessment with reference-styled white option cards, partial draft persistence,
///   submit validation, zero floating animations, and zero tap click sounds.
class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  int _index = 0;

  void _goBack(BuildContext context) {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(AppRoutes.home);
    }
  }

  Future<void> _handleSubmit(QuizGamificationProvider provider) async {
    final questions = provider.questions;
    final draft = provider.draftAnswers;

    final firstUnanswered = questions.indexWhere(
      (q) => (draft[q.id] ?? '').trim().isEmpty,
    );

    if (firstUnanswered >= 0) {
      setState(() => _index = firstUnanswered);
      final remaining = questions
          .where((q) => (draft[q.id] ?? '').trim().isEmpty)
          .length;
      if (!mounted) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text('Please answer all questions ($remaining remaining)'),
          ),
        );
      return;
    }

    await provider.submitQuiz();
    if (!mounted) return;
    context.pushReplacement(AppRoutes.recommendations);
  }

  void _handleContinueAction(QuizGamificationProvider provider) {
    final questions = provider.questions;
    if (questions.isEmpty) return;
    if (_index >= questions.length - 1) {
      unawaited(_handleSubmit(provider));
    } else {
      setState(() => _index++);
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<QuizGamificationProvider>();
    final questions = provider.questions;
    final draft = provider.draftAnswers;
    final scheme = Theme.of(context).colorScheme;
    final brightness = Theme.of(context).brightness;
    final isDark = brightness == Brightness.dark;
    final textTheme = Theme.of(context).textTheme;

    final safeIndex = questions.isEmpty
        ? 0
        : _index.clamp(0, questions.length - 1);
    final currentQuestion = questions.isEmpty ? null : questions[safeIndex];
    final answeredCount = questions
        .where((q) => (draft[q.id] ?? '').trim().isNotEmpty)
        .length;
    final total = questions.length;
    final progressFraction = total == 0 ? 0.0 : answeredCount / total;
    final isLast = total > 0 && safeIndex == total - 1;

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: CustomPaint(painter: _QuizBackdropPainter(isDark: isDark)),
          ),
          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 6),

                // 1. Hero Header Row: Back arrow + "Aptitude Quiz" + Fixed Clipboard Illustration
                SizedBox(
                  height: 112,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Positioned(
                        right: 6,
                        bottom: 0,
                        width: 148,
                        height: 108,
                        child: CustomPaint(
                          painter: _ClipboardBackdropPainter(isDark: isDark),
                        ),
                      ),
                      Positioned(
                        left: 14,
                        top: 10,
                        right: 126,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Material(
                                  color: Colors.transparent,
                                  shape: const CircleBorder(),
                                  clipBehavior: Clip.antiAlias,
                                  child: InkWell(
                                    enableFeedback: false,
                                    onTap: () => _goBack(context),
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
                                    'Aptitude Quiz',
                                    style: textTheme.headlineSmall?.copyWith(
                                      fontSize: 23.5,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: -0.5,
                                      color: isDark
                                          ? scheme.onSurface
                                          : const Color(0xFF17122B),
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Padding(
                              padding: const EdgeInsets.only(left: 36),
                              child: Text(
                                'Assess your skills and discover\nyour strengths.',
                                style: textTheme.bodySmall?.copyWith(
                                  color: isDark
                                      ? scheme.onSurfaceVariant
                                      : const Color(0xFF4A4560),
                                  fontSize: 13,
                                  height: 1.35,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Positioned(
                        right: 16,
                        bottom: 2,
                        width: 108,
                        height: 106,
                        child: CustomPaint(
                          painter: _QuizClipboardArtPainter(isDark: isDark),
                        ),
                      ),
                    ],
                  ),
                ),

                // 3. Body State
                Expanded(
                  child: !provider.isLoaded
                      ? const Center(child: CircularProgressIndicator())
                      : provider.loadError != null
                      ? EmptyStateView(
                          icon: Icons.error_outline_rounded,
                          title: 'Could not load quiz',
                          subtitle: provider.loadError!,
                          actionLabel: 'Back to Home',
                          onAction: () => _goBack(context),
                        )
                      : currentQuestion == null
                      ? EmptyStateView(
                          icon: Icons.quiz_outlined,
                          title: 'No quiz questions available',
                          subtitle: 'Could not find questions in assets/data/aptitudequiz.json.',
                          actionLabel: 'Back to Home',
                          onAction: () => _goBack(context),
                        )
                      : Column(
                          children: [
                            // Exact Reference "Quiz Progress" Lavender-Framed Card
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                              ),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 12,
                                ),
                                decoration: BoxDecoration(
                                  color: isDark
                                      ? const Color(0xFF231C42)
                                      : const Color(0xFFF3ECFF),
                                  borderRadius: BorderRadius.circular(22),
                                  border: Border.all(
                                    color: isDark
                                        ? scheme.outlineVariant
                                        : Colors.white,
                                    width: 2,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.cardShadow(brightness),
                                      blurRadius: 16,
                                      offset: const Offset(0, 6),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  children: [
                                    SizedBox(
                                      width: 54,
                                      height: 54,
                                      child: CustomPaint(
                                        painter: _QuizRingPainter(
                                          progress: progressFraction,
                                          isDark: isDark,
                                        ),
                                        child: Center(
                                          child: Text(
                                            '$answeredCount/$total',
                                            style: TextStyle(
                                              fontSize: 13.5,
                                              fontWeight: FontWeight.w800,
                                              color: isDark
                                                  ? scheme.onSurface
                                                  : const Color(0xFF3E1D8A),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Quiz Progress',
                                            style: textTheme.titleSmall
                                                ?.copyWith(
                                                  fontWeight: FontWeight.w800,
                                                  fontSize: 15,
                                                  color: isDark
                                                      ? scheme.onSurface
                                                      : const Color(0xFF17122B),
                                                ),
                                          ),
                                          const SizedBox(height: 3),
                                          Text(
                                            'Question ${safeIndex + 1} of $total',
                                            style: textTheme.bodySmall
                                                ?.copyWith(
                                                  color: isDark
                                                      ? scheme.onSurfaceVariant
                                                      : const Color(0xFF56506E),
                                                  fontSize: 12.2,
                                                ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(20),
                                        gradient: const LinearGradient(
                                          colors: [
                                            Color(0xFF6429CC),
                                            Color(0xFF8C4DF0),
                                          ],
                                        ),
                                      ),
                                      child: Material(
                                        color: Colors.transparent,
                                        borderRadius: BorderRadius.circular(20),
                                        clipBehavior: Clip.antiAlias,
                                        child: InkWell(
                                          enableFeedback: false,
                                          onTap: () =>
                                              _handleContinueAction(provider),
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 14,
                                              vertical: 9,
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Text(
                                                  isLast
                                                      ? 'Finish'
                                                      : 'Continue',
                                                  style: const TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 12.5,
                                                    fontWeight: FontWeight.w700,
                                                  ),
                                                ),
                                                const SizedBox(width: 4),
                                                const Icon(
                                                  Icons.arrow_forward_rounded,
                                                  size: 14,
                                                  color: Colors.white,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            const SizedBox(height: 12),

                            // Quick Question Jump Bar (1..8)
                            SizedBox(
                              height: 30,
                              child: ListView.separated(
                                scrollDirection: Axis.horizontal,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                ),
                                itemCount: total,
                                separatorBuilder: (_, _) =>
                                    const SizedBox(width: 7),
                                itemBuilder: (context, i) {
                                  final isCurrent = i == safeIndex;
                                  final isAnswered =
                                      (draft[questions[i].id] ?? '')
                                          .trim()
                                          .isNotEmpty;
                                  return GestureDetector(
                                    onTap: () => setState(() => _index = i),
                                    child: Container(
                                      width: 34,
                                      alignment: Alignment.center,
                                      decoration: BoxDecoration(
                                        color: isCurrent
                                            ? const Color(0xFF7433D6)
                                            : isAnswered
                                            ? (isDark
                                                  ? scheme.primaryContainer
                                                  : const Color(0xFFE9DDFF))
                                            : scheme.surface,
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(
                                          color: isCurrent
                                              ? const Color(0xFF7433D6)
                                              : scheme.outlineVariant,
                                        ),
                                      ),
                                      child: Text(
                                        '${i + 1}',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w700,
                                          color: isCurrent
                                              ? Colors.white
                                              : isAnswered
                                              ? (isDark
                                                    ? scheme.primary
                                                    : const Color(0xFF5D26C6))
                                              : scheme.onSurfaceVariant,
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),

                            const SizedBox(height: 12),

                            // Scrollable Question + Reference-Style White Option Cards
                            Expanded(
                              child: SingleChildScrollView(
                                padding: const EdgeInsets.fromLTRB(
                                  14,
                                  0,
                                  14,
                                  10,
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 4,
                                      ),
                                      child: Text(
                                        currentQuestion.question,
                                        style: textTheme.titleMedium?.copyWith(
                                          fontSize: 17,
                                          fontWeight: FontWeight.w800,
                                          letterSpacing: -0.3,
                                          height: 1.32,
                                          color: isDark
                                              ? scheme.onSurface
                                              : const Color(0xFF17122B),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    for (
                                      var i = 0;
                                      i < currentQuestion.options.length;
                                      i++
                                    ) ...[
                                      _ReferenceOptionCard(
                                        index: i,
                                        label: currentQuestion.options[i].label,
                                        selected:
                                            draft[currentQuestion.id] ==
                                            currentQuestion.options[i].value,
                                        onTap: () {
                                          ScaffoldMessenger.of(context)
                                              .hideCurrentSnackBar();
                                          unawaited(
                                            provider.selectDraftAnswer(
                                              currentQuestion.id,
                                              currentQuestion.options[i].value,
                                            ),
                                          );
                                        },
                                      ),
                                      if (i <
                                          currentQuestion.options.length - 1)
                                        const SizedBox(height: 10),
                                    ],
                                  ],
                                ),
                              ),
                            ),

                            // Bottom Action Bar (Previous / Next or Submit)
                            Padding(
                              padding: const EdgeInsets.fromLTRB(14, 6, 14, 12),
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: SizedBox(
                                          height: 48,
                                          child: OutlinedButton(
                                            onPressed: safeIndex > 0
                                                ? () => setState(() => _index--)
                                                : null,
                                            style: OutlinedButton.styleFrom(
                                              enableFeedback: false,
                                              backgroundColor: scheme.surface,
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(16),
                                              ),
                                            ),
                                            child: const Text(
                                              'Previous',
                                              style: TextStyle(
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        flex: 2,
                                        child: Container(
                                          height: 48,
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(
                                              16,
                                            ),
                                            gradient: const LinearGradient(
                                              colors: [
                                                Color(0xFF5D26C6),
                                                Color(0xFF8344E4),
                                              ],
                                            ),
                                            boxShadow: [
                                              BoxShadow(
                                                color: const Color(
                                                  0xFF6B2FD0,
                                                ).withAlpha(isDark ? 60 : 52),
                                                blurRadius: 14,
                                                offset: const Offset(0, 5),
                                              ),
                                            ],
                                          ),
                                          child: Material(
                                            color: Colors.transparent,
                                            borderRadius: BorderRadius.circular(
                                              16,
                                            ),
                                            clipBehavior: Clip.antiAlias,
                                            child: InkWell(
                                              enableFeedback: false,
                                              onTap: isLast
                                                  ? () =>
                                                        _handleSubmit(provider)
                                                  : () => setState(
                                                      () => _index++,
                                                    ),
                                              child: Center(
                                                child: Text(
                                                  isLast ? 'Submit' : 'Next',
                                                  style: const TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 15,
                                                    fontWeight: FontWeight.w700,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  if (answeredCount > 0) ...[
                                    const SizedBox(height: 6),
                                    Text(
                                      'Progress auto-saved locally ($answeredCount/$total)',
                                      style: textTheme.labelSmall?.copyWith(
                                        color: scheme.onSurfaceVariant,
                                      ),
                                    ),
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
        ],
      ),
    );
  }
}

class _ReferenceOptionCard extends StatelessWidget {
  const _ReferenceOptionCard({
    required this.index,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final int index;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final brightness = Theme.of(context).brightness;
    final isDark = brightness == Brightness.dark;
    final letter = String.fromCharCode('A'.codeUnitAt(0) + index);

    return Container(
      decoration: BoxDecoration(
        color: selected
            ? (isDark ? const Color(0xFF2B2054) : const Color(0xFFF4EEFF))
            : scheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: selected
              ? (isDark ? scheme.primary : const Color(0xFF7433D6))
              : scheme.outlineVariant.withAlpha(175),
          width: selected ? 1.8 : 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.cardShadow(brightness),
            blurRadius: 14,
            offset: const Offset(0, 5),
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
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
            child: Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: selected
                        ? (isDark ? scheme.primary : const Color(0xFF7433D6))
                        : (isDark
                              ? scheme.primaryContainer
                              : const Color(0xFFF3ECFF)),
                    borderRadius: BorderRadius.circular(13),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    letter,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: selected
                          ? Colors.white
                          : (isDark ? scheme.primary : const Color(0xFF6B2FD0)),
                    ),
                  ),
                ),
                const SizedBox(width: 13),
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(
                      fontSize: 14.2,
                      fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
                      height: 1.3,
                      color: isDark
                          ? scheme.onSurface
                          : const Color(0xFF17122B),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: selected
                        ? (isDark ? scheme.primary : const Color(0xFF7433D6))
                        : (isDark
                              ? scheme.surfaceContainerHighest
                              : const Color(0xFFF4EEFF)),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    selected
                        ? Icons.check_rounded
                        : Icons.arrow_forward_rounded,
                    size: 16,
                    color: selected
                        ? Colors.white
                        : (isDark ? scheme.primary : const Color(0xFF7433D6)),
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

class _QuizRingPainter extends CustomPainter {
  const _QuizRingPainter({required this.progress, required this.isDark});

  final double progress;
  final bool isDark;

  @override
  void paint(Canvas canvas, Size size) {
    const stroke = 5.5;
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
        ..color = isDark ? Colors.white.withAlpha(35) : const Color(0xFFDCD0F8)
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke,
    );
    if (progress > 0) {
      canvas.drawArc(
        rect,
        -math.pi / 2,
        math.pi * 2 * progress.clamp(0.0, 1.0),
        false,
        Paint()
          ..color = isDark ? AppColors.darkPrimary : const Color(0xFF6B2FD0)
          ..style = PaintingStyle.stroke
          ..strokeWidth = stroke
          ..strokeCap = StrokeCap.round,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _QuizRingPainter oldDelegate) =>
      oldDelegate.progress != progress || oldDelegate.isDark != isDark;
}

class _QuizBackdropPainter extends CustomPainter {
  const _QuizBackdropPainter({required this.isDark});

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
  bool shouldRepaint(covariant _QuizBackdropPainter oldDelegate) =>
      oldDelegate.isDark != isDark;
}

class _ClipboardBackdropPainter extends CustomPainter {
  const _ClipboardBackdropPainter({required this.isDark});

  final bool isDark;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final blob = Path()
      ..moveTo(w * 0.14, h)
      ..cubicTo(w * 0.04, h * 0.50, w * 0.24, h * 0.18, w * 0.62, h * 0.22)
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
  bool shouldRepaint(covariant _ClipboardBackdropPainter oldDelegate) =>
      oldDelegate.isDark != isDark;
}

/// Exact reference clipboard + tilted violet pencil illustration (PDF Page 5, zero 3-line sparkles).
class _QuizClipboardArtPainter extends CustomPainter {
  const _QuizClipboardArtPainter({required this.isDark});

  final bool isDark;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    canvas.save();
    canvas.translate(w * 0.44, h * 0.56);
    canvas.rotate(-0.10);

    // Clipboard board body
    final boardRect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset.zero, width: w * 0.58, height: h * 0.78),
      Radius.circular(w * 0.11),
    );
    canvas.drawRRect(
      boardRect,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF9362F2), Color(0xFF6B2FD0)],
        ).createShader(boardRect.outerRect),
    );

    // Inner white checklist sheet
    final sheetRect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(0, h * 0.03),
        width: w * 0.48,
        height: h * 0.64,
      ),
      Radius.circular(w * 0.07),
    );
    canvas.drawRRect(
      sheetRect,
      Paint()..color = isDark ? const Color(0xFF282046) : Colors.white,
    );

    // Top metallic-violet clipboard clasp
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(0, -h * 0.37),
          width: w * 0.28,
          height: h * 0.11,
        ),
        Radius.circular(w * 0.045),
      ),
      Paint()..color = const Color(0xFF5320AD),
    );

    // 3 purple checkboxes with checkmarks + lines
    final boxPaint = Paint()
      ..color = isDark ? const Color(0xFF3E2D73) : const Color(0xFFEBE1FF);
    final checkPaint = Paint()
      ..color = const Color(0xFF7433D6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final linePaint = Paint()
      ..color = const Color(0xFFC5AFFB)
      ..strokeWidth = 2.4
      ..strokeCap = StrokeCap.round;

    for (var i = 0; i < 3; i++) {
      final y = -h * 0.14 + i * h * 0.18;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: Offset(-w * 0.13, y),
            width: w * 0.11,
            height: w * 0.11,
          ),
          const Radius.circular(3),
        ),
        boxPaint,
      );
      final ck = Path()
        ..moveTo(-w * 0.16, y)
        ..lineTo(-w * 0.135, y + h * 0.025)
        ..lineTo(-w * 0.095, y - h * 0.025);
      canvas.drawPath(ck, checkPaint);
      canvas.drawLine(Offset(-w * 0.04, y), Offset(w * 0.16, y), linePaint);
    }

    canvas.restore();

    // Tilted violet-and-silver pencil on the right side (matching PDF Page 5!)
    canvas.save();
    canvas.translate(w * 0.78, h * 0.62);
    canvas.rotate(0.42);

    // Top eraser cap
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(0, -h * 0.30),
          width: w * 0.11,
          height: h * 0.10,
        ),
        Radius.circular(w * 0.04),
      ),
      Paint()..color = const Color(0xFF5320AD),
    );
    // Violet pencil barrel
    canvas.drawRect(
      Rect.fromCenter(center: Offset.zero, width: w * 0.11, height: h * 0.50),
      Paint()
        ..shader =
            const LinearGradient(colors: [Color(0xFF8C53EE), Color(0xFF5D26C6)])
                .createShader(
                  Rect.fromCenter(
                    center: Offset.zero,
                    width: w * 0.11,
                    height: h * 0.50,
                  ),
                ),
    );
    // Silver cone + dark tip
    final cone = Path()
      ..moveTo(-w * 0.055, h * 0.25)
      ..lineTo(w * 0.055, h * 0.25)
      ..lineTo(0, h * 0.39)
      ..close();
    canvas.drawPath(cone, Paint()..color = const Color(0xFFE5DEFA));
    final tip = Path()
      ..moveTo(-w * 0.022, h * 0.33)
      ..lineTo(w * 0.022, h * 0.33)
      ..lineTo(0, h * 0.39)
      ..close();
    canvas.drawPath(tip, Paint()..color = const Color(0xFF3E1D8A));

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _QuizClipboardArtPainter oldDelegate) =>
      oldDelegate.isDark != isDark;
}
