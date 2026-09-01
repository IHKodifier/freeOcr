import 'package:flutter_test/flutter_test.dart';
import 'package:free_ocr_frontend/services/telemetry_service.dart';

void main() {
  group('TelemetryService Unit Tests', () {
    test('trackPageView dispatches pageview without throwing', () {
      expect(
        () => TelemetryService.trackPageView('/', pageTitle: 'freeOCR.me — Home'),
        returnsNormally,
      );
      expect(
        () => TelemetryService.trackPageView('/result/job_abc123', pageTitle: 'Result'),
        returnsNormally,
      );
    });

    test('trackEvent dispatches generic event without throwing', () {
      expect(
        () => TelemetryService.trackEvent('test_event', {'param_1': 'value_1'}),
        returnsNormally,
      );
    });

    test('trackDocumentUploaded dispatches upload telemetry without throwing', () {
      expect(
        () => TelemetryService.trackDocumentUploaded(
          filename: 'sample_doc.pdf',
          fileSizeInBytes: 2048576,
          source: 'unit_test',
        ),
        returnsNormally,
      );
    });

    test('trackOcrCompleted dispatches OCR complete telemetry without throwing', () {
      expect(
        () => TelemetryService.trackOcrCompleted(
          jobId: 'job_test_456',
          pageCount: 5,
          durationSeconds: 2.5,
          layoutType: 'simple',
        ),
        returnsNormally,
      );
    });

    test('trackDownloadClicked dispatches download telemetry without throwing', () {
      expect(
        () => TelemetryService.trackDownloadClicked(
          jobId: 'job_test_789',
          format: 'pdf',
          filename: 'sample_doc_searchable.pdf',
        ),
        returnsNormally,
      );
    });

    test('trackEmailSent dispatches email telemetry without throwing', () {
      expect(
        () => TelemetryService.trackEmailSent(
          jobId: 'job_test_789',
          recipientDomain: 'example.com',
        ),
        returnsNormally,
      );
    });
  });
}
