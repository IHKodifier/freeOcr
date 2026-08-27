import 'dart:async';
import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../services/sse_service.dart';
import 'split_preview_viewer.dart';
import 'expired_link_view.dart';
import 'adsense_banner.dart';
import '../pages/result_page.dart';



class OcrProgressView extends StatefulWidget {

  final String? jobId;
  final String? filename;
  final int? fileSize;
  final List<BatchFileItem>? batchItems;
  final int currentPage;
  final int totalPages;
  final String status;
  final String? outputPdfToken;
  final String? errorMessage;
  final VoidCallback? onReset;

  const OcrProgressView({
    super.key,
    this.jobId,
    this.filename,
    this.fileSize,
    this.batchItems,
    this.currentPage = 0,
    this.totalPages = 0,
    this.status = 'QUEUED',
    this.outputPdfToken,
    this.errorMessage,
    this.onReset,
  });

  @override
  State<OcrProgressView> createState() => _OcrProgressViewState();
}

class _OcrProgressViewState extends State<OcrProgressView> {
  final Map<String, StreamSubscription<OcrProgressEvent>> _subscriptions = {};

  late int _currentPage;
  late int _totalPages;
  late String _status;
  String? _outputPdfToken;
  String? _errorMessage;
  List<BatchFileItem> _batchItems = [];
  bool _showPreview = false;
  Map<String, dynamic>? _previewData;
  bool _isLoadingPreview = false;

