import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class JobEvent {
  final String jobId;
  final String status;
  final int currentPage;
  final int totalPages;
  final String? outputPdfToken;
  final String? errorMessage;
  final String? layoutComplexity;
  final String? targetEngine;
  final bool coldStartActive;

  JobEvent({
    required this.jobId,
    required this.status,
    required this.currentPage,
    required this.totalPages,
    this.outputPdfToken,
    this.errorMessage,
    this.layoutComplexity,
    this.targetEngine,
    this.coldStartActive = false,
  });

  factory JobEvent.fromJson(Map<String, dynamic> json) {
    return JobEvent(
      jobId: json['job_id']?.toString() ?? '',
      status: json['status']?.toString() ?? 'QUEUED',
      currentPage: json['current_page'] is int
          ? json['current_page'] as int
          : (json['current_page'] != null ? int.tryParse(json['current_page'].toString()) ?? 0 : 0),
      totalPages: json['total_pages'] is int
          ? json['total_pages'] as int
          : (json['total_pages'] != null ? int.tryParse(json['total_pages'].toString()) ?? 1 : 1),
      outputPdfToken: json['output_pdf_token'] as String?,
      errorMessage: json['error_message'] as String?,
      layoutComplexity: json['layout_complexity'] as String?,
      targetEngine: json['target_engine'] as String?,
      coldStartActive: json['cold_start_active'] == true,
    );
  }

  bool get isCompleted => status == 'COMPLETED';
  bool get isFailed => status == 'FAILED';
  double get progress {
    if (status == 'COMPLETED') return 1.0;
    if (totalPages <= 0) return 0.0;
    final p = currentPage / totalPages;
    return p.clamp(0.0, 1.0);
  }
}

typedef OcrProgressEvent = JobEvent;

class SseService {
  static const String defaultBaseUrl = String.fromEnvironment(
    'BACKEND_BASE_URL',
    defaultValue: kIsWeb ? '' : 'http://127.0.0.1:8000',
  );

  final String baseUrl;
  final http.Client _client;

  SseService({String? baseUrl, http.Client? client})
      : baseUrl = baseUrl ?? defaultBaseUrl,
        _client = client ?? http.Client();

  static Stream<JobEvent> listenToJobEvents(String jobId, {String? baseUrl}) {
    return SseService(baseUrl: baseUrl ?? defaultBaseUrl).subscribeToJob(jobId);
  }

  Stream<JobEvent> subscribeToJob(String jobId) {
    final controller = StreamController<JobEvent>();
    final uri = Uri.parse('$baseUrl/api/v1/jobs/$jobId/events');

    final request = http.Request('GET', uri);
    request.headers['Accept'] = 'text/event-stream';
    request.headers['Cache-Control'] = 'no-cache';

    _client.send(request).then((response) {
      if (response.statusCode != 200) {
        controller.addError('Failed to connect to SSE stream: ${response.statusCode}');
        controller.close();
        return;
      }

      response.stream
          .transform(utf8.decoder)
          .transform(const LineSplitter())
          .listen(
        (line) {
          final trimmed = line.trim();
          if (trimmed.startsWith('data:')) {
            final jsonStr = trimmed.substring(5).trim();
            if (jsonStr.isNotEmpty) {
              try {
                final data = json.decode(jsonStr) as Map<String, dynamic>;
                final event = JobEvent.fromJson(data);
                controller.add(event);
                if (event.status == 'COMPLETED' || event.status == 'FAILED') {
                  controller.close();
                }
              } catch (e) {
                // Ignore parse errors on malformed frames
              }
            }
          }
        },
        onError: (error) {
          controller.addError(error);
          controller.close();
        },
        onDone: () {
          if (!controller.isClosed) {
            controller.close();
          }
        },
        cancelOnError: true,
      );
    }).catchError((error) {
      if (!controller.isClosed) {
        controller.addError(error);
        controller.close();
      }
    });

    return controller.stream;
  }
}
