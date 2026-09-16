import 'telemetry_helper_stub.dart'
    if (dart.library.html) 'telemetry_helper_web.dart' as helper;

/// Centralized Telemetry & Analytics service for tracking page views and conversion events.
abstract class TelemetryService {
  /// Dispatches GA4 PageView event.
  static void trackPageView(String routeName, {String? pageTitle}) {
    helper.trackGa4PageView(routeName, pageTitle);
  }

  /// Dispatches generic GA4 custom event.
  static void trackEvent(String eventName, [Map<String, dynamic>? parameters]) {
    helper.trackGa4Event(eventName, parameters);
  }

  /// Standard FreePDFToolz Conversion Event: Upload initiated
  static void trackToolUploadStarted({
    required String tool,
    required double fileSizeKb,
  }) {
    final params = {
      'tool': tool,
      'file_size_kb': fileSizeKb,
      'timestamp': DateTime.now().toIso8601String(),
    };
    trackEvent('tool_upload_started', params);
  }

  /// Standard FreePDFToolz Conversion Event: Tool manipulation complete
  static void trackToolProcessCompleted({
    required String tool,
    required int durationMs,
    required int pages,
  }) {
    final params = {
      'tool': tool,
      'duration_ms': durationMs,
      'pages': pages,
      'timestamp': DateTime.now().toIso8601String(),
    };
    trackEvent('tool_process_completed', params);
  }

  /// Standard FreePDFToolz Conversion Event: Download action clicked
  static void trackToolDownloadClicked({
    required String tool,
    required double fileSizeKb,
  }) {
    final params = {
      'tool': tool,
      'file_size_kb': fileSizeKb,
      'timestamp': DateTime.now().toIso8601String(),
    };
    trackEvent('tool_download_clicked', params);
  }

  /// Standard FreePDFToolz Conversion Event: Rewarded video ad completed
  static void trackRewardedAdWatched({
    required String tool,
    required double boostMb,
  }) {
    final params = {
      'tool': tool,
      'boost_mb': boostMb,
      'timestamp': DateTime.now().toIso8601String(),
    };
    trackEvent('rewarded_ad_watched', params);
  }

  /// Track when a user initiates/completes a file upload.
  static void trackDocumentUploaded({
    required String filename,
    required int fileSizeInBytes,
    String? source,
  }) {
    final params = {
      'filename': filename,
      'file_size_bytes': fileSizeInBytes,
      'file_size_mb': (fileSizeInBytes / (1024 * 1024)).toStringAsFixed(2),
      'source': source ?? 'dropzone',
      'timestamp': DateTime.now().toIso8601String(),
    };
    trackEvent('document_uploaded', params);
    trackEvent('upload_start', params);
  }

  /// Track when an OCR conversion job completes successfully.
  static void trackOcrCompleted({
    required String jobId,
    int? pageCount,
    double? durationSeconds,
    String? layoutType,
  }) {
    final params = {
      'job_id': jobId,
      if (pageCount != null) 'page_count': pageCount,
      if (durationSeconds != null) 'duration_seconds': durationSeconds,
      if (layoutType != null) 'layout_type': layoutType,
      'timestamp': DateTime.now().toIso8601String(),
    };
    trackEvent('ocr_completed', params);
    trackEvent('ocr_complete', params);
  }

  /// Track when a user clicks to download a converted file (PDF, TXT, MD).
  static void trackDownloadClicked({
    required String jobId,
    required String format,
    String? filename,
  }) {
    final params = {
      'job_id': jobId,
      'format': format,
      if (filename != null) 'filename': filename,
      'timestamp': DateTime.now().toIso8601String(),
    };
    trackEvent('download_clicked', params);
    trackEvent('download_file', params);
  }

  /// Track when download links are sent to user's email address.
  static void trackEmailSent({
    required String jobId,
    required String recipientDomain,
  }) {
    final params = {
      'job_id': jobId,
      'email_domain': recipientDomain,
      'timestamp': DateTime.now().toIso8601String(),
    };
    trackEvent('email_sent', params);
  }
}
