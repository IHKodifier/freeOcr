import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:free_ocr_frontend/main.dart';

void main() {
  testWidgets('App renders headline and uses Material 3 theme', (WidgetTester tester) async {
    await tester.pumpWidget(const FreeOcrApp());

    expect(find.text('freeOCR.me'), findsOneWidget);
    expect(find.text('Scanned PDF to Searchable PDF/Text'), findsOneWidget);
    expect(find.text('100% Free & Privacy Ephemeral'), findsOneWidget);

    final MaterialApp app = tester.widget(find.byType(MaterialApp));
    expect(app.theme?.useMaterial3, isTrue);
    expect(app.darkTheme?.useMaterial3, isTrue);
  });
}
