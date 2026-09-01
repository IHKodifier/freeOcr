import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:free_ocr_frontend/widgets/app_footer.dart';

void main() {
  Widget buildTestWidget(Widget child) {
    return MaterialApp(
      home: Scaffold(
        body: SingleChildScrollView(child: child),
      ),
    );
  }

  testWidgets('AppFooter renders brand, social media handles, legal links, and engine chips', (WidgetTester tester) async {
    await tester.pumpWidget(buildTestWidget(const AppFooter()));
    await tester.pumpAndSettle();

    // Verify Brand title & Privacy commitment text
    expect(find.text('freeOCR.me'), findsOneWidget);
    expect(find.textContaining('RAM disk'), findsOneWidget);

    // Verify Navigation Buttons
    expect(find.byKey(const Key('footer_home_btn')), findsOneWidget);
    expect(find.byKey(const Key('footer_kb_btn')), findsOneWidget);
    expect(find.byKey(const Key('footer_docs_btn')), findsOneWidget);
    expect(find.byKey(const Key('footer_privacy_btn')), findsOneWidget);
    expect(find.byKey(const Key('footer_terms_btn')), findsOneWidget);

    // Verify Social Media Handles
    expect(find.byKey(const Key('footer_social_twitter')), findsOneWidget);
    expect(find.byKey(const Key('footer_social_linkedin')), findsOneWidget);
    expect(find.byKey(const Key('footer_social_discord')), findsOneWidget);

    // Verify Repository link is NOT present
    expect(find.byKey(const Key('footer_github_repo_link')), findsNothing);

    // Verify Engine Attribution Chips
    expect(find.byKey(const Key('chip_baiduocr')), findsOneWidget);
    expect(find.byKey(const Key('chip_tesseract')), findsOneWidget);
    expect(find.byKey(const Key('chip_ocrmypdf')), findsOneWidget);
    expect(find.byKey(const Key('chip_pymupdf')), findsOneWidget);
  });
}
