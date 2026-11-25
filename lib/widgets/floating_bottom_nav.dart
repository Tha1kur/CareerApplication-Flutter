import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../core/constants/app_routes.dart';
import '../core/theme/app_colors.dart';

enum CareerGuideTab { home, explore, saved, profile }

/// Fixed rounded white bottom navigation bar matching the CareerGuide reference
/// (Home / Explore / Saved / Profile, zero tap click sounds).
class FloatingBottomNav extends StatelessWidget {
  const FloatingBottomNav({
    super.key,
    required this.currentTab,
    this.onExploreTap,
  });

  final CareerGuideTab currentTab;
  final VoidCallback? onExploreTap;

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
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
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
          child: Row(
            children: [
              _NavItem(
                label: 'Home',
                icon: Icons.home_outlined,
                selectedIcon: Icons.home_rounded,
                selected: currentTab == CareerGuideTab.home,
                isDark: isDark,
                onTap: () {
                  if (currentTab != CareerGuideTab.home) {
                    context.go(AppRoutes.home);
                  }
                },
              ),
              _NavItem(
                label: 'Explore',
                icon: Icons.explore_outlined,
                selectedIcon: Icons.explore_rounded,
                selected: currentTab == CareerGuideTab.explore,
                isDark: isDark,
                onTap: onExploreTap ??
                    () {
                      if (currentTab != CareerGuideTab.explore) {
                        context.go(AppRoutes.explore);
                      }
                    },
              ),
              _NavItem(
                label: 'Saved',
                icon: Icons.bookmark_border_rounded,
                selectedIcon: Icons.bookmark_rounded,
                selected: currentTab == CareerGuideTab.saved,
                isDark: isDark,
                onTap: () {
                  if (currentTab != CareerGuideTab.saved) {
                    context.push(AppRoutes.saved);
                  }
                },
              ),
              _NavItem(
                label: 'Profile',
                icon: Icons.person_outline_rounded,
                selectedIcon: Icons.person_rounded,
                selected: currentTab == CareerGuideTab.profile,
                isDark: isDark,
                onTap: () {
                  if (currentTab != CareerGuideTab.profile) {
                    context.push(AppRoutes.profile);
                  }
                },
              ),
            ],
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
        color: selected
            ? (isDark ? scheme.primaryContainer : const Color(0xFFF3ECFF))
            : Colors.transparent,
        borderRadius: BorderRadius.circular(18),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          enableFeedback: false,
          onTap: onTap,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(selected ? selectedIcon : icon, size: 24, color: fg),
              const SizedBox(height: 3),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                  color: fg,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
