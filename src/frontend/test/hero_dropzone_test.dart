import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:free_ocr_frontend/widgets/hero_dropzone.dart';

void main() {
  testWidgets('HeroDropzone renders title, drop target, and file picker button',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: HeroDropzone(),
        ),
      ),
    );

    // Verify Title & Subtitle presence
    expect(find.textContaining('Drag & Drop'), findsOneWidget);
    expect(
      find.textContaining('10MB'),
      findsOneWidget,
    );

    // Verify Icons and Select File button
    expect(find.byIcon(Icons.cloud_upload_outlined), findsOneWidget);
    expect(find.textContaining('Select File'), findsOneWidget);

  });
}
