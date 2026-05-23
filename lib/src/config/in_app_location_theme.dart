import 'package:flutter/material.dart';

/// Visual defaults for bundled widgets — fully overridable.
class InAppLocationTheme {
  const InAppLocationTheme({
    this.primaryColor,
    this.scaffoldBackgroundColor,
    this.errorColor,
    this.buttonBorderRadius = 12,
    this.elevatedButtonPadding = const EdgeInsets.symmetric(vertical: 16),
    this.titleStyle,
    this.bodyStyle,
    this.illustration,
    this.permissionScreenBuilder,
    this.loadingIndicatorBuilder,
  });

  final Color? primaryColor;
  final Color? scaffoldBackgroundColor;
  final Color? errorColor;
  final double buttonBorderRadius;
  final EdgeInsets elevatedButtonPadding;
  final TextStyle? titleStyle;
  final TextStyle? bodyStyle;

  /// Replaces the default hero illustration on [InAppLocationPermissionScreen].
  final Widget? illustration;

  /// Wrap the entire permission screen (e.g. SafeArea, branding header).
  final Widget Function(BuildContext context, Widget child)?
      permissionScreenBuilder;

  /// Custom loading indicator for buttons and full-screen states.
  final Widget Function(BuildContext context)? loadingIndicatorBuilder;

  ThemeData mergeWith(ThemeData base) {
    final primary = primaryColor ?? base.colorScheme.primary;
    return base.copyWith(
      colorScheme: base.colorScheme.copyWith(primary: primary),
      scaffoldBackgroundColor:
          scaffoldBackgroundColor ?? base.scaffoldBackgroundColor,
    );
  }

  ButtonStyle elevatedButtonStyle(ThemeData theme) {
    return ElevatedButton.styleFrom(
      backgroundColor: primaryColor ?? theme.colorScheme.primary,
      foregroundColor: theme.colorScheme.onPrimary,
      padding: elevatedButtonPadding,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(buttonBorderRadius),
      ),
    );
  }

  ButtonStyle outlinedButtonStyle(ThemeData theme) {
    return OutlinedButton.styleFrom(
      padding: elevatedButtonPadding,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(buttonBorderRadius),
      ),
    );
  }
}
