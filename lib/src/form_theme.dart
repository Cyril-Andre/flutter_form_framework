import 'package:flutter/material.dart';

/// Theme data for the form and its input widgets.
///
/// When a color is null, the framework uses Material 3 theme colors
/// from [ThemeData] (e.g. [ColorScheme.surface], [ColorScheme.onSurface]).
class FormThemeData {
  const FormThemeData({
    this.formBackgroundColor,
    this.formForegroundColor,
    this.inputBackgroundColor,
    this.inputForegroundColor,
    this.readonlyBackgroundColor,
    this.readonlyForegroundColor,
  });

  /// Background color of the form container. Null = use theme surface.
  final Color? formBackgroundColor;

  /// Foreground color for the form container content. Null = use theme onSurface.
  final Color? formForegroundColor;

  /// Background color of input widgets (text field, dropdown, etc.). Null = use theme.
  final Color? inputBackgroundColor;

  /// Foreground color of input widgets. Null = use theme.
  final Color? inputForegroundColor;

  /// Background color when [readonly] is true. Null = use theme surfaceContainerHighest or similar.
  final Color? readonlyBackgroundColor;

  /// Foreground color when [readonly] is true. Null = use theme onSurfaceVariant or similar.
  final Color? readonlyForegroundColor;

  /// Resolve form container background, falling back to theme.
  Color formBackground(BuildContext context) {
    final theme = Theme.of(context);
    return formBackgroundColor ?? theme.colorScheme.surface;
  }

  /// Resolve form container foreground, falling back to theme.
  Color formForeground(BuildContext context) {
    final theme = Theme.of(context);
    return formForegroundColor ?? theme.colorScheme.onSurface;
  }

  /// Resolve input background, falling back to theme.
  Color inputBackground(BuildContext context) {
    final theme = Theme.of(context);
    return inputBackgroundColor ?? theme.colorScheme.surfaceContainerHighest;
  }

  /// Resolve input foreground, falling back to theme.
  Color inputForeground(BuildContext context) {
    final theme = Theme.of(context);
    return inputForegroundColor ?? theme.colorScheme.onSurface;
  }

  /// Resolve readonly background.
  Color readonlyBackground(BuildContext context) {
    final theme = Theme.of(context);
    return readonlyBackgroundColor ?? theme.colorScheme.surfaceContainerHigh;
  }

  /// Resolve readonly foreground.
  Color readonlyForeground(BuildContext context) {
    final theme = Theme.of(context);
    return readonlyForegroundColor ?? theme.colorScheme.onSurfaceVariant;
  }

  FormThemeData copyWith({
    Color? formBackgroundColor,
    Color? formForegroundColor,
    Color? inputBackgroundColor,
    Color? inputForegroundColor,
    Color? readonlyBackgroundColor,
    Color? readonlyForegroundColor,
  }) {
    return FormThemeData(
      formBackgroundColor: formBackgroundColor ?? this.formBackgroundColor,
      formForegroundColor: formForegroundColor ?? this.formForegroundColor,
      inputBackgroundColor: inputBackgroundColor ?? this.inputBackgroundColor,
      inputForegroundColor: inputForegroundColor ?? this.inputForegroundColor,
      readonlyBackgroundColor:
          readonlyBackgroundColor ?? this.readonlyBackgroundColor,
      readonlyForegroundColor:
          readonlyForegroundColor ?? this.readonlyForegroundColor,
    );
  }
}
