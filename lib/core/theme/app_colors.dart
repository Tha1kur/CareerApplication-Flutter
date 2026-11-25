import 'package:material_ui/material_ui.dart';

/// Core brand color tokens aligned with the original Career Guidance Community identity.
abstract final class AppColors {
  // Light palette
  static const Color lightPrimary = Color(0xFF1565C0);
  static const Color lightOnPrimary = Color(0xFFFFFFFF);
  static const Color lightPrimaryContainer = Color(0xFFD7E9FF);
  static const Color lightOnPrimaryContainer = Color(0xFF001B36);

  static const Color lightSecondary = Color(0xFF00695C);
  static const Color lightOnSecondary = Color(0xFFFFFFFF);
  static const Color lightSecondaryContainer = Color(0xFFC8F0EA);
  static const Color lightOnSecondaryContainer = Color(0xFF00201C);

  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightBackground = Color(0xFFF6F8FB);
  static const Color lightOnBackground = Color(0xFF1B1B1F);
  static const Color lightError = Color(0xFFB00020);

  // Dark palette
  static const Color darkPrimary = Color(0xFF90CAF9);
  static const Color darkOnPrimary = Color(0xFF003352);
  static const Color darkPrimaryContainer = Color(0xFF004A79);
  static const Color darkOnPrimaryContainer = Color(0xFFD7E9FF);

  static const Color darkSecondary = Color(0xFF4DB6AC);
  static const Color darkOnSecondary = Color(0xFF00201C);
  static const Color darkSecondaryContainer = Color(0xFF004D43);
  static const Color darkOnSecondaryContainer = Color(0xFFC8F0EA);

  static const Color darkSurface = Color(0xFF121A26);
  static const Color darkBackground = Color(0xFF0B1220);
  static const Color darkOnBackground = Color(0xFFE6EEF6);
  static const Color darkError = Color(0xFFFFB4AB);

  // Semantic accents
  static const Color success = Color(0xFF2E7D32);
  static const Color warning = Color(0xFFEF6C00);
}
