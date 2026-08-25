import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:free_ocr_frontend/main.dart';

void main() {
  testWidgets('AppBar contains Theme Toggle button and toggles theme mode',
      (WidgetTester tester) async {
    await tester.pumpWidget(const FreeOcrApp());
    await tester.pumpAndSettle();

    // Verify Theme Toggle IconButton exists in AppBar
    final toggleFinder = find.byTooltip('Switch to Dark Theme');
    expect(toggleFinder, findsOneWidget);

    // Tap theme toggle button
    await tester.tap(toggleFinder);
    await tester.pumpAndSettle();

    // Verify tooltip updated to Light Theme
    expect(find.byTooltip('Switch to Light Theme'), findsOneWidget);

    // Tap theme toggle button again to switch back
    await tester.tap(find.byTooltip('Switch to Light Theme'));
    await tester.pumpAndSettle();

    expect(find.byTooltip('Switch to Dark Theme'), findsOneWidget);
  });
}
