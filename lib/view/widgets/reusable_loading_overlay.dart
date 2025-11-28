import 'package:flutter/material.dart';

/// Reusable Loading Overlay Widget
/// Provides consistent loading indicator overlay
class ReusableLoadingOverlay extends StatelessWidget {
  final bool isLoading;
  final Widget child;
  final Color? overlayColor;
  final Color? indicatorColor;

  const ReusableLoadingOverlay({
    super.key,
    required this.isLoading,
    required this.child,
    this.overlayColor,
    this.indicatorColor,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isLoading)
          Container(
            color: overlayColor ?? 
                (Theme.of(context).brightness == Brightness.dark
                    ? Colors.black.withValues(alpha: 0.5)
                    : Colors.black.withValues(alpha: 0.3)),
            child: Center(
              child: CircularProgressIndicator(
                valueColor: indicatorColor != null
                    ? AlwaysStoppedAnimation<Color>(indicatorColor!)
                    : null,
              ),
            ),
          ),
      ],
    );
  }
}

