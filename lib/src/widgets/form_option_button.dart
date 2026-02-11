import 'package:flutter/material.dart';
import '../form_state.dart';
import '../form_container.dart';
import '../form_input_widget.dart';

/// A radio / option form field that integrates with [FormContainer] (dirty state,
/// theme, readonly styling).
class FormOptionButton<T> extends FormInputWidget {
  const FormOptionButton({
    super.key,
    this.fieldKey,
    required this.formFieldKey,
    required this.value,
    this.groupValue,
    this.initialValue,
    this.readonly = false,
    this.label,
    this.onChanged,
    this.validator,
    this.onSaved,
  });

  final Key? fieldKey;
  final String formFieldKey;
  final T value;
  final T? groupValue;
  final T? initialValue;
  @override
  final bool readonly;
  final Widget? label;
  final ValueChanged<T?>? onChanged;
  final FormFieldValidator<T?>? validator;
  final FormFieldSetter<T?>? onSaved;

  @override
  State<FormOptionButton<T>> createState() => _FormOptionButtonState<T>();
}

class _FormOptionButtonState<T> extends FormInputState<FormOptionButton<T>> {
  FormFrameState? _formState;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _formState = FormFrameScope.of(context);
    _registerValue(widget.groupValue ?? widget.initialValue);
  }

  @override
  void didUpdateWidget(FormOptionButton<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    _registerValue(widget.groupValue ?? widget.initialValue);
  }

  void _registerValue(T? value) {
    FormFrameScope.of(context)?.registerField(widget.formFieldKey, value);
  }

  @override
  void dispose() {
    _formState?.unregisterField(widget.formFieldKey);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = resolveThemeColors(context);
    final groupValue = widget.groupValue ?? widget.initialValue;

    return FormField<T?>(
      key: widget.fieldKey,
      initialValue: widget.initialValue,
      validator: widget.validator,
      onSaved: widget.onSaved,
      builder: (FormFieldState<T?> state) {
        return InputDecorator(
          decoration: InputDecoration(
            errorText: state.errorText,
            border: InputBorder.none,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Radio<T>(
                value: widget.value,
                groupValue: groupValue,
                onChanged: widget.readonly
                    ? null
                    : (v) {
                        state.didChange(v);
                        _registerValue(v);
                        widget.onChanged?.call(v);
                      },
                fillColor: WidgetStateProperty.resolveWith((states) {
                  if (states.contains(WidgetState.disabled)) {
                    return FormThemeScope.of(context).readonlyForeground(context);
                  }
                  return colors.foreground;
                }),
              ),
              if (widget.label != null) ...[
                const SizedBox(width: 8),
                DefaultTextStyle(
                  style: TextStyle(color: colors.foreground),
                  child: widget.label!,
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}
