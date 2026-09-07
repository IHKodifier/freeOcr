import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:free_ocr_frontend/constants/social_links.dart';
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
    expect(find.byKey(const Key('footer_about_btn')), findsOneWidget);
    expect(find.byKey(const Key('footer_kb_btn')), findsOneWidget);
    expect(find.byKey(const Key('footer_docs_btn')), findsOneWidget);
    expect(find.byKey(const Key('footer_privacy_btn')), findsOneWidget);
    expect(find.byKey(const Key('footer_terms_btn')), findsOneWidget);
    expect(find.byKey(const Key('footer_contact_btn')), findsOneWidget);

    // Verify Live Social Media Handles (Twitter/X, Instagram)
    expect(find.byKey(const Key('footer_social_twitter')), findsOneWidget);
    expect(find.byKey(const Key('footer_social_instagram')), findsOneWidget);

    // FB & YT temporarily hidden until claimed tomorrow morning PKT
    expect(find.byKey(const Key('footer_social_facebook')), findsNothing);
    expect(find.byKey(const Key('footer_social_youtube')), findsNothing);

    // Verify Deprecated Handles are NOT present
    expect(find.byKey(const Key('footer_social_linkedin')), findsNothing);
    expect(find.byKey(const Key('footer_social_discord')), findsNothing);
    expect(find.byKey(const Key('footer_github_repo_link')), findsNothing);

    // Verify Engine Attribution Chips
    expect(find.byKey(const Key('chip_baiduocr')), findsOneWidget);
    expect(find.byKey(const Key('chip_tesseract')), findsOneWidget);
    expect(find.byKey(const Key('chip_ocrmypdf')), findsOneWidget);
    expect(find.byKey(const Key('chip_pymupdf')), findsOneWidget);
  });

  testWidgets('SocialLinks.openSocialChannel triggers high-contrast fallback dialog when URL is unclaimed', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: Builder(
          builder: (context) => ElevatedButton(
            onPressed: () => SocialLinks.openSocialChannel(
              context,
              platformName: 'Facebook',
              url: '',
            ),
            child: const Text('Open'),
          ),
        ),
      ),
    ));
    await tester.pumpAndSettle();

    // Tap button to open fallback dialog
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();

    // Verify high-contrast dialog appears
    expect(find.text('Facebook Channel'), findsOneWidget);
    expect(find.textContaining('presence is launching soon!'), findsOneWidget);
    expect(find.text('Close'), findsOneWidget);
    expect(find.text('Contact Support'), findsOneWidget);

    // Tap Close to dismiss
    await tester.tap(find.text('Close'));
    await tester.pumpAndSettle();

    expect(find.text('Facebook Channel'), findsNothing);
  });
}
