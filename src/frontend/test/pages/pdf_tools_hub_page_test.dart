import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:free_ocr_frontend/pages/pdf_tools_hub_page.dart';
import 'package:free_ocr_frontend/widgets/tool_card.dart';

void main() {
  Widget buildTestHub() {
    return MaterialApp(
      routes: {
        '/merge': (context) => const Scaffold(body: Text('Merge Page')),
        '/split': (context) => const Scaffold(body: Text('Split Page')),
        '/ocr': (context) => const Scaffold(body: Text('OCR Page')),
      },
      home: const PdfToolsHubPage(),
    );
  }

  testWidgets('PdfToolsHubPage renders header, search field, and all 16 tool cards', (tester) async {
    tester.view.physicalSize = const Size(1280, 1000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(buildTestHub());
    await tester.pumpAndSettle();

    // Verify Title / Header
    expect(find.textContaining('PDF Tools Suite'), findsOneWidget);
    expect(find.byType(TextField), findsOneWidget);

    // Verify tool cards count (all 16 tools)
    expect(find.byType(ToolCard), findsNWidgets(16));

    // Verify key tool cards are visible
    expect(find.text('Merge PDF'), findsOneWidget);
    expect(find.text('Split PDF'), findsOneWidget);
    expect(find.text('Compress PDF'), findsOneWidget);
    expect(find.text('OCR PDF'), findsOneWidget);
    expect(find.text('Summarize PDF'), findsOneWidget);
  });

  testWidgets('PdfToolsHubPage filters tools by search query in real time', (tester) async {
    tester.view.physicalSize = const Size(1280, 1000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(buildTestHub());
    await tester.pumpAndSettle();

    final searchField = find.byType(TextField);
    await tester.enterText(searchField, 'Merge');
    await tester.pumpAndSettle();

    // Only Merge card should be visible
    expect(find.text('Merge PDF'), findsOneWidget);
    expect(find.text('Split PDF'), findsNothing);
    expect(find.text('Compress PDF'), findsNothing);
  });

  testWidgets('PdfToolsHubPage filters tools by category chips', (tester) async {
    tester.view.physicalSize = const Size(1280, 1000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(buildTestHub());
    await tester.pumpAndSettle();

    // Tap "Security & Privacy" filter chip
    final securityChip = find.text('Security & Privacy');
    expect(securityChip, findsOneWidget);
    await tester.tap(securityChip);
    await tester.pumpAndSettle();

    // Should find security tools
    expect(find.text('Compress PDF'), findsOneWidget);
    expect(find.text('Redact PDF'), findsOneWidget);
    // Should NOT find Page Ops tools like Split
    expect(find.text('Split PDF'), findsNothing);
  });

  testWidgets('Tapping a ToolCard navigates to corresponding route', (tester) async {
    tester.view.physicalSize = const Size(1280, 1000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(buildTestHub());
    await tester.pumpAndSettle();

    final mergeCard = find.text('Merge PDF');
    expect(mergeCard, findsOneWidget);
    await tester.ensureVisible(mergeCard);
    await tester.pumpAndSettle();
    await tester.tap(mergeCard);
    await tester.pumpAndSettle();

    // Should have navigated to Merge Page
    expect(find.text('Merge Page'), findsOneWidget);
  });
}
