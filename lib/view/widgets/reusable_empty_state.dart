import 'package:flutter/material.dart';
import '../../core/utils/app_colors.dart';

/// Reusable Empty State Widget
/// Provides consistent empty state UI across the app
class ReusableEmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? actionButton;
  final double? iconSize;
  final Color? iconColor;

  const ReusableEmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.actionButton,
    this.iconSize,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: iconSize ?? 64,
              color: iconColor ?? ThemeColors.getSecondaryTextColor(context),
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: ThemeColors.getTextColor(context),
              ),
              textAlign: TextAlign.center,
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 8),
              Text(
                subtitle!,
                style: TextStyle(
                  fontSize: 14,
                  color: ThemeColors.getSecondaryTextColor(context),
                ),
                textAlign: TextAlign.center,
              ),
            ],
            if (actionButton != null) ...[
              const SizedBox(height: 32),
              actionButton!,
            ],
          ],
        ),
      ),
    );
  }
}

