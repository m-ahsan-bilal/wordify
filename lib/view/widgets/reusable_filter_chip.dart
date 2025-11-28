import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/utils/app_colors.dart';

/// Reusable Filter Chip Widget
/// Provides consistent filter chip styling
class ReusableFilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final Color? selectedColor;
  final Color? unselectedColor;
  final EdgeInsets? padding;
  final double? borderRadius;
  final TextStyle? textStyle;

  const ReusableFilterChip({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.selectedColor,
    this.unselectedColor,
    this.padding,
    this.borderRadius,
    this.textStyle,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final defaultSelectedColor = selectedColor ?? ThemeColors.getButtonColor(context);
    final defaultUnselectedColor = unselectedColor ?? 
        (isDark ? AppColors.darkSurface : AppColors.lightLavender);
    
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      child: Container(
        padding: padding ?? const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? defaultSelectedColor : defaultUnselectedColor,
          borderRadius: BorderRadius.circular(borderRadius ?? 20),
        ),
        child: Text(
          label,
          style: textStyle ??
              TextStyle(
                color: ThemeColors.getTextColor(context),
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                fontSize: 14,
              ),
        ),
      ),
    );
  }
}

