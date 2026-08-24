import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;


class OcrProgressEvent {
  final int currentPage;
  final int totalPages;
  final String status;
  final String? outputPdfToken;
  final String? errorMessage;

  OcrProgressEvent({
    required this.currentPage,
    required this.totalPages,
    required this.status,
    this.outputPdfToken,
    this.errorMessage,
  });

  double get progressPercentage {
    if (totalPages <= 0) return 0.0;
    return (currentPage / totalPages).clamp(0.0, 1.0);
  }
}

class SseService {
  static const String baseUrl = 'http://127.0.0.1:8000/api/v1';

  static Stream<OcrProgressEvent> listenToJobEvents(String jobId) {
    final controller = StreamController<OcrProgressEvent>();
    final client = http.Client();
    final uri = Uri.parse('$baseUrl/jobs/$jobId/events');

    final request = http.Request('GET', uri);
    request.headers['Accept'] = 'text/event-stream';

    client.send(request).then((response) {
      if (response.statusCode != 200) {
        controller.add(
          OcrProgressEvent(
            currentPage: 0,
            totalPages: 0,
            status: 'FAILED',
            errorMessage: 'HTTP ${response.statusCode}: Job not found or stream error',
          ),
        );
        controller.close();
        client.close();
        return;
      }

      response.stream
          .transform(utf8.decoder)
          .transform(const LineSplitter())
          .listen(
        (line) {
          if (line.startsWith('data: ')) {
            final jsonStr = line.substring(6).trim();
            try {
              final Map<String, dynamic> data = jsonDecode(jsonStr);
              final event = OcrProgressEvent(
                currentPage: data['current_page'] as int? ?? 0,
                totalPages: data['total_pages'] as int? ?? 0,
                status: data['status'] as String? ?? 'PROCESSING',
                outputPdfToken: data['output_pdf_token'] as String?,
              );
              debugPrint(
                '[SSE Event] Job $jobId: status=${event.status}, page=${event.currentPage}/${event.totalPages}',
              );
              controller.add(event);

              if (event.status == 'COMPLETED' || event.status == 'FAILED') {
                debugPrint('[SSE Closed] Job $jobId stream finished with status ${event.status}');
                controller.close();
                client.close();
              }
            } catch (e) {
              debugPrint('[SSE Error] Failed to parse event JSON: $e');
            }
          }
        },

        onError: (error) {
          controller.add(
            OcrProgressEvent(
              currentPage: 0,
              totalPages: 0,
              status: 'FAILED',
              errorMessage: 'Stream connection error: $error',
            ),
          );
          controller.close();
          client.close();
        },
        onDone: () {
          if (!controller.isClosed) {
            controller.close();
          }
          client.close();
        },
      );
    }).catchError((error) {
      controller.add(
        OcrProgressEvent(
          currentPage: 0,
          totalPages: 0,
          status: 'FAILED',
          errorMessage: 'Connection error: $error',
        ),
      );
      controller.close();
      client.close();
    });

    return controller.stream;
  }
}
