import 'package:flutter/material.dart';
import 'form_theme.dart';
import 'form_state.dart';

/// Provides [FormThemeData] to descendant form widgets.
class FormThemeScope extends InheritedWidget {
  const FormThemeScope({
    super.key,
    required this.theme,
    required super.child,
  });

  final FormThemeData theme;

  static FormThemeData of(BuildContext context) {
    final scope =
        context.dependOnInheritedWidgetOfExactType<FormThemeScope>();
    return scope?.theme ?? const FormThemeData();
  }

  @override
  bool updateShouldNotify(FormThemeScope oldWidget) =>
      oldWidget.theme != theme;
}

/// Border style for the form container.
enum FormContainerBorder {
  /// No border.
  none,

  /// Square (zero radius) border.
  square,

  /// Rounded border using theme shape.
  rounded,
}

/// A configurable form container that respects Material 3 and optional
/// [FormThemeData], and provides dirty state via [FormFrameScope].
class FormContainer extends StatefulWidget {
  const FormContainer({
    super.key,
    this.border = FormContainerBorder.rounded,
    this.theme,
    this.initialValues,
    this.padding,
    this.child,
  });

  final FormContainerBorder border;
  final FormThemeData? theme;
  final Map<String, dynamic>? initialValues;
  final EdgeInsetsGeometry? padding;
  final Widget? child;

  @override
  State<FormContainer> createState() => _FormContainerState();
}

class _FormContainerState extends State<FormContainer> {
  late FormFrameState _frameState;

  @override
  void initState() {
    super.initState();
    _frameState = FormFrameState(initialValues: widget.initialValues);
  }

  @override
  void didUpdateWidget(FormContainer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialValues != oldWidget.initialValues) {
      _frameState.setInitialValues(widget.initialValues);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = widget.theme ?? const FormThemeData();
    final backgroundColor = theme.formBackground(context);
    final foregroundColor = theme.formForeground(context);

    BoxDecoration decoration;
    switch (widget.border) {
      case FormContainerBorder.none:
        decoration = BoxDecoration(color: backgroundColor);
        break;
      case FormContainerBorder.square:
        decoration = BoxDecoration(
          color: backgroundColor,
          border: Border.all(
            color: foregroundColor.withValues(alpha: 0.38),
            width: 1,
          ),
        );
        break;
      case FormContainerBorder.rounded:
        decoration = BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: foregroundColor.withValues(alpha: 0.38),
            width: 1,
          ),
        );
        break;
    }

    return FormFrameScope(
      state: _frameState,
      child: FormThemeScope(
        theme: theme,
        child: Container(
          padding: widget.padding ?? const EdgeInsets.all(16),
          decoration: decoration,
          child: DefaultTextStyle(
            style: TextStyle(color: foregroundColor),
            child: widget.child ?? const SizedBox.shrink(),
          ),
        ),
      ),
    );
  }
}
