import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:free_ocr_frontend/widgets/ocr_progress_view.dart';

void main() {
  testWidgets('OcrProgressView renders progress indicator, page count, and status',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: OcrProgressView(
            currentPage: 3,
            totalPages: 8,
            status: 'PROCESSING',
          ),
        ),
      ),
    );

    // Verify status and page text
    expect(find.text('Processing Document...'), findsOneWidget);
    expect(find.textContaining('Page 3 of 8'), findsOneWidget);
    expect(find.byType(LinearProgressIndicator), findsOneWidget);
  });

  testWidgets('OcrProgressView renders completed status when finished',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: OcrProgressView(
            currentPage: 8,
            totalPages: 8,
            status: 'COMPLETED',
          ),
        ),
      ),
    );

    expect(find.text('Conversion Complete!'), findsOneWidget);
    expect(find.byIcon(Icons.check_circle_outline), findsOneWidget);
  });
}
