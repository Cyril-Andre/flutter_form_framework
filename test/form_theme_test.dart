import 'package:flutter/material.dart';
import 'package:flutter_form_framework/flutter_form_framework.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('FormThemeData', () {
    testWidgets('resolve methods return theme colors when custom colors null',
        (tester) async {
      BuildContext? context;
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(useMaterial3: true),
          home: Builder(
            builder: (ctx) {
              context = ctx;
              const theme = FormThemeData();
              return ColoredBox(
                color: theme.formBackground(ctx),
                child: const SizedBox(),
              );
            },
          ),
        ),
      );
      expect(context, isNotNull);
      const theme = FormThemeData();
      expect(theme.formBackground(context!), isNotNull);
      expect(theme.formForeground(context!), isNotNull);
      expect(theme.inputBackground(context!), isNotNull);
      expect(theme.readonlyBackground(context!), isNotNull);
    });

    test('custom colors are returned when set', () {
      const red = Color(0xFFFF0000);
      const theme = FormThemeData(
        formBackgroundColor: red,
        formForegroundColor: red,
      );
      expect(theme.formBackgroundColor, red);
      expect(theme.formForegroundColor, red);
    });

    test('copyWith preserves unspecified values', () {
      const red = Color(0xFFFF0000);
      const theme = FormThemeData(formBackgroundColor: red);
      final next = theme.copyWith(formForegroundColor: red);
      expect(next.formBackgroundColor, red);
      expect(next.formForegroundColor, red);
    });
  });
}
