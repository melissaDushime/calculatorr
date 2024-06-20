import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart'; // Import the provider package

import 'package:calculator/main.dart';

void main() {
  testWidgets('Calculator smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => ThemeProvider(),
        child: CalculatorApp(),
      ),
    );

    // Verify that our initial display value is 0.
    expect(find.text('0'), findsOneWidget);
    expect(find.text('1'), findsNothing);

    // Tap the '1' button and trigger a frame.
    await tester.tap(find.text('1'));
    await tester.pump();

    // Verify that our display now shows 1.
    expect(find.text('0'), findsNothing);
    expect(find.text('1'), findsOneWidget);

    // Tap the 'C' button and trigger a frame.
    await tester.tap(find.text('C'));
    await tester.pump();

    // Verify that our display is cleared and shows 0.
    expect(find.text('0'), findsOneWidget);
    expect(find.text('1'), findsNothing);
  });
}
