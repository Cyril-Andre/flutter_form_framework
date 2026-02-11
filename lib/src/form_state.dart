import 'package:flutter/material.dart';

/// Scope that provides [FormFrameState] to descendants.
class FormFrameScope extends InheritedWidget {
  const FormFrameScope({
    super.key,
    required this.state,
    required super.child,
  });

  final FormFrameState state;

  static FormFrameState? of(BuildContext context) {
    final scope =
        context.dependOnInheritedWidgetOfExactType<FormFrameScope>();
    return scope?.state;
  }

  @override
  bool updateShouldNotify(FormFrameScope oldWidget) =>
      oldWidget.state != state;
}

/// State for dirty tracking and form snapshot.
///
/// Register each field with [registerField] / [unregisterField].
/// [isDirty] is true when current values differ from the last snapshot.
/// Call [markAsSaved] to snapshot current values and clear dirty.
///
/// When [initialValues] is not provided to the constructor, the snapshot
/// is built from the first value each field registers (widget initial values).
/// When [initialValues] is provided, it defines the snapshot and [registerField]
/// never updates it (only [markAsSaved] or [setInitialValues] do).
class FormFrameState extends ChangeNotifier {
  FormFrameState({Map<String, dynamic>? initialValues})
      : _initialValuesFromParent = initialValues != null,
        _initialValues = initialValues != null
            ? Map<String, dynamic>.from(initialValues)
            : null;

  Map<String, dynamic>? _initialValues;
  final Map<String, dynamic> _currentValues = {};
  bool _initialValuesFromParent;

  /// Whether any registered field value differs from the last snapshot.
  bool get isDirty {
    if (_initialValues == null) return false;
    if (_currentValues.length != _initialValues!.length) return true;
    for (final e in _currentValues.entries) {
      final initial = _initialValues![e.key];
      if (_valueEquals(initial, e.value)) continue;
      return true;
    }
    return false;
  }

  bool _valueEquals(dynamic a, dynamic b) {
    if (identical(a, b)) return true;
    if (a == b) return true;
    if (a is List && b is List) {
      if (a.length != b.length) return false;
      for (var i = 0; i < a.length; i++) {
        if (!_valueEquals(a[i], b[i])) return false;
      }
      return true;
    }
    if (a is Map && b is Map) {
      if (a.length != b.length) return false;
      for (final k in a.keys) {
        if (!b.containsKey(k) || !_valueEquals(a[k], b[k])) return false;
      }
      return true;
    }
    return false;
  }

  /// Snapshot current values and set dirty to false.
  void markAsSaved() {
    _initialValues = Map<String, dynamic>.from(_currentValues);
    _initialValuesFromParent = false;
    notifyListeners();
  }

  /// Set the snapshot to [values]. When [FormContainer.initialValues] changes,
  /// this is called so [isDirty] is computed against the new baseline.
  /// Pass [null] to clear the snapshot (form will not be dirty until [markAsSaved]).
  void setInitialValues(Map<String, dynamic>? values) {
    _initialValues =
        values != null ? Map<String, dynamic>.from(values) : null;
    _initialValuesFromParent = values != null;
    notifyListeners();
  }

  /// Current values (read-only view).
  Map<String, dynamic> get currentValues =>
      Map.unmodifiable(_currentValues);

  /// Last saved snapshot, or null if never saved.
  Map<String, dynamic>? get initialValues =>
      _initialValues == null ? null : Map.unmodifiable(_initialValues!);

  void registerField(String key, dynamic value) {
    _initialValues ??= {};
    if (!_initialValuesFromParent && !_initialValues!.containsKey(key)) {
      _initialValues![key] = value;
    }
    final prev = _currentValues[key];
    _currentValues[key] = value;
    if (!_valueEquals(prev, value)) notifyListeners();
  }

  void unregisterField(String key) {
    if (_currentValues.remove(key) != null) notifyListeners();
  }
}
