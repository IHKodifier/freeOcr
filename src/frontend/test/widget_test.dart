import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:free_ocr_frontend/main.dart';

void main() {
  testWidgets('App renders headline and uses Material 3 theme', (WidgetTester tester) async {
    await tester.pumpWidget(const FreeOcrApp());

    expect(find.text('freeOCR.me'), findsAtLeast(1));
    expect(find.byWidgetPredicate((w) => w is RichText && w.text.toPlainText().contains('Extract Text with')), findsOneWidget);
    expect(find.textContaining('100% Free • Zero File Retention'), findsAtLeast(1));

    final MaterialApp app = tester.widget(find.byType(MaterialApp));
    expect(app.theme?.useMaterial3, isTrue);
    expect(app.darkTheme?.useMaterial3, isTrue);
  });
}
