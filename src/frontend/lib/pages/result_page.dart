import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../widgets/adsense_banner.dart';
import '../widgets/split_preview_viewer.dart';
import '../widgets/expired_link_view.dart';

import '../services/telemetry_service.dart';

import '../widgets/app_footer.dart';

import '../widgets/app_header.dart';
import '../main.dart' show themeNotifier;

/// Dedicated Route Page for Result & Interactive Comparison (/result/{job_id})
/// Provides clean URL page navigation for SEO & engagement tracking while keeping
/// dynamic AdSense rotation active.
class ResultPage extends StatefulWidget {
  final String jobId;
  final String? filename;
  final List<dynamic>? pages;

  const ResultPage({
    super.key,
    required this.jobId,
    this.filename,
    this.pages,
  });

  @override
  State<ResultPage> createState() => _ResultPageState();
}

class _ResultPageState extends State<ResultPage> {
  Map<String, dynamic>? _previewData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    TelemetryService.trackPageView('/result/${widget.jobId}', pageTitle: 'freeOCR.me — Result Preview');
    _loadPreviewData();
  }

  Future<void> _loadPreviewData() async {
    if (widget.pages != null && widget.pages!.isNotEmpty) {
      if (mounted) {
        setState(() {
          _previewData = {
            'job_id': widget.jobId,
            'pages': widget.pages,
          };
          _isLoading = false;
        });
      }
      return;
    }

    final data = await ApiService.fetchJobPreview(widget.jobId);
    if (mounted) {
      setState(() {
        _previewData = data;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final displayName = widget.filename ?? 'Document';

    return Scaffold(
      appBar: AppHeader(
        currentRoute: '/result',
        onThemeToggle: () {
          if (isDark) {
            themeNotifier.value = ThemeMode.light;
          } else {
            themeNotifier.value = ThemeMode.dark;
          }
        },
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
                child: Column(
                  children: [
                    const AdSenseBanner(),
                    const SizedBox(height: 16),
                    if (_isLoading)
                      const Padding(
                        padding: EdgeInsets.all(40.0),
                        child: CircularProgressIndicator(),
                      )
                    else if (_previewData != null && _previewData!['is_expired'] == true)
                      ExpiredLinkView(
                        rawExpiredAtString: _previewData!['expired_at'] as String?,
                        onUploadNew: () => Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false),
                      )
                    else if (_previewData != null && _previewData!.containsKey('pages')) ...[
                      SplitPreviewViewer(
                        jobId: widget.jobId,
                        filename: displayName,
                        pages: _previewData!['pages'] as List<dynamic>? ?? [],
                        onClose: () => Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton.icon(
                        onPressed: () => Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false),
                        icon: const Icon(Icons.upload_file),
                        label: const Text('Convert Another File'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ] else
                      const Padding(
                        padding: EdgeInsets.all(40.0),
                        child: Text('Preview unavailable.'),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
            const AppFooter(),
          ],
        ),
      ),
    );
  }
}
