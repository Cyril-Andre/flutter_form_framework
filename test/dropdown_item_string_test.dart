import 'package:flutter_form_framework/flutter_form_framework.dart';
import 'package:flutter_test/flutter_test.dart';

enum TestEnum { foo, bar }

class TestItem implements ItemString {
  TestItem(this.label);
  final String label;
  @override
  String get itemString => label;
}

void main() {
  group('DropdownItemString extension', () {
    test('null returns empty string', () {
      expect(null.toItemString(), '');
    });

    test('String returns itself', () {
      expect('hello'.toItemString(), 'hello');
    });

    test('Enum returns name', () {
      expect(TestEnum.foo.toItemString(), 'foo');
      expect(TestEnum.bar.toItemString(), 'bar');
    });

    test('ItemString returns itemString', () {
      expect(TestItem('Custom').toItemString(), 'Custom');
    });

    test('int returns toString', () {
      expect(42.toItemString(), '42');
    });
  });
}