  Future<void> _toggleSplitPreview() async {
    if (_showPreview) {
      setState(() {
        _showPreview = false;
      });
      return;
    }

    final jobId = widget.jobId ?? (_batchItems.isNotEmpty ? _batchItems.first.jobId : null);
    if (jobId == null) return;

    setState(() {
      _isLoadingPreview = true;
    });

    final data = await ApiService.fetchJobPreview(jobId);

    if (mounted) {
      setState(() {
        _isLoadingPreview = false;
        if (data != null && (data.containsKey('pages') || data['is_expired'] == true)) {
          _previewData = data;
          _showPreview = true;
          AdSenseBanner.rotateAd();
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ResultPage(
                jobId: jobId,
                filename: widget.filename,
                pages: data['pages'] as List<dynamic>?,
              ),
              settings: RouteSettings(name: '/result/$jobId'),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Could not load preview data.')),
          );
        }
      });
    }


  }

  @override
  void initState() {
    super.initState();
    _currentPage = widget.currentPage;
    _totalPages = widget.totalPages;
    _status = widget.status;
    _outputPdfToken = widget.outputPdfToken;
    _errorMessage = widget.errorMessage;
    _batchItems = widget.batchItems != null ? List.from(widget.batchItems!) : [];

    if (_batchItems.isNotEmpty) {
      _subscribeToBatchSse();
    } else if (widget.jobId != null && widget.jobId!.isNotEmpty) {
      _subscribeToSingleSse(widget.jobId!);
    }
  }

  Future<void> _refreshPreviewData(String jobId) async {
    final data = await ApiService.fetchJobPreview(jobId);
    if (mounted && data != null) {
      if (data.containsKey('pages') || data['is_expired'] == true) {
        setState(() {
          _previewData = data;
        });
      }
    }
  }

  void _subscribeToSingleSse(String jobId) {
    _subscriptions[jobId]?.cancel();
    _subscriptions[jobId] = SseService.listenToJobEvents(jobId).listen(
      (event) {
        if (mounted) {
          final previousStatus = _status;
          setState(() {
            _currentPage = event.currentPage;
            _totalPages = event.totalPages;
            _status = event.status;
            if (event.outputPdfToken != null) {
              _outputPdfToken = event.outputPdfToken;
            }
            if (event.errorMessage != null) {
              _errorMessage = event.errorMessage;
            }
          });
          if (previousStatus != event.status &&
              (event.status == 'QUEUED' || event.status == 'PROCESSING' || event.status == 'COMPLETED')) {
            AdSenseBanner.rotateAd();
          }
          if (event.status == 'COMPLETED') {
            _refreshPreviewData(jobId);
          }
        }
      },


      onError: (error) {
        if (mounted) {
          setState(() {
            _status = 'FAILED';
            _errorMessage = 'Stream error: $error';
          });
        }
      },
    );
  }

  void _subscribeToBatchSse() {
    for (final item in _batchItems) {
      if (item.jobId != null && item.jobId!.isNotEmpty) {
        _subscriptions[item.jobId!]?.cancel();
        _subscriptions[item.jobId!] = SseService.listenToJobEvents(item.jobId!).listen(
          (event) {
            if (mounted) {
              final previousStatus = item.status;
              setState(() {
                item.currentPage = event.currentPage;
                item.totalPages = event.totalPages;
                item.status = event.status;
                if (event.outputPdfToken != null) {
                  item.outputPdfToken = event.outputPdfToken;
                }
                if (event.errorMessage != null) {
                  item.errorMessage = event.errorMessage;
                }
              });
              if (previousStatus != event.status &&
                  (event.status == 'QUEUED' || event.status == 'PROCESSING' || event.status == 'COMPLETED')) {
                AdSenseBanner.rotateAd();
              }
            }
          },


          onError: (error) {
            if (mounted) {
              setState(() {
                item.status = 'FAILED';
                item.errorMessage = 'Stream error: $error';
              });
            }
          },
        );
      }
    }
  }

  @override
  void dispose() {
    for (final sub in _subscriptions.values) {
      sub.cancel();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final String displayName = widget.filename ?? (_batchItems.isNotEmpty ? _batchItems.first.filename : 'Document');

    if (_showPreview && _previewData != null) {
      if (_previewData!['is_expired'] == true) {
        return ExpiredLinkView(
          rawExpiredAtString: _previewData!['expired_at'] as String?,
          onUploadNew: widget.onReset,
        );
      }

      return Column(
        children: [
          SplitPreviewViewer(
            jobId: widget.jobId ?? (_previewData!['job_id'] as String? ?? ''),
            filename: displayName,
            pages: _previewData!['pages'] as List<dynamic>? ?? [],
            onClose: () => setState(() => _showPreview = false),
          ),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: () => setState(() => _showPreview = false),
            icon: const Icon(Icons.arrow_back),
            label: const Text('Back to Status View'),
          ),
        ],
      );
    }

    if (_batchItems.length > 1) {
      return _buildBatchProgressUI(theme, colorScheme);
    }

    return _buildSingleProgressUI(theme, colorScheme);
  }


  Widget _buildSingleProgressUI(ThemeData theme, ColorScheme colorScheme) {
    final isCompleted = _status == 'COMPLETED';
    final isFailed = _status == 'FAILED';
    final double progress = _totalPages > 0 ? (_currentPage / _totalPages).clamp(0.0, 1.0) : 0.0;
    final int percentInt = (progress * 100).round();

    final String displayName = widget.filename ?? (_batchItems.isNotEmpty ? _batchItems.first.filename : 'Document');
    final int displaySize = widget.fileSize ?? (_batchItems.isNotEmpty ? _batchItems.first.sizeInBytes : 0);

    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(maxWidth: 680, minHeight: 300),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHigh.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isCompleted
              ? Colors.green.shade400
              : isFailed
                  ? colorScheme.error
                  : colorScheme.primary,
          width: 2.0,
        ),
        boxShadow: [
          BoxShadow(
            color: (isCompleted
                    ? Colors.green
                    : isFailed
                        ? colorScheme.error
                        : colorScheme.primary)
                .withValues(alpha: 0.12),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // File Metadata Card
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: colorScheme.outlineVariant),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  displayName.toLowerCase().endsWith('.pdf')
                      ? Icons.picture_as_pdf
                      : Icons.image,
                  color: colorScheme.primary,
                  size: 28,
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      displayName,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '${getFileTypeDescription(displayName)} • ${formatBytes(displaySize)}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          if (isCompleted) ...[
            Icon(
              Icons.check_circle_outline,
              size: 64,
              color: Colors.green.shade600,
            ),
            const SizedBox(height: 16),
            Text(
              'Conversion Complete!',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.green.shade700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Searchable PDF ready for preview & download',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            if (_outputPdfToken != null) ...[
              const SizedBox(height: 12),
              SelectableText(
                'Token: $_outputPdfToken',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.tertiary,
                  fontFamily: 'monospace',
                ),
              ),
            ],
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: _isLoadingPreview ? null : _toggleSplitPreview,
              icon: _isLoadingPreview
                  ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Icon(Icons.vertical_split_rounded),
              label: const Text('Interactive Split Preview'),
            ),

          ] else if (isFailed) ...[
            Icon(
              Icons.error_outline,
              size: 64,
              color: colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Conversion Failed',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.error,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage ?? 'An error occurred during OCR processing.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ] else ...[
            Icon(
              Icons.hourglass_top_rounded,
              size: 56,
              color: colorScheme.primary,
            ),
            const SizedBox(height: 16),
            Text(
              'Processing Document...',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _totalPages > 0
                  ? 'Page $_currentPage of $_totalPages ($percentInt%)'
                  : 'Queued in OCR pipeline...',
              style: theme.textTheme.titleMedium?.copyWith(
                color: colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: 380,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: _totalPages > 0 ? progress : null,
                  minHeight: 10,
                  backgroundColor: colorScheme.surfaceContainerHighest,
                  valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),
                ),
              ),
            ),
          ],

          if (widget.onReset != null) ...[
            const SizedBox(height: 24),
            OutlinedButton.icon(
              onPressed: widget.onReset,
              icon: const Icon(Icons.refresh),
              label: const Text('Convert Another File'),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBatchProgressUI(ThemeData theme, ColorScheme colorScheme) {
    final completedCount = _batchItems.where((i) => i.status == 'COMPLETED').length;
    final failedCount = _batchItems.where((i) => i.status == 'FAILED').length;
    final isAllDone = (completedCount + failedCount) == _batchItems.length;

    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(maxWidth: 680, minHeight: 300),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHigh.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isAllDone ? Colors.green.shade400 : colorScheme.primary,
          width: 2.0,
        ),
        boxShadow: [
          BoxShadow(
            color: (isAllDone ? Colors.green : colorScheme.primary).withValues(alpha: 0.12),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(
            isAllDone ? Icons.task_alt : Icons.bolt,
            size: 48,
            color: isAllDone ? Colors.green.shade600 : colorScheme.primary,
          ),
          const SizedBox(height: 12),
          Text(
            isAllDone ? 'Batch Processing Complete!' : 'Processing Batch OCR Queue',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '$completedCount of ${_batchItems.length} Files Converted',
            style: theme.textTheme.titleMedium?.copyWith(
              color: isAllDone ? Colors.green.shade700 : colorScheme.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 24),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _batchItems.length,
            separatorBuilder: (_, _) => const SizedBox(height: 12),

            itemBuilder: (context, index) {
              final item = _batchItems[index];
              final isDone = item.status == 'COMPLETED';
              final isErr = item.status == 'FAILED';

              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDone
                      ? Colors.green.withValues(alpha: 0.08)
                      : isErr
                          ? colorScheme.errorContainer.withValues(alpha: 0.2)
                          : colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isDone
                        ? Colors.green.shade300
                        : isErr
                            ? colorScheme.error
                            : colorScheme.outlineVariant,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      item.filename.toLowerCase().endsWith('.pdf')
                          ? Icons.picture_as_pdf
                          : Icons.image,
                      color: colorScheme.primary,
                      size: 28,
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.filename,
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            item.totalPages > 0
                                ? 'Page ${item.currentPage} of ${item.totalPages}'
                                : item.status,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    if (isDone)
                      Icon(Icons.check_circle, color: Colors.green.shade600)
                    else if (isErr)
                      Icon(Icons.error_outline, color: colorScheme.error)
                    else
                      const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2.5),
                      ),
                  ],
                ),
              );
            },
          ),
          if (widget.onReset != null && isAllDone) ...[
            const SizedBox(height: 24),
            OutlinedButton.icon(
              onPressed: widget.onReset,
              icon: const Icon(Icons.refresh),
              label: const Text('Convert More Files'),
            ),
          ],
        ],
      ),
    );
  }
}
