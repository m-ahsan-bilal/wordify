import 'package:flutter/material.dart';
import '../../core/utils/app_colors.dart';

/// Reusable Text Form Field Widget
/// Provides consistent styling and behavior across the app
/// Follows the app's design system and theme
class ReusableTextField extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode? focusNode;
  final FocusNode? nextFocusNode;
  final String? hintText;
  final String? labelText;
  final String? Function(String?)? validator;
  final int? maxLines;
  final TextInputAction? textInputAction;
  final bool enabled;
  final bool readOnly;
  final TextInputType? keyboardType;
  final String? helperText;
  final bool isRequired;
  final Color? fillColor;
  final TextStyle? textStyle;
  final TextStyle? hintStyle;
  final EdgeInsets? contentPadding;
  final double? borderRadius;
  final void Function(String)? onChanged;
  final void Function()? onTap;
  final void Function(String)? onFieldSubmitted;

  const ReusableTextField({
    super.key,
    required this.controller,
    this.focusNode,
    this.nextFocusNode,
    this.hintText,
    this.labelText,
    this.validator,
    this.maxLines = 1,
    this.textInputAction,
    this.enabled = true,
    this.readOnly = false,
    this.keyboardType,
    this.helperText,
    this.isRequired = false,
    this.fillColor,
    this.textStyle,
    this.hintStyle,
    this.contentPadding,
    this.borderRadius,
    this.onChanged,
    this.onTap,
    this.onFieldSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    // Determine text input action
    final inputAction = textInputAction ??
        (nextFocusNode != null ? TextInputAction.next : TextInputAction.done);

    // Determine onFieldSubmitted callback
    final onSubmitted = onFieldSubmitted ??
        (nextFocusNode != null
            ? (_) => nextFocusNode?.requestFocus()
            : null);

    return TextFormField(
      controller: controller,
      focusNode: focusNode,
      textInputAction: inputAction,
      onFieldSubmitted: onSubmitted,
      onChanged: onChanged,
      onTap: onTap,
      maxLines: maxLines,
      enabled: enabled,
      readOnly: readOnly,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: labelText,
        hintText: hintText,
        helperText: helperText,
        hintStyle: hintStyle ??
            TextStyle(
              color: ThemeColors.getSecondaryTextColor(context)
                  .withValues(alpha: 0.7),
            ),
        filled: true,
        fillColor: fillColor ?? 
            (Theme.of(context).brightness == Brightness.dark
                ? AppColors.darkSurface
                : AppColors.inputFieldBackground),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius ?? 12),
          borderSide: BorderSide(
            color: ThemeColors.getBorderColor(context).withValues(alpha: 0.5),
            width: 1,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius ?? 12),
          borderSide: BorderSide(
            color: ThemeColors.getBorderColor(context).withValues(alpha: 0.5),
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius ?? 12),
          borderSide: BorderSide(
            color: ThemeColors.getButtonColor(context),
            width: 2,
          ),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius ?? 12),
          borderSide: BorderSide(
            color: ThemeColors.getBorderColor(context).withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius ?? 12),
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.error,
            width: 1,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius ?? 12),
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.error,
            width: 2,
          ),
        ),
        contentPadding: contentPadding ??
            const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
      ),
      style: textStyle ??
          TextStyle(
            fontSize: maxLines != null && maxLines! > 1 ? 14 : 16,
            fontWeight: FontWeight.w500,
            color: ThemeColors.getTextColor(context),
          ),
      validator: validator ??
          (isRequired
              ? (v) => v == null || v.trim().isEmpty
                  ? 'This field is required'
                  : null
              : null),
    );
  }
}

