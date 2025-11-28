import 'package:flutter/material.dart';
import '../../core/utils/app_colors.dart';

/// Reusable Card Container Widget
/// Provides consistent card styling across the app
/// Follows the app's design system
class ReusableCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final double? borderRadius;
  final Color? backgroundColor;
  final List<BoxShadow>? boxShadow;
  final double? elevation;
  final Border? border;

  const ReusableCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.borderRadius,
    this.backgroundColor,
    this.boxShadow,
    this.elevation,
    this.border,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      padding: padding ?? const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: backgroundColor ?? ThemeColors.getCardColor(context),
        borderRadius: BorderRadius.circular(borderRadius ?? 16),
        border: border,
        boxShadow: boxShadow ??
            [
              BoxShadow(
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.black.withValues(alpha: 0.3)
                    : Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
      ),
      child: child,
    );
  }
}

