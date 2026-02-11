import 'package:flutter/material.dart';
import '../form_state.dart';
import '../form_container.dart';
import '../form_input_widget.dart';

/// A checkbox form field that integrates with [FormContainer] (dirty state,
/// theme, readonly styling).
class FormCheckbox extends FormInputWidget {
  const FormCheckbox({
    super.key,
    this.fieldKey,
    required this.formFieldKey,
    this.initialValue = false,
    this.readonly = false,
    this.label,
    this.tristate = false,
    this.onChanged,
    this.validator,
    this.onSaved,
  });

  final Key? fieldKey;
  final String formFieldKey;
  final bool? initialValue;
  @override
  final bool readonly;
  final Widget? label;
  final bool tristate;
  final ValueChanged<bool?>? onChanged;
  final FormFieldValidator<bool?>? validator;
  final FormFieldSetter<bool?>? onSaved;

  @override
  State<FormCheckbox> createState() => _FormCheckboxState();
}

class _FormCheckboxState extends FormInputState<FormCheckbox> {
  late bool? _value;
  FormFrameState? _formState;

  @override
  void initState() {
    super.initState();
    _value = widget.initialValue;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _formState = FormFrameScope.of(context);
    _registerValue(_value);
  }

  @override
  void didUpdateWidget(FormCheckbox oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialValue != widget.initialValue) {
      _value = widget.initialValue;
      _registerValue(_value);
    }
  }

  void _registerValue(bool? value) {
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

    return FormField<bool?>(
      key: widget.fieldKey,
      initialValue: widget.initialValue,
      validator: widget.validator,
      onSaved: widget.onSaved,
      builder: (FormFieldState<bool?> state) {
        return InputDecorator(
          decoration: InputDecoration(
            errorText: state.errorText,
            border: InputBorder.none,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Checkbox(
                value: _value,
                onChanged: widget.readonly
                    ? null
                    : (v) {
                        setState(() => _value = v);
                        state.didChange(v);
                        _registerValue(v);
                        widget.onChanged?.call(v);
                      },
                fillColor: WidgetStateProperty.resolveWith((states) {
                  if (states.contains(WidgetState.disabled)) {
                    return FormThemeScope.of(context).readonlyBackground(context);
                  }
                  return colors.background;
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
