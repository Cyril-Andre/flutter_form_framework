import 'package:flutter/material.dart';
import 'package:flutter_form_framework/flutter_form_framework.dart';

/// Form themes available in the example.
enum AppFormTheme {
  light,
  dark,
  ocean,
}

extension AppFormThemeExtension on AppFormTheme {
  String get label {
    switch (this) {
      case AppFormTheme.light:
        return 'Light';
      case AppFormTheme.dark:
        return 'Dark';
      case AppFormTheme.ocean:
        return 'Ocean';
    }
  }

  FormThemeData get themeData {
    switch (this) {
      case AppFormTheme.light:
        return _lightTheme;
      case AppFormTheme.dark:
        return _darkTheme;
      case AppFormTheme.ocean:
        return _oceanTheme;
    }
  }
}

/// Light theme: white / very light grey background, neutral colors.
/// Readonly: slightly darker than editable (grey 300 vs white).
final _lightTheme = FormThemeData(
  formBackgroundColor: Colors.grey.shade50,
  formForegroundColor: Colors.grey.shade900,
  inputBackgroundColor: Colors.white,
  inputForegroundColor: Colors.grey.shade900,
  readonlyBackgroundColor: Colors.grey.shade300,
  readonlyForegroundColor: Colors.grey.shade700,
);

/// Dark theme: dark grey background, light text.
/// Readonly: slightly darker than editable (grey 900 vs 800).
final _darkTheme = FormThemeData(
  formBackgroundColor: Colors.grey.shade900,
  formForegroundColor: Colors.grey.shade100,
  inputBackgroundColor: Colors.grey.shade800,
  inputForegroundColor: Colors.grey.shade100,
  readonlyBackgroundColor: Colors.grey.shade900,
  readonlyForegroundColor: Colors.grey.shade300,
);

/// Ocean theme: teal/cyan tones, nautical feel.
/// Readonly: slightly darker than editable (darker teal than white).
final _oceanTheme = FormThemeData(
  formBackgroundColor: const Color(0xFFE0F7FA),
  formForegroundColor: const Color(0xFF004D40),
  inputBackgroundColor: Colors.white,
  inputForegroundColor: const Color(0xFF00695C),
  readonlyBackgroundColor: const Color(0xFF80CBC4),
  readonlyForegroundColor: const Color(0xFF004D40),
);
