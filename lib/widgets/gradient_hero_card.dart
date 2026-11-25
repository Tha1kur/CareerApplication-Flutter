import 'package:material_ui/material_ui.dart';

import '../core/theme/app_colors.dart';

class GradientHeroCard extends StatelessWidget {
  const GradientHeroCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(20),
    this.horizontalGradient = false,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final bool horizontalGradient;

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: LinearGradient(
          begin: horizontalGradient ? Alignment.centerLeft : Alignment.topLeft,
          end: horizontalGradient
              ? Alignment.centerRight
              : Alignment.bottomRight,
          colors: AppColors.primaryGradient(brightness),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.lightPrimary.withAlpha(
              brightness == Brightness.dark ? 65 : 52,
            ),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Padding(padding: padding, child: child),
    );
  }
}
