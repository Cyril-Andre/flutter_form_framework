import 'package:flutter/material.dart';
import '../form_state.dart';
import '../form_container.dart';
import '../form_input_widget.dart';

/// A text form field that integrates with [FormContainer] (dirty state,
/// theme, readonly styling).
class FormTextField extends FormInputWidget {
  const FormTextField({
    super.key,
    this.fieldKey,
    required this.formFieldKey,
    this.initialValue,
    this.readonly = false,
    this.decoration,
    this.onChanged,
    this.validator,
    this.onSaved,
    this.keyboardType,
    this.obscureText = false,
    this.maxLines = 1,
    this.autovalidateMode,
  });

  /// Key for the underlying [FormField].
  final Key? fieldKey;

  /// Key used to register this field with [FormFrameState] for dirty tracking.
  final String formFieldKey;

  /// Initial value; also used as snapshot when [FormFrameState.markAsSaved] is called.
  final String? initialValue;

  final InputDecoration? decoration;
  final ValueChanged<String>? onChanged;
  final FormFieldValidator<String>? validator;
  final FormFieldSetter<String>? onSaved;
  final TextInputType? keyboardType;
  final bool obscureText;
  final int? maxLines;
  final AutovalidateMode? autovalidateMode;

  @override
  State<FormTextField> createState() => _FormTextFieldState();

  /// When true, uses readonly colors and prevents editing.
  @override
  final bool readonly;
}

class _FormTextFieldState extends FormInputState<FormTextField> {
  late TextEditingController _controller;
  FormFrameState? _formState;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _formState = FormFrameScope.of(context);
    _registerValue(_controller.text);
  }

  @override
  void didUpdateWidget(FormTextField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialValue != widget.initialValue &&
        _controller.text != widget.initialValue) {
      _controller.text = widget.initialValue ?? '';
      _registerValue(widget.initialValue ?? '');
    }
  }

  void _registerValue(String value) {
    FormFrameScope.of(context)?.registerField(widget.formFieldKey, value);
  }

  @override
  void dispose() {
    _formState?.unregisterField(widget.formFieldKey);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = resolveThemeColors(context);

    return FormField<String>(
      key: widget.fieldKey,
      initialValue: widget.initialValue,
      validator: widget.validator,
      onSaved: widget.onSaved,
      autovalidateMode: widget.autovalidateMode,
      builder: (FormFieldState<String> state) {
        return InputDecorator(
          decoration: (widget.decoration ?? const InputDecoration())
              .copyWith(
                filled: true,
                fillColor: colors.background,
                errorText: state.errorText,
                labelStyle: TextStyle(color: colors.foreground),
                hintStyle: TextStyle(color: colors.foreground.withValues(alpha: 0.6)),
              ),
          child: TextField(
            controller: _controller,
            readOnly: widget.readonly,
            onChanged: (value) {
              state.didChange(value);
              _registerValue(value);
              widget.onChanged?.call(value);
            },
            keyboardType: widget.keyboardType,
            obscureText: widget.obscureText,
            maxLines: widget.maxLines,
            style: TextStyle(color: colors.foreground),
            decoration: const InputDecoration.collapsed(hintText: ''),
          ),
        );
      },
    );
  }
}
