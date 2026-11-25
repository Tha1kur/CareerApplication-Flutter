import 'package:material_ui/material_ui.dart';

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
    final scheme = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          begin: horizontalGradient ? Alignment.centerLeft : Alignment.topLeft,
          end: horizontalGradient
              ? Alignment.centerRight
              : Alignment.bottomRight,
          colors: [scheme.primary, scheme.primaryContainer],
        ),
        boxShadow: [
          BoxShadow(
            color: scheme.primary.withAlpha(35),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(padding: padding, child: child),
    );
  }
}
