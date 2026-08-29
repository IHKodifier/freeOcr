import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:free_ocr_frontend/widgets/rewarded_video_ad_modal.dart';
import 'package:free_ocr_frontend/utils/limit_evaluator.dart';


void main() {
  group('LimitEvaluator Unit Tests', () {
    test('Correctly identifies file size under limit', () {
      const fileSizeInBytes = 5 * 1024 * 1024; // 5MB
      const currentLimitMb = 10.0;
      final result = LimitEvaluator.evaluate(
        fileSizeInBytes: fileSizeInBytes,
        currentLimitMb: currentLimitMb,
      );
      expect(result.isExceeded, isFalse);
      expect(result.fileSizeMb, closeTo(5.0, 0.01));
    });

    test('Correctly identifies file size exceeding limit', () {
      const fileSizeInBytes = 15 * 1024 * 1024; // 15MB
      const currentLimitMb = 10.0;
      final result = LimitEvaluator.evaluate(
        fileSizeInBytes: fileSizeInBytes,
        currentLimitMb: currentLimitMb,
      );
      expect(result.isExceeded, isTrue);
      expect(result.fileSizeMb, closeTo(15.0, 0.01));
    });
  });

  group('RewardedVideoAdModal Widget Tests', () {
    testWidgets('Renders frosted glass modal with file size and boost options', (WidgetTester tester) async {
      bool watchAdClicked = false;
      bool cancelClicked = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RewardedVideoAdModal(
              filename: 'large_document.pdf',
              fileSizeInBytes: 15 * 1024 * 1024,
              currentLimitMb: 10.0,
              boostPerAdMb: 20.0,
              maxStackMb: 500.0,
              adDurationSeconds: 15,
              onWatchAd: (boostedLimit) {
                watchAdClicked = true;
              },
              onCancel: () {
                cancelClicked = true;
              },
            ),
          ),
        ),
      );

      // Verify Title & Filename
      expect(find.text('File Size Limit Exceeded'), findsOneWidget);
      expect(find.textContaining('large_document.pdf'), findsOneWidget);

      // Verify file size and limit display
      expect(find.textContaining('15.0 MB'), findsOneWidget);
      expect(find.textContaining('10.0 MB'), findsOneWidget);

      // Verify boost pass info (+20 MB per ad up to 500 MB)
      expect(find.textContaining('+20 MB'), findsWidgets);
      expect(find.textContaining('500 MB'), findsOneWidget);


      // Verify Watch Ad button
      final watchAdButton = find.textContaining('Watch 15s Ad to Stack Boost');
      expect(watchAdButton, findsOneWidget);

      // Tap Watch Ad
      await tester.tap(watchAdButton);
      await tester.pump();
      expect(find.textContaining('Rewarded Video Sponsor Ad'), findsOneWidget);
      await tester.pump(const Duration(seconds: 16));
      // Verify Green Success Card & Tap Continue
      final continueButton = find.text('Continue Processing File');
      expect(continueButton, findsOneWidget);
      await tester.ensureVisible(continueButton);
      await tester.tap(continueButton);
      await tester.pump();
      expect(watchAdClicked, isTrue);
    });

    testWidgets('Tapping Cancel invokes onCancel callback', (WidgetTester tester) async {
      bool cancelClicked = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RewardedVideoAdModal(
              filename: 'large_document.pdf',
              fileSizeInBytes: 15 * 1024 * 1024,
              currentLimitMb: 10.0,
              onWatchAd: (boostedLimit) {},
              onCancel: () {
                cancelClicked = true;
              },
            ),
          ),
        ),
      );

      final cancelButton = find.text('Cancel');
      expect(cancelButton, findsOneWidget);
      await tester.tap(cancelButton);
      await tester.pump();
      expect(cancelClicked, isTrue);
    });
  });
}
