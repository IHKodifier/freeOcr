import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class UploadResult {
  final bool isSuccess;
  final String? jobId;
  final String? status;
  final String? errorMessage;
  final bool isPasswordRequired;

  UploadResult({
    required this.isSuccess,
    this.jobId,
    this.status,
    this.errorMessage,
    this.isPasswordRequired = false,
  });
}

class BatchFileItem {
  final String id;
  final String filename;
  final int sizeInBytes;
  final Uint8List bytes;
  String? jobId;
  String status; // 'QUEUED', 'UPLOADING', 'PROCESSING', 'COMPLETED', 'FAILED'
  int sentBytes;
  int totalBytes;
  int currentPage;
  int totalPages;
  String? outputPdfToken;
  String? errorMessage;

  BatchFileItem({
    required this.id,
    required this.filename,
    required this.sizeInBytes,
    required this.bytes,
    this.jobId,
    this.status = 'QUEUED',
    this.sentBytes = 0,
    int? totalBytes,
    this.currentPage = 0,
    this.totalPages = 0,
    this.outputPdfToken,
    this.errorMessage,
  }) : totalBytes = totalBytes ?? sizeInBytes;

  double get uploadProgress {
    if (totalBytes <= 0) return 0.0;
    return (sentBytes / totalBytes).clamp(0.0, 1.0);
  }

  double get ocrProgress {
    if (totalPages <= 0) return 0.0;
    return (currentPage / totalPages).clamp(0.0, 1.0);
  }
}

class MultipartRequestWithProgress extends http.MultipartRequest {
  final Function(int sentBytes, int totalBytes) onProgress;

  MultipartRequestWithProgress(
    super.method,
    super.url, {
    required this.onProgress,
  });

  @override
  http.ByteStream finalize() {
    final byteStream = super.finalize();
    final total = contentLength;
    int sent = 0;

    final transformer = StreamTransformer<List<int>, List<int>>.fromHandlers(
      handleData: (data, sink) {
        sent += data.length;
        onProgress(sent, total);
        sink.add(data);
      },
    );

    return http.ByteStream(byteStream.transform(transformer));
  }
}

String formatBytes(int bytes, [int decimals = 1]) {
  if (bytes <= 0) return "0 B";
  const suffixes = ["B", "KB", "MB", "GB"];
  var i = (log(bytes) / log(1024)).floor();
  return '${(bytes / pow(1024, i)).toStringAsFixed(decimals)} ${suffixes[i]}';
}

String getFileTypeDescription(String filename) {
  final ext = filename.split('.').last.toLowerCase();
  switch (ext) {
    case 'pdf':
      return 'PDF Document';
    case 'png':
      return 'PNG Image';
    case 'jpg':
    case 'jpeg':
      return 'JPEG Image';
    default:
      return '${ext.toUpperCase()} File';
  }
}

class ApiService {
  static const String baseUrl = 'http://127.0.0.1:8000/api/v1';

  static Future<UploadResult> uploadDocument({
    required String filename,
    required Uint8List bytes,
    String? password,
    Function(int sentBytes, int totalBytes)? onProgress,
  }) async {
    try {
      debugPrint('[API Upload] Starting upload of $filename (${formatBytes(bytes.length)})...');
      final uri = Uri.parse('$baseUrl/ocr/convert');

      final request = MultipartRequestWithProgress(
        'POST',
        uri,
        onProgress: (sent, total) {
          final percentage = total > 0 ? ((sent / total) * 100).round() : 0;
          debugPrint(
            '[API Upload Progress] $filename: $percentage% (${formatBytes(sent)} / ${formatBytes(total)})',
          );
          if (onProgress != null) {
            onProgress(sent, total);
          }
        },
      );

      if (password != null && password.isNotEmpty) {
        request.fields['password'] = password;
      }

      request.files.add(
        http.MultipartFile.fromBytes(
          'file',
          bytes,
          filename: filename,
        ),
      );

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 202) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final jobId = data['job_id'] as String?;
        final jobStatus = data['status'] as String?;
        debugPrint('[API Upload Success] Job ID: $jobId, Status: $jobStatus');
        return UploadResult(
          isSuccess: true,
          jobId: jobId,
          status: jobStatus,
        );
      } else {
        String detail = 'Upload failed with status code ${response.statusCode}';
        bool isPasswordReq = false;
        try {
          final data = jsonDecode(response.body) as Map<String, dynamic>;
          if (data.containsKey('error') && data['error'] == 'PASSWORD_REQUIRED') {
            isPasswordReq = true;
            detail = data['message'] as String? ?? 'Password Protected PDF. Please provide password to unlock.';
          } else if (data.containsKey('detail')) {
            detail = data['detail'] as String;
          }
        } catch (_) {}

        debugPrint('[API Upload Error] $detail');
        return UploadResult(
          isSuccess: false,
          isPasswordRequired: isPasswordReq,
          errorMessage: detail,
        );
      }
    } catch (e) {
      debugPrint('[API Upload Exception] $e');
      return UploadResult(
        isSuccess: false,
        errorMessage: 'Network error connecting to OCR server: $e',
      );
    }
  }

  static Future<Map<String, dynamic>?> fetchJobPreview(String jobId) async {
    try {
      final uri = Uri.parse('$baseUrl/jobs/$jobId/preview');
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else if (response.statusCode == 410) {
        try {
          final data = jsonDecode(response.body) as Map<String, dynamic>;
          return {
            'is_expired': true,
            'expired_at': data['expired_at'],
            'detail': data['detail'],
          };
        } catch (_) {
          return {'is_expired': true, 'detail': 'Download link expired.'};
        }
      }
      return null;
    } catch (e) {
      debugPrint('[API Preview Error] $e');
      return null;
    }
  }

  static Future<void> prewarmBackend() async {
    try {
      debugPrint('[API Pre-Warm] Sending silent background ping to wake scale-to-zero backend...');
      final uri = Uri.parse('$baseUrl/config');
      await http.get(uri).timeout(const Duration(seconds: 10));
      debugPrint('[API Pre-Warm] Backend container warm and responsive.');
    } catch (e) {
      debugPrint('[API Pre-Warm] Warmup ping sent (container booting): $e');
    }
  }

  static String getDownloadUrl(String jobId, String format) {
    return '$baseUrl/jobs/$jobId/download/$format';
  }

  static Future<Map<String, dynamic>> sendEmailLinks(String jobId, String email) async {
    try {
      final uri = Uri.parse('$baseUrl/ocr/email-links');
      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'job_id': jobId, 'email': email}),
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else {
        String detail = 'Email delivery failed (${response.statusCode})';
        try {
          final data = jsonDecode(response.body) as Map<String, dynamic>;
          if (data.containsKey('detail')) {
            detail = data['detail'] as String;
          }
        } catch (_) {}
        return {'status': 'ERROR', 'detail': detail};
      }
    } catch (e) {
      return {'status': 'ERROR', 'detail': 'Network connection error: $e'};
    }
  }
}



