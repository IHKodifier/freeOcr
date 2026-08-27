import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:free_ocr_frontend/widgets/adsense_banner.dart';

void main() {
  setUp(() {
    AdSenseBanner.resetSessionCount();
  });

  testWidgets('AdSenseBanner renders banner layout correctly', (WidgetTester tester) async {

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: AdSenseBanner(
            overrideRotationSeconds: 5,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Verify banner container and sponsored text exists
    expect(find.byKey(const Key('adsense_banner_container')), findsOneWidget);
    expect(find.text('Sponsored Advertisement'), findsOneWidget);
    expect(find.textContaining('Auto-rotating (5s)'), findsOneWidget);
  });

  testWidgets('AdSenseBanner timer pauses on tab blur and resumes on focus', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: AdSenseBanner(
            overrideRotationSeconds: 2,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final AdSenseBannerState state = tester.state(find.byType(AdSenseBanner));

    expect(state.isPaused, isFalse);
    expect(state.rotationIntervalSeconds, equals(2));

    // Simulate tab blur / lifecycle paused event
    state.didChangeAppLifecycleState(AppLifecycleState.paused);
    await tester.pump();

    expect(state.isPaused, isTrue);
    expect(find.textContaining('Paused'), findsOneWidget);


    // Fast-forward time past 4 seconds while paused - adRefreshCount should NOT increment
    await tester.pump(const Duration(seconds: 4));
    expect(state.adRefreshCount, equals(0));

    // Simulate window resume / lifecycle resumed event
    state.didChangeAppLifecycleState(AppLifecycleState.resumed);
    await tester.pump();

    expect(state.isPaused, isFalse);
    expect(find.textContaining('Auto-rotating (2s)'), findsOneWidget);

    // Fast-forward time by 2 seconds - adRefreshCount should increment by 1
    await tester.pump(const Duration(seconds: 2));
    expect(state.adRefreshCount, equals(1));
  });

  testWidgets('AdSenseBanner.rotateAd() triggers immediate rotation on conversion stage change', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: AdSenseBanner(
            overrideRotationSeconds: 30,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final AdSenseBannerState state = tester.state(find.byType(AdSenseBanner));
    expect(state.adRefreshCount, equals(0));

    // Trigger explicit rotation on drop/stage change
    AdSenseBanner.rotateAd();
    await tester.pump();

    expect(state.adRefreshCount, equals(1));

    // Trigger second stage rotation (e.g. processing started)
    AdSenseBanner.rotateAd();
    await tester.pump();

    expect(state.adRefreshCount, equals(2));

    // Verify that the periodic autorotation timer continues running after explicit triggers
    await tester.pump(const Duration(seconds: 30));
    expect(state.adRefreshCount, equals(3));
  });
}

