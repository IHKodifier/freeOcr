import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:free_ocr_frontend/widgets/hero_dropzone.dart';
import 'package:free_ocr_frontend/utils/app_limits_config.dart';
import 'package:free_ocr_frontend/widgets/rewarded_video_ad_modal.dart';

void main() {
  setUp(() {
    AppLimitsConfig.resetBoost();
    RewardedVideoAdModal.debugOverrideAdPlayback = true;
  });

  tearDown(() {
    AppLimitsConfig.resetBoost();
    RewardedVideoAdModal.debugOverrideAdPlayback = null;
  });

  testWidgets('HeroDropzone renders title, drop target, and file picker button',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: HeroDropzone(),
        ),
      ),
    );

    // Verify Title presence
    expect(find.textContaining('Drag & Drop'), findsOneWidget);

    // Verify Icons and Select File button
    expect(find.byIcon(Icons.cloud_upload_rounded), findsOneWidget);
    expect(find.textContaining('Select PDF or Images'), findsOneWidget);

    // Verify free tier limit and boost action
    expect(find.textContaining('Up to 100 MB free per PDF'), findsOneWidget);
    expect(find.textContaining('Boost up to 1 GB with Ads'), findsOneWidget);
  });

  testWidgets('Tapping boost action in dropzone opens RewardedVideoAdModal',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: HeroDropzone(),
        ),
      ),
    );

    final boostButton = find.textContaining('Boost up to 1 GB with Ads');
    expect(boostButton, findsOneWidget);

    await tester.tap(boostButton);
    await tester.pump();

    // Verify Rewarded Video modal opens
    expect(find.byType(RewardedVideoAdModal), findsOneWidget);
    expect(find.textContaining('Load Sponsor Ad'), findsOneWidget);
  });

  testWidgets('When boost is active, dropzone renders boosted limit badge and countdown timer',
      (WidgetTester tester) async {
    AppLimitsConfig.recordBoost(150.0);

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: HeroDropzone(),
        ),
      ),
    );

    // Verify boosted badge
    expect(find.textContaining('Up to 150 MB free per PDF (Boosted)'), findsOneWidget);
    expect(find.textContaining('+ Boost More (+50 MB)'), findsOneWidget);

    // Verify active session countdown timer ticker
    expect(find.textContaining('Session Boost Active:'), findsOneWidget);
    expect(find.textContaining('remaining'), findsOneWidget);
  });
}
