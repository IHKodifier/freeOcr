import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;

/// Fallback uploader for non-web environments (tests, desktop).
Future<Map<String, dynamic>> uploadWithRealSocketProgress({
  required String url,
  required String filename,
  required Uint8List bytes,
  Map<String, String>? headers,
  String? password,
  Function(int sentBytes, int totalBytes)? onProgress,
  Function()? onAnalyzing,
}) async {
  final request = http.MultipartRequest('POST', Uri.parse(url));
  if (headers != null) {
    request.headers.addAll(headers);
  }
  if (password != null && password.isNotEmpty) {
    request.fields['password'] = password;
  }
  request.files.add(http.MultipartFile.fromBytes('file', bytes, filename: filename));

  if (onProgress != null) {
    onProgress(bytes.length, bytes.length);
  }
  if (onAnalyzing != null) {
    onAnalyzing();
  }

  final streamed = await request.send();
  final response = await http.Response.fromStream(streamed);

  try {
    final json = jsonDecode(response.body) as Map<String, dynamic>;
    return {'statusCode': response.statusCode, 'data': json};
  } catch (_) {
    return {
      'statusCode': response.statusCode,
      'data': {'detail': response.body}
    };
  }
}
