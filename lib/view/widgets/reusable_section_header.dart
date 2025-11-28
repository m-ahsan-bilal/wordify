import 'package:flutter/material.dart';
import '../../core/utils/app_colors.dart';

/// Reusable Section Header Widget
/// Provides consistent section title styling with optional required indicator
class ReusableSectionHeader extends StatelessWidget {
  final String title;
  final bool isRequired;
  final TextStyle? textStyle;
  final EdgeInsets? padding;

  const ReusableSectionHeader({
    super.key,
    required this.title,
    this.isRequired = false,
    this.textStyle,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    if (isRequired) {
      return Padding(
        padding: padding ?? EdgeInsets.zero,
        child: Row(
          children: [
            Text(
              title,
              style: textStyle ??
                  TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: ThemeColors.getTextColor(context),
                  ),
            ),
            Text(
              ' *',
              style: TextStyle(
                fontSize: 16,
                color: Theme.of(context).colorScheme.error,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: padding ?? EdgeInsets.zero,
      child: Text(
        title,
        style: textStyle ??
            TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: ThemeColors.getTextColor(context),
            ),
      ),
    );
  }
}

