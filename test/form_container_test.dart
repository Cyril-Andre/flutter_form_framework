import 'package:flutter/material.dart';
import 'package:flutter_form_framework/flutter_form_framework.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('FormContainer', () {
    testWidgets('renders child and provides FormFrameScope', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(useMaterial3: true),
          home: FormContainer(
            border: FormContainerBorder.none,
            child: Builder(
              builder: (context) {
                final state = FormFrameScope.of(context);
                return Text(state != null ? 'hasState' : 'noState');
              },
            ),
          ),
        ),
      );
      expect(find.text('hasState'), findsOneWidget);
    });

    testWidgets('FormThemeScope provides theme to descendants', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(useMaterial3: true),
          home: FormContainer(
            theme: const FormThemeData(
              formBackgroundColor: Color(0xFF0000FF),
            ),
            child: const SizedBox(),
          ),
        ),
      );
      expect(find.byType(FormContainer), findsOneWidget);
    });
  });
}
