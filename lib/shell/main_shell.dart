import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_typography.dart';

class MainShell extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const MainShell({
    super.key,
    required this.navigationShell,
  });

  @override
  Widget build(BuildContext context) {
    final currentIndex = navigationShell.currentIndex;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: navigationShell,
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: AppColors.background,
          border: Border(
            top: BorderSide(color: Color(0xFF1E2530), width: 1),
          ),
        ),
        child: SafeArea(
          top: false,
          child: SizedBox(
            height: 60,
            child: Row(
              children: [
                _buildNavItem(
                  index: 0,
                  label: 'Map',
                  icon: Icons.map_outlined,
                  isSelected: currentIndex == 0,
                  onTap: () => navigationShell.goBranch(0),
                ),
                _buildNavItem(
                  index: 1,
                  label: 'Activity',
                  icon: Icons.menu_rounded,
                  isSelected: currentIndex == 1,
                  onTap: () => navigationShell.goBranch(1),
                ),
                _buildNavItem(
                  index: 2,
                  label: 'Settings',
                  icon: Icons.tune_rounded,
                  isSelected: currentIndex == 2,
                  onTap: () => navigationShell.goBranch(2),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required String label,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Active orange line indicator on top of selected tab (matches Page 6 design)
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                height: 2.5,
                width: isSelected ? 48 : 0,
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Nav item Icon & Label
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    icon,
                    size: 22,
                    color: isSelected ? AppColors.textPrimary : AppColors.textMuted,
                  ),
                  const SizedBox(height: 3),
                  Text(
                    label,
                    style: AppTypography.buttonText.copyWith(
                      fontSize: 12,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                      color: isSelected ? AppColors.textPrimary : AppColors.textMuted,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
            ],
          ),
        ),
      ),
    );
  }
}

