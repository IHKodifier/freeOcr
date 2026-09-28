// src/frontend/test/pages/kb_navigation_and_telemetry_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:free_ocr_frontend/data/kb_articles_data.dart';
import 'package:free_ocr_frontend/main.dart';
import 'package:free_ocr_frontend/pages/kb_page.dart';

void main() {
  group('Knowledge Base Identical Navigation & Catalog Tests', () {
    testWidgets('KbPage renders all 4 pillars and Directory title matching static HTML', (WidgetTester tester) async {
      await tester.pumpWidget(const FreeOcrApp());
      await tester.pumpAndSettle();

      final BuildContext context = tester.element(find.byType(HomePage));
      Navigator.pushNamed(context, '/kb');
      await tester.pumpAndSettle();

      expect(find.byType(KbPage), findsOneWidget);
      expect(find.text('Knowledge Base Directory'), findsOneWidget);
      expect(find.textContaining('Tool Guides & Workflows'), findsAtLeast(1));
      expect(find.textContaining('Format & Tech Comparisons'), findsAtLeast(1));
      expect(find.textContaining('Use-Case Solutions'), findsAtLeast(1));
      expect(find.textContaining('Troubleshooting & FAQs'), findsAtLeast(1));
      expect(find.text('Security Assurance'), findsAtLeast(1));
    });

    testWidgets('KbPage contains all 23 articles in the navigation tree', (WidgetTester tester) async {
      await tester.pumpWidget(const FreeOcrApp());
      await tester.pumpAndSettle();

      final BuildContext context = tester.element(find.byType(HomePage));
      Navigator.pushNamed(context, '/kb');
      await tester.pumpAndSettle();

      expect(kbArticles.length, 23);
      for (final article in kbArticles) {
        expect(
          find.text(article.navTitle, skipOffstage: false),
          findsAtLeast(1),
          reason: 'Expected article ${article.slug} (${article.navTitle}) to be in the navigation directory',
        );
      }
    });

    testWidgets('Deep link to /kb/optimal-dpi-settings renders target article and breadcrumbs', (WidgetTester tester) async {
      await tester.pumpWidget(const FreeOcrApp());
      await tester.pumpAndSettle();

      final BuildContext context = tester.element(find.byType(HomePage));
      Navigator.pushNamed(context, '/kb/optimal-dpi-settings');
      await tester.pumpAndSettle();

      expect(find.textContaining('Optimal DPI Settings'), findsAtLeast(1));
      expect(find.textContaining('Tool Guides & Workflows'), findsAtLeast(1));
    });

    testWidgets('Deep link to /kb/privacy-security renders Zero-Disk Retention article', (WidgetTester tester) async {
      await tester.pumpWidget(const FreeOcrApp());
      await tester.pumpAndSettle();

      final BuildContext context = tester.element(find.byType(HomePage));
      Navigator.pushNamed(context, '/kb/privacy-security');
      await tester.pumpAndSettle();

      expect(find.textContaining('Zero-Disk Retention Architecture'), findsAtLeast(1));
      expect(find.textContaining('Use-Case Solutions'), findsAtLeast(1));
    });

    testWidgets('Deep link to /kb/scan-restoration renders Scan Restoration article', (WidgetTester tester) async {
      await tester.pumpWidget(const FreeOcrApp());
      await tester.pumpAndSettle();

      final BuildContext context = tester.element(find.byType(HomePage));
      Navigator.pushNamed(context, '/kb/scan-restoration');
      await tester.pumpAndSettle();

      expect(find.textContaining('Scan Restoration & Preprocessing'), findsAtLeast(1));
      expect(find.textContaining('Troubleshooting & FAQs'), findsAtLeast(1));
    });

    testWidgets('Clicking an article item switches active article in view', (WidgetTester tester) async {
      await tester.pumpWidget(const FreeOcrApp());
      await tester.pumpAndSettle();

      final BuildContext context = tester.element(find.byType(HomePage));
      Navigator.pushNamed(context, '/kb');
      await tester.pumpAndSettle();

      // Initially OCR Guide is active
      expect(find.textContaining('Understanding OCR: The Complete Guide'), findsOneWidget);

      // Find and tap "Optimal DPI Settings"
      final dpiNavItem = find.text('Optimal DPI Settings for Scanned Documents', skipOffstage: false);
      expect(dpiNavItem, findsOneWidget);

      await tester.ensureVisible(dpiNavItem);
      await tester.tap(dpiNavItem);
      await tester.pumpAndSettle();

      // Now Optimal DPI Settings is active
      expect(find.textContaining('Optimal DPI Settings for Scanned Documents: Speed vs Accuracy'), findsOneWidget);
    });
  });
}
