import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../constants/app_routes.dart';

/// Centralized safe navigation helpers for GoRouter across all screens:
/// - Prevents GoError on empty back stacks via [safePop]
/// - Prevents stacking duplicate routes (e.g. tapping Profile while on Profile)
/// - Keeps root tab switching consistent
extension AppNavigationX on BuildContext {
  void safePop({String fallback = AppRoutes.home}) {
    if (canPop()) {
      pop();
    } else {
      go(fallback);
    }
  }

  void pushUnique(String location) {
    final currentUri = GoRouterState.of(this).uri.toString();
    if (currentUri == location) return;
    push(location);
  }

  void switchRootTab(String route) {
    final currentPath = GoRouterState.of(this).uri.path;
    if (currentPath == route) return;
    go(route);
  }
}
