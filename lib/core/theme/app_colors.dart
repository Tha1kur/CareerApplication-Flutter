import 'package:material_ui/material_ui.dart';

/// CareerGuide Lavender & White design system tokens (Light + Dark modes).
abstract final class AppColors {
  // Light palette (Approved CareerGuide Lavender & White)
  static const Color lightBackground = Color(0xFFF6F3FF);
  static const Color lightBackgroundTop = Color(0xFFEEE8FF);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightSurfaceTint = Color(0xFFF3EEFF);
  static const Color lightCardBorder = Color(0xFFE9E2FB);

  static const Color lightPrimary = Color(0xFF6D28D9);
  static const Color lightPrimaryDeep = Color(0xFF5B21B6);
  static const Color lightPrimaryBright = Color(0xFF8B5CF6);
  static const Color lightOnPrimary = Color(0xFFFFFFFF);
  static const Color lightPrimaryContainer = Color(0xFFEDE9FE);
  static const Color lightOnPrimaryContainer = Color(0xFF2E1065);

  static const Color lightSecondary = Color(0xFF7C3AED);
  static const Color lightOnSecondary = Color(0xFFFFFFFF);
  static const Color lightSecondaryContainer = Color(0xFFF3EEFF);
  static const Color lightOnSecondaryContainer = Color(0xFF3B1D7A);

  static const Color lightInk = Color(0xFF1E1B3A);
  static const Color lightMutedInk = Color(0xFF655F80);
  static const Color lightError = Color(0xFFDC2626);

  // Dark palette (Midnight Violet)
  static const Color darkBackground = Color(0xFF0F0B1E);
  static const Color darkBackgroundTop = Color(0xFF181132);
  static const Color darkSurface = Color(0xFF1A1430);
  static const Color darkSurfaceTint = Color(0xFF251D42);
  static const Color darkCardBorder = Color(0xFF2E2452);

  static const Color darkPrimary = Color(0xFFB794F6);
  static const Color darkPrimaryDeep = Color(0xFF5B21B6);
  static const Color darkPrimaryBright = Color(0xFF9F7AEA);
  static const Color darkOnPrimary = Color(0xFF1E0B4B);
  static const Color darkPrimaryContainer = Color(0xFF3B1D7A);
  static const Color darkOnPrimaryContainer = Color(0xFFEDE9FE);

  static const Color darkSecondary = Color(0xFFC4B5FD);
  static const Color darkOnSecondary = Color(0xFF24104D);
  static const Color darkSecondaryContainer = Color(0xFF2B1C54);
  static const Color darkOnSecondaryContainer = Color(0xFFEDE9FE);

  static const Color darkInk = Color(0xFFF3F0FF);
  static const Color darkMutedInk = Color(0xFFB2A9CE);
  static const Color darkError = Color(0xFFFCA5A5);

  // Shared semantic & duotone accents
  static const Color accentGold = Color(0xFFF59E0B);
  static const Color accentGoldLight = Color(0xFFFCD34D);
  static const Color duotoneLavender = Color(0xFFD8CCFA);
  static const Color duotoneSoftLavender = Color(0xFFEDE9FE);
  static const Color success = Color(0xFF16A34A);
  static const Color warning = Color(0xFFEA580C);

  static List<Color> primaryGradient(Brightness brightness) {
    return brightness == Brightness.dark
        ? const [Color(0xFF4C1D95), Color(0xFF6D28D9), Color(0xFF7C3AED)]
        : const [Color(0xFF5B21B6), Color(0xFF7C3AED), Color(0xFF8B5CF6)];
  }

  static Color cardShadow(Brightness brightness) {
    return brightness == Brightness.dark
        ? const Color(0x40000000)
        : const Color(0x165B21B6);
  }
}
