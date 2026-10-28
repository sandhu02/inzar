import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

enum AppButtonVariant {
  primary,
  secondaryLight,
  secondaryDark,
  outline,
}

class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final IconData? icon;
  final Widget? leading;
  final bool isFullWidth;
  final double height;
  final double borderRadius;
  final bool isLoading;

  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.icon,
    this.leading,
    this.isFullWidth = false,
    this.height = 50,
    this.borderRadius = 25, // Soft pill shape as in mockups
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color textColor;
    Border? border;

    switch (variant) {
      case AppButtonVariant.primary:
        bg = AppColors.primary;
        textColor = Colors.white;
        border = null;
        break;
      case AppButtonVariant.secondaryLight:
        bg = AppColors.buttonLight;
        textColor = AppColors.buttonLightText;
        border = null;
        break;
      case AppButtonVariant.secondaryDark:
        bg = AppColors.buttonDark;
        textColor = AppColors.textPrimary;
        border = Border.all(color: AppColors.buttonDarkBorder, width: 1);
        break;
      case AppButtonVariant.outline:
        bg = Colors.transparent;
        textColor = AppColors.textPrimary;
        border = Border.all(color: AppColors.borderLight, width: 1);
        break;
    }

    Widget content;
    if (isLoading) {
      content = SizedBox(
        height: 20,
        width: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(textColor),
        ),
      );
    } else {
      content = Row(
        mainAxisSize: isFullWidth ? MainAxisSize.max : MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (leading != null) ...[
            leading!,
            const SizedBox(width: 10),
          ] else if (icon != null) ...[
            Icon(icon, size: 18, color: textColor),
            const SizedBox(width: 8),
          ],
          Text(
            label,
            style: AppTypography.buttonText.copyWith(color: textColor),
          ),
        ],
      );
    }

    final buttonWidget = AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      height: height,
      decoration: BoxDecoration(
        color: onPressed == null ? bg.withValues(alpha: 0.4) : bg,
        borderRadius: BorderRadius.circular(borderRadius),
        border: border,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(borderRadius),
          onTap: isLoading ? null : onPressed,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Center(child: content),
          ),
        ),
      ),
    );

    if (isFullWidth) {
      return SizedBox(
        width: double.infinity,
        child: buttonWidget,
      );
    }

    return buttonWidget;
  }
}
