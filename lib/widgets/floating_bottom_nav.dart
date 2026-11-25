import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../core/constants/app_routes.dart';
import '../core/theme/app_colors.dart';

enum CareerGuideTab { home, explore, saved, profile }

/// Stationary rounded white bottom navigation bar with a single liquid-sliding
/// lavender pill indicator (zero jitter, zero tap click sounds).
class FloatingBottomNav extends StatelessWidget {
  const FloatingBottomNav({
    super.key,
    required this.currentTab,
    this.onTabSelected,
    this.onExploreTap,
  });

  final CareerGuideTab currentTab;
  final ValueChanged<CareerGuideTab>? onTabSelected;
  final VoidCallback? onExploreTap;

  int get _activeIndex => switch (currentTab) {
    CareerGuideTab.home => 0,
    CareerGuideTab.explore => 1,
    CareerGuideTab.saved => 2,
    CareerGuideTab.profile => 3,
  };

  void _handleTap(BuildContext context, CareerGuideTab tab) {
    if (onTabSelected != null) {
      onTabSelected!(tab);
      return;
    }
    if (tab == currentTab) return;
    switch (tab) {
      case CareerGuideTab.home:
        context.go(AppRoutes.home);
      case CareerGuideTab.explore:
        if (onExploreTap != null) {
          onExploreTap!();
        } else {
          context.go(AppRoutes.explore);
        }
      case CareerGuideTab.saved:
        context.push(AppRoutes.saved);
      case CareerGuideTab.profile:
        context.push(AppRoutes.profile);
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final shadow = AppColors.cardShadow(Theme.of(context).brightness);

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 2, 12, 10),
        child: Container(
          height: 70,
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: scheme.surface,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: scheme.outlineVariant.withAlpha(180)),
            boxShadow: [
              BoxShadow(
                color: shadow,
                blurRadius: 18,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final tabWidth = constraints.maxWidth / 4;
              return Stack(
                children: [
                  // Single smooth liquid-gliding lavender active pill
                  AnimatedPositioned(
                    duration: const Duration(milliseconds: 260),
                    curve: Curves.easeOutCubic,
                    left: _activeIndex * tabWidth,
                    top: 0,
                    bottom: 0,
                    width: tabWidth,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: isDark
                            ? scheme.primaryContainer
                            : const Color(0xFFF3ECFF),
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      _NavItem(
                        label: 'Home',
                        icon: Icons.home_outlined,
                        selectedIcon: Icons.home_rounded,
                        selected: currentTab == CareerGuideTab.home,
                        isDark: isDark,
                        onTap: () => _handleTap(context, CareerGuideTab.home),
                      ),
                      _NavItem(
                        label: 'Explore',
                        icon: Icons.explore_outlined,
                        selectedIcon: Icons.explore_rounded,
                        selected: currentTab == CareerGuideTab.explore,
                        isDark: isDark,
                        onTap: () =>
                            _handleTap(context, CareerGuideTab.explore),
                      ),
                      _NavItem(
                        label: 'Saved',
                        icon: Icons.bookmark_border_rounded,
                        selectedIcon: Icons.bookmark_rounded,
                        selected: currentTab == CareerGuideTab.saved,
                        isDark: isDark,
                        onTap: () => _handleTap(context, CareerGuideTab.saved),
                      ),
                      _NavItem(
                        label: 'Profile',
                        icon: Icons.person_outline_rounded,
                        selectedIcon: Icons.person_rounded,
                        selected: currentTab == CareerGuideTab.profile,
                        isDark: isDark,
                        onTap: () =>
                            _handleTap(context, CareerGuideTab.profile),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.label,
    required this.icon,
    required this.selectedIcon,
    required this.selected,
    required this.isDark,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final IconData selectedIcon;
  final bool selected;
  final bool isDark;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final activeColor = isDark ? scheme.primary : const Color(0xFF7433D6);
    final inactiveColor = isDark
        ? scheme.onSurfaceVariant
        : const Color(0xFF3E3856);
    final fg = selected ? activeColor : inactiveColor;

    return Expanded(
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(18),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          enableFeedback: false,
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          onTap: onTap,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedScale(
                scale: selected ? 1.06 : 1.0,
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOutCubic,
                child: Icon(
                  selected ? selectedIcon : icon,
                  size: 24,
                  color: fg,
                ),
              ),
              const SizedBox(height: 3),
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOutCubic,
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                  color: fg,
                ),
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
