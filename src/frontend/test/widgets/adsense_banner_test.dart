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
    expect(find.textContaining('Stage Rotation'), findsOneWidget);
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
  });
}
