import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

/// Mobbin / Material 3 Expressive transition builders for GoRouter:
/// 1. [buildFadePage]: Clean 240ms crossfade (Splash -> Welcome -> Home).
/// 2. [buildTabPage]: Crisp 180ms Fade-Through for peer bottom-nav tabs inside ShellRoute
///    (keeps bottom navigation completely stationary with zero jarring zoom/slide).
/// 3. [buildSharedAxisPage]: Material 3 Shared-Axis Horizontal slide + fade (250ms forward,
///    210ms reverse, easeOutCubic) for hierarchical pushed screens.
CustomTransitionPage<T> buildFadePage<T>({
  required LocalKey key,
  required Widget child,
  Duration duration = const Duration(milliseconds: 240),
}) {
  return CustomTransitionPage<T>(
    key: key,
    child: child,
    transitionDuration: duration,
    reverseTransitionDuration: const Duration(milliseconds: 200),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      if (MediaQuery.disableAnimationsOf(context)) return child;
      final curved = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
      );
      return FadeTransition(opacity: curved, child: child);
    },
  );
}

CustomTransitionPage<T> buildTabPage<T>({
  required LocalKey key,
  required Widget child,
}) {
  return CustomTransitionPage<T>(
    key: key,
    child: child,
    transitionDuration: const Duration(milliseconds: 185),
    reverseTransitionDuration: const Duration(milliseconds: 150),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      if (MediaQuery.disableAnimationsOf(context)) return child;
      final fade = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOut,
      );
      final scale = Tween<double>(begin: 0.988, end: 1.0).animate(
        CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
      );
      return FadeTransition(
        opacity: fade,
        child: ScaleTransition(scale: scale, child: child),
      );
    },
  );
}

CustomTransitionPage<T> buildSharedAxisPage<T>({
  required LocalKey key,
  required Widget child,
}) {
  return CustomTransitionPage<T>(
    key: key,
    child: child,
    transitionDuration: const Duration(milliseconds: 250),
    reverseTransitionDuration: const Duration(milliseconds: 210),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      if (MediaQuery.disableAnimationsOf(context)) return child;

      final incomingSlide = Tween<Offset>(
        begin: const Offset(0.08, 0.0),
        end: Offset.zero,
      ).animate(
        CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
          reverseCurve: Curves.easeInCubic,
        ),
      );

      final incomingFade = CurvedAnimation(
        parent: animation,
        curve: const Interval(0.0, 0.78, curve: Curves.easeOut),
        reverseCurve: Curves.easeIn,
      );

      final outgoingSlide = Tween<Offset>(
        begin: Offset.zero,
        end: const Offset(-0.04, 0.0),
      ).animate(
        CurvedAnimation(
          parent: secondaryAnimation,
          curve: Curves.easeOutCubic,
          reverseCurve: Curves.easeInCubic,
        ),
      );

      return SlideTransition(
        position: outgoingSlide,
        child: SlideTransition(
          position: incomingSlide,
          child: FadeTransition(
            opacity: incomingFade,
            child: child,
          ),
        ),
      );
    },
  );
}
