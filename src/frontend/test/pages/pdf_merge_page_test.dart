import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:free_ocr_frontend/pages/pdf_merge_page.dart';

void main() {
  testWidgets('PdfMergePage renders dropzone and header initially', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1280, 1000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      const MaterialApp(
        home: PdfMergePage(),
      ),
    );
    await tester.pumpAndSettle();

    // Verify Title & Subtitle
    expect(find.text('Merge PDF Files'), findsOneWidget);
    expect(find.textContaining('Combine multiple PDFs into a single document'), findsOneWidget);

    // Verify Dropzone prompt
    expect(find.textContaining('Drop PDF files here'), findsOneWidget);
    expect(find.text('Select PDF Files'), findsOneWidget);

    // Verify initial button state (disabled when 0 files)
    final mergeButtonFinder = find.widgetWithText(ElevatedButton, 'Merge PDFs');
    expect(mergeButtonFinder, findsOneWidget);
    final ElevatedButton mergeButton = tester.widget(mergeButtonFinder);
    expect(mergeButton.onPressed, isNull);
  });

  testWidgets('PdfMergePage renders added files in reorderable list', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1280, 1000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      MaterialApp(
        home: PdfMergePage(
          initialFiles: const [
            SelectedPdfFile(name: 'DocA.pdf', sizeBytes: 1024 * 1024),
            SelectedPdfFile(name: 'DocB.pdf', sizeBytes: 2 * 1024 * 1024),
          ],
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Verify file names render
    expect(find.text('DocA.pdf'), findsOneWidget);
    expect(find.text('DocB.pdf'), findsOneWidget);

    // Verify file count & total size badge
    expect(find.textContaining('2 files selected'), findsOneWidget);

    // Verify merge button is enabled when >= 2 files
    final mergeButtonFinder = find.widgetWithText(ElevatedButton, 'Merge PDFs (2)');
    expect(mergeButtonFinder, findsOneWidget);
    final ElevatedButton mergeButton = tester.widget(mergeButtonFinder);
    expect(mergeButton.onPressed, isNotNull);

    // Verify delete button is present for each file
    expect(find.byIcon(Icons.close), findsNWidgets(2));
  });
}
