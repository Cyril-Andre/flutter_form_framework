// Basic Flutter widget test for the flutter_form_framework example app.

import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_form_framework_example/main.dart';

void main() {
  testWidgets('Example app loads and shows form', (WidgetTester tester) async {
    await tester.pumpWidget(const ExampleApp());

    expect(find.text('Form Framework Example'), findsOneWidget);
    expect(find.text('Name'), findsOneWidget);
    expect(find.text('No changes'), findsOneWidget);
  });
}
