import 'package:flutter_form_framework/flutter_form_framework.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('FormFrameState', () {
    test('isDirty is false when initialValues not set', () {
      final state = FormFrameState();
      state.registerField('a', 1);
      expect(state.isDirty, isFalse);
    });

    test('isDirty becomes true when value differs from snapshot', () {
      final state = FormFrameState(initialValues: {'a': 1});
      state.registerField('a', 1);
      expect(state.isDirty, isFalse);
      state.registerField('a', 2);
      expect(state.isDirty, isTrue);
    });

    test('markAsSaved snapshots current values and clears dirty', () {
      final state = FormFrameState(initialValues: {'a': 1});
      state.registerField('a', 2);
      expect(state.isDirty, isTrue);
      state.markAsSaved();
      expect(state.isDirty, isFalse);
      expect(state.initialValues!['a'], 2);
    });

    test('unregisterField removes key and may set dirty', () {
      final state = FormFrameState(initialValues: {'a': 1, 'b': 2});
      state.registerField('a', 1);
      state.registerField('b', 2);
      expect(state.isDirty, isFalse);
      state.unregisterField('a');
      expect(state.currentValues.containsKey('a'), isFalse);
      expect(state.isDirty, isTrue);
    });
  });
}
