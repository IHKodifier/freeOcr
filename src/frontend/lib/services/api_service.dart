import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;

class UploadResult {
  final bool isSuccess;
  final String? jobId;
  final String? status;
  final String? errorMessage;

  UploadResult({
    required this.isSuccess,
    this.jobId,
    this.status,
    this.errorMessage,
  });
}

class ApiService {
  static const String baseUrl = 'http://127.0.0.1:8000/api/v1';

  static Future<UploadResult> uploadDocument({
    required String filename,
    required Uint8List bytes,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl/ocr/convert');
      final request = http.MultipartRequest('POST', uri);

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
        return UploadResult(
          isSuccess: true,
          jobId: data['job_id'] as String?,
          status: data['status'] as String?,
        );
      } else {
        String detail = 'Upload failed with status code ${response.statusCode}';
        try {
          final data = jsonDecode(response.body) as Map<String, dynamic>;
          if (data.containsKey('detail')) {
            detail = data['detail'] as String;
          }
        } catch (_) {}

        return UploadResult(
          isSuccess: false,
          errorMessage: detail,
        );
      }
    } catch (e) {
      return UploadResult(
        isSuccess: false,
        errorMessage: 'Network error connecting to OCR server: $e',
      );
    }
  }
}
