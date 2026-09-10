// ignore: avoid_web_libraries_in_flutter
import 'dart:async';
import 'dart:convert';
import 'dart:html' as html;
import 'dart:typed_data';

/// Native browser XMLHttpRequest uploader that tracks real network socket upload bytes
/// and throttles UI notifications to ~600ms for smooth, realistic progress updates.
Future<Map<String, dynamic>> uploadWithRealSocketProgress({
  required String url,
  required String filename,
  required Uint8List bytes,
  Map<String, String>? headers,
  String? password,
  Function(int sentBytes, int totalBytes)? onProgress,
  Function()? onAnalyzing,
}) {
  final completer = Completer<Map<String, dynamic>>();
  final xhr = html.HttpRequest();

  xhr.open('POST', url);

  if (headers != null) {
    headers.forEach((key, value) {
      xhr.setRequestHeader(key, value);
    });
  }

  final formData = html.FormData();
  final blob = html.Blob([bytes]);
  formData.appendBlob('file', blob, filename);
  if (password != null && password.isNotEmpty) {
    formData.append('password', password);
  }

  int lastReportTime = 0;
  final totalBytes = bytes.length;

  xhr.upload.onProgress.listen((html.ProgressEvent event) {
    final now = DateTime.now().millisecondsSinceEpoch;
    final sent = event.loaded ?? 0;
    final total = (event.total != null && event.total! > 0) ? event.total! : totalBytes;

    // Report at ~600ms throttle or when 100% reached
    if (sent >= total) {
      if (onProgress != null) {
        onProgress(total, total);
      }
      if (onAnalyzing != null) {
        onAnalyzing();
      }
    } else if (now - lastReportTime >= 550) {
      lastReportTime = now;
      if (onProgress != null) {
        onProgress(sent, total);
      }
    }
  });

  xhr.onLoad.listen((_) {
    final status = xhr.status ?? 0;
    final responseText = xhr.responseText ?? '';
    try {
      final json = jsonDecode(responseText) as Map<String, dynamic>;
      completer.complete({'statusCode': status, 'data': json});
    } catch (_) {
      completer.complete({
        'statusCode': status,
        'data': {'detail': responseText.isNotEmpty ? responseText : 'HTTP $status'}
      });
    }
  });

  xhr.onError.listen((_) {
    completer.complete({
      'statusCode': xhr.status ?? 500,
      'data': {'detail': 'Network error during document transmission.'}
    });
  });

  xhr.send(formData);

  return completer.future;
}
