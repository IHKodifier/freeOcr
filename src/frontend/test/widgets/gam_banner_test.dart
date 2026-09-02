import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:free_ocr_frontend/widgets/gam_banner.dart';

void main() {
  setUp(() {
    GamBannerWidget.resetSessionCount();
  });

  group('GamBannerWidget Unit & Widget Tests', () {
    testWidgets('Renders GAM / AdX badge, slot container info, and refresh timer', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: GamBannerWidget(
              autoRefreshSeconds: 31,
            ),
          ),
        ),
      );

      // Verify GAM / AdX badge
      expect(find.text('GAM / AdX'), findsOneWidget);

      // Verify slot name
      expect(find.textContaining('/1234567/freeocr_leaderboard_728x90'), findsOneWidget);

      // Verify declared refresh badge
      expect(find.textContaining('Declared 31s Refresh'), findsOneWidget);

      // Verify initial 31s countdown ticker
      expect(find.text('31s'), findsOneWidget);
    });

    testWidgets('GamBannerWidget.refreshGamSlot() increments refresh counter and updates UI', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: GamBannerWidget(
              autoRefreshSeconds: 31,
            ),
          ),
        ),
      );

      expect(find.textContaining('#0'), findsWidgets);

      // Trigger static refresh method
      GamBannerWidget.refreshGamSlot();
      await tester.pump();

      // Verify counter incremented to #1
      expect(find.textContaining('#1'), findsWidgets);
    });

    testWidgets('Auto-refresh timer counts down and triggers slot refresh after 31 seconds', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: GamBannerWidget(
              autoRefreshSeconds: 5, // Shortened for quick test simulation
            ),
          ),
        ),
      );

      expect(find.textContaining('5s'), findsOneWidget);

      // Advance timer by 2 seconds
      await tester.pump(const Duration(seconds: 2));
      expect(find.textContaining('3s'), findsOneWidget);

      // Advance timer past 5 seconds
      await tester.pump(const Duration(seconds: 4));
      expect(find.textContaining('#1'), findsWidgets);
    });

    testWidgets('Tapping refresh IconButton triggers explicit GAM slot refresh', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: GamBannerWidget(),
          ),
        ),
      );

      final refreshBtn = find.byIcon(Icons.refresh_rounded);
      expect(refreshBtn, findsOneWidget);

      await tester.tap(refreshBtn);
      await tester.pump();

      expect(find.textContaining('#1'), findsWidgets);
    });
  });
}
