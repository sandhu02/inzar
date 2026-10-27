import 'package:flutter/material.dart';
import '../../../core/design_system/radius_selector.dart';
import '../../../core/design_system/app_button.dart';

class RadiusBar extends StatelessWidget {
  final int selectedRadiusKm;
  final ValueChanged<int> onRadiusSelected;
  final VoidCallback onReportPressed;

  const RadiusBar({
    super.key,
    required this.selectedRadiusKm,
    required this.onRadiusSelected,
    required this.onReportPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          // Segmented Radius Selector
          RadiusSelector(
            selectedRadiusKm: selectedRadiusKm,
            onRadiusSelected: onRadiusSelected,
          ),
          const SizedBox(width: 10),

          // Prominent "+ Report" Button
          Expanded(
            child: AppButton(
              label: '+ Report',
              variant: AppButtonVariant.primary,
              height: 48,
              borderRadius: 16,
              onPressed: onReportPressed,
            ),
          ),
        ],
      ),
    );
  }
}
