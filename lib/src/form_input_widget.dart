import 'package:flutter/material.dart';
import 'form_container.dart';

/// Base class for form input widgets that participate in [FormContainer] theming.
///
/// Subclasses must implement [readonly]. When [readonly] is true, the theme
/// provides distinct background and foreground colors (see [FormThemeData]).
/// Use [FormInputState] as the base for the corresponding [State] so that
/// [resolveThemeColors] can be used in [build] to apply the theme consistently.
///
/// Example for a custom form widget:
/// ```dart
/// class MyFormInput extends FormInputWidget {
///   const MyFormInput({super.key, required this.formFieldKey, this.readonly = false});
///   @override
///   final String formFieldKey;
///   @override
///   final bool readonly;
///   @override
///   State<MyFormInput> createState() => _MyFormInputState();
/// }
///
/// class _MyFormInputState extends FormInputState<MyFormInput> {
///   @override
///   Widget build(BuildContext context) {
///     final colors = resolveThemeColors(context);
///     return InputDecorator(
///       decoration: InputDecoration(filled: true, fillColor: colors.background),
///       child: Text('...', style: TextStyle(color: colors.foreground)),
///     );
///   }
/// }
/// ```
abstract class FormInputWidget extends StatefulWidget {
  const FormInputWidget({super.key});

  /// When true, uses readonly colors from the theme and prevents editing.
  bool get readonly;
}

/// State base for [FormInputWidget] that resolves theme colors from
/// [FormThemeScope] according to [FormInputWidget.readonly].
///
/// Use [resolveThemeColors] in [build] to get background and foreground colors
/// that respect the current theme and readonly state (including [filled] and
/// [fillColor] for [InputDecoration]).
abstract class FormInputState<T extends FormInputWidget> extends State<T> {
  /// Resolves background and foreground colors from the nearest [FormThemeScope]
  /// for the current [readonly] state.
  ///
  /// Use these colors for [InputDecoration.fillColor], [TextStyle.color], etc.,
  /// and set [InputDecoration.filled] to true when using [background] as fill.
  ({Color background, Color foreground}) resolveThemeColors(BuildContext context) {
    final theme = FormThemeScope.of(context);
    final r = widget.readonly;
    return (
      background: r ? theme.readonlyBackground(context) : theme.inputBackground(context),
      foreground: r ? theme.readonlyForeground(context) : theme.inputForeground(context),
    );
  }
}
