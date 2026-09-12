import 'dart:async';
import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../services/download_helper.dart';
import '../services/sse_service.dart';
import '../services/telemetry_service.dart';
import 'split_preview_viewer.dart';
import 'expired_link_view.dart';
import 'adsense_banner.dart';
import '../pages/result_page.dart';



class OcrProgressView extends StatefulWidget {

  final String? jobId;
  final String? filename;
  final int? fileSize;
  final List<BatchFileItem>? batchItems;
  final int uploadSentBytes;
  final int uploadTotalBytes;
  final int currentPage;
  final int totalPages;
  final String status;
  final String? outputPdfToken;
  final String? errorMessage;
  final String? layoutComplexity;
  final bool coldStartActive;
  final VoidCallback? onReset;

  const OcrProgressView({
    super.key,
    this.jobId,
    this.filename,
    this.fileSize,
    this.batchItems,
    this.uploadSentBytes = 0,
    this.uploadTotalBytes = 0,
    this.currentPage = 0,
    this.totalPages = 0,
    this.status = 'QUEUED',
    this.outputPdfToken,
    this.errorMessage,
    this.layoutComplexity,
    this.coldStartActive = false,
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
  String? _layoutComplexity;
  bool _coldStartActive = false;
  String? _outputPdfToken;
  String? _errorMessage;
  List<BatchFileItem> _batchItems = [];
  bool _showPreview = false;
  Map<String, dynamic>? _previewData;
  bool _isLoadingPreview = false;
  Timer? _pollingTimer;

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

  Future<void> _openResultPage(String jobId, String filename) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ResultPage(
          jobId: jobId,
          filename: filename,
        ),
        settings: RouteSettings(name: '/result/$jobId'),
      ),
    );
  }

  void _downloadBatchItemFile(String jobId, String filename, String format, {bool showToast = true}) {
    final url = ApiService.getDownloadUrl(jobId, format);
    final dotIndex = filename.lastIndexOf('.');
    final stem = dotIndex > 0 ? filename.substring(0, dotIndex) : filename;
    final ext = format == 'pdf' ? '_searchable.pdf' : '_extracted.$format';
    final outFilename = '$stem$ext';

    DownloadHelper.triggerDownload(url, outFilename);
    TelemetryService.trackDownloadClicked(
      jobId: jobId,
      format: format,
      filename: outFilename,
    );
    if (showToast && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Downloading $outFilename...'),
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _downloadAllCompletedAsZip() {
    final completedItems = _batchItems.where((i) => i.status == 'COMPLETED' && i.jobId != null).toList();
    if (completedItems.isEmpty) return;

    final jobIds = completedItems.map((i) => i.jobId!).toList();
    final url = ApiService.getBatchDownloadZipUrl(jobIds, 'pdf');
    const outFilename = 'freeOCR_searchable_batch.zip';

    DownloadHelper.triggerDownload(url, outFilename);
    TelemetryService.trackDownloadClicked(
      jobId: jobIds.first,
      format: 'zip',
      filename: outFilename,
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Downloading single ZIP containing all ${completedItems.length} Searchable PDFs...'),
          duration: const Duration(seconds: 4),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  void didUpdateWidget(covariant OcrProgressView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.status != oldWidget.status) {
      setState(() {
        _status = widget.status;
      });
    }
    if (widget.layoutComplexity != oldWidget.layoutComplexity && widget.layoutComplexity != null) {
      setState(() {
        _layoutComplexity = widget.layoutComplexity;
      });
    }
    if (widget.coldStartActive != oldWidget.coldStartActive) {
      setState(() {
        _coldStartActive = widget.coldStartActive;
      });
    }
    if (widget.errorMessage != oldWidget.errorMessage && widget.errorMessage != null) {
      setState(() {
        _errorMessage = widget.errorMessage;
      });
    }
    if (widget.jobId != oldWidget.jobId && widget.jobId != null && widget.jobId!.isNotEmpty) {
      _subscribeToSingleSse(widget.jobId!);
      _startPollingFallback();
    }
  }

  @override
  void initState() {
    super.initState();
    _currentPage = widget.currentPage;
    _totalPages = widget.totalPages;
    _status = widget.status;
    _layoutComplexity = widget.layoutComplexity;
    _coldStartActive = widget.coldStartActive;
    _outputPdfToken = widget.outputPdfToken;
    _errorMessage = widget.errorMessage;
    _batchItems = widget.batchItems != null ? List.from(widget.batchItems!) : [];

    if (_batchItems.isNotEmpty) {
      _subscribeToBatchSse();
      _startPollingFallback();
    } else if (widget.jobId != null && widget.jobId!.isNotEmpty) {
      _subscribeToSingleSse(widget.jobId!);
      _startPollingFallback();
    }
  }

  void _startPollingFallback() {
    _pollingTimer?.cancel();
    _pollingTimer = Timer.periodic(const Duration(seconds: 3), (_) async {
      if (!mounted) return;
      if (_status == 'COMPLETED' || _status == 'FAILED') {
        _pollingTimer?.cancel();
        return;
      }

      final singleJobId = widget.jobId;
      if (singleJobId != null && singleJobId.isNotEmpty) {
        final jobData = await ApiService.fetchJobStatus(singleJobId);
        if (mounted && jobData != null) {
          final status = jobData['status']?.toString();
          final layoutComp = jobData['layout_complexity']?.toString();
          final coldStart = jobData['cold_start_active'] == true;
          final currPage = jobData['current_page'] is int
              ? jobData['current_page'] as int
              : int.tryParse(jobData['current_page']?.toString() ?? '0') ?? 0;
          final totalPages = jobData['total_pages'] is int
              ? jobData['total_pages'] as int
              : int.tryParse(jobData['total_pages']?.toString() ?? '0') ?? 0;
          final token = jobData['output_pdf_token']?.toString();
          final error = jobData['error']?.toString();

          if (currPage > _currentPage || status != _status || (layoutComp != null && layoutComp != _layoutComplexity)) {
            setState(() {
              if (currPage > _currentPage) _currentPage = currPage;
              if (totalPages > 0) _totalPages = totalPages;
              if (status != null) _status = status;
              if (layoutComp != null) _layoutComplexity = layoutComp;
              if (currPage > 0 || status == 'PROCESSING' || status == 'COMPLETED') {
                _coldStartActive = false;
              } else {
                _coldStartActive = coldStart;
              }
              if (token != null) _outputPdfToken = token;
              if (error != null) _errorMessage = error;
            });
          }

          if (status == 'COMPLETED') {
            _pollingTimer?.cancel();
            TelemetryService.trackOcrCompleted(
              jobId: singleJobId,
              pageCount: _totalPages > 0 ? _totalPages : null,
            );
            _refreshPreviewData(singleJobId);
          }
        }
      }

      if (_batchItems.isNotEmpty) {
        bool allDone = true;
        for (final item in _batchItems) {
          if (item.jobId != null && item.status != 'COMPLETED' && item.status != 'FAILED') {
            allDone = false;
            final jobData = await ApiService.fetchJobStatus(item.jobId!);
            if (mounted && jobData != null) {
              final status = jobData['status']?.toString();
              final layoutComp = jobData['layout_complexity']?.toString();
              final coldStart = jobData['cold_start_active'] == true;
              final currPage = jobData['current_page'] is int ? jobData['current_page'] as int : 0;
              final totalPages = jobData['total_pages'] is int ? jobData['total_pages'] as int : 0;
              final token = jobData['output_pdf_token']?.toString();
              final error = jobData['error']?.toString();
              setState(() {
                if (currPage > item.currentPage) item.currentPage = currPage;
                if (totalPages > 0) item.totalPages = totalPages;
                if (status != null) item.status = status;
                if (layoutComp != null) item.layoutComplexity = layoutComp;
                if (currPage > 0 || status == 'PROCESSING' || status == 'COMPLETED') {
                  item.coldStartActive = false;
                } else {
                  item.coldStartActive = coldStart;
                }
                if (token != null) item.outputPdfToken = token;
                if (error != null) item.errorMessage = error;
              });
            }
          }
        }
        if (allDone) {
          _pollingTimer?.cancel();
        }
      }
    });
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
          setState(() {
            _currentPage = event.currentPage;
            _totalPages = event.totalPages;
            _status = event.status;
            if (event.layoutComplexity != null) {
              _layoutComplexity = event.layoutComplexity;
            }
            if (event.currentPage > 0 || event.status == 'PROCESSING' || event.status == 'COMPLETED') {
              _coldStartActive = false;
            } else {
              _coldStartActive = event.coldStartActive;
            }
            if (event.outputPdfToken != null) {
              _outputPdfToken = event.outputPdfToken;
            }
            if (event.errorMessage != null) {
              _errorMessage = event.errorMessage;
            }
          });
          if (event.status == 'COMPLETED') {
            TelemetryService.trackOcrCompleted(
              jobId: jobId,
              pageCount: event.totalPages > 0 ? event.totalPages : null,
            );
            _refreshPreviewData(jobId);
          }
        }
      },
      onError: (error) {
        debugPrint('[SSE Single Stream Notice] Transient stream reconnect: $error. Polling maintaining UI.');
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
              setState(() {
                item.currentPage = event.currentPage;
                item.totalPages = event.totalPages;
                item.status = event.status;
                if (event.layoutComplexity != null) {
                  item.layoutComplexity = event.layoutComplexity;
                }
                if (event.currentPage > 0 || event.status == 'PROCESSING' || event.status == 'COMPLETED') {
                  item.coldStartActive = false;
                } else {
                  item.coldStartActive = event.coldStartActive;
                }
                if (event.outputPdfToken != null) {
                  item.outputPdfToken = event.outputPdfToken;
                }
                if (event.errorMessage != null) {
                  item.errorMessage = event.errorMessage;
                }
              });
            }
          },
          onError: (error) {
            debugPrint('[SSE Batch Stream Notice] Transient stream reconnect: $error. Polling maintaining UI.');
          },
        );
      }
    }
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
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
            onClose: widget.onReset ?? () => setState(() => _showPreview = false),
          ),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: widget.onReset ?? () => setState(() => _showPreview = false),
            icon: const Icon(Icons.upload_file),
            label: const Text('Convert Another File'),
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
    final isUploading = _status == 'UPLOADING';
    final isCompleted = _status == 'COMPLETED';
    final isFailed = _status == 'FAILED';
    final double progress = _totalPages > 0 ? (_currentPage / _totalPages).clamp(0.0, 1.0) : 0.0;
    final int percentInt = (progress * 100).round();

    final String displayName = widget.filename ?? (_batchItems.isNotEmpty ? _batchItems.first.filename : 'Document');
    final int displaySize = widget.fileSize ?? (_batchItems.isNotEmpty ? _batchItems.first.sizeInBytes : 0);

    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(maxWidth: 680),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHigh.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isCompleted
              ? Colors.green.shade400
              : isFailed
                  ? colorScheme.error
                  : colorScheme.primary,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: (isCompleted
                    ? Colors.green
                    : isFailed
                        ? colorScheme.error
                        : colorScheme.primary)
                .withValues(alpha: 0.10),
            blurRadius: 14,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Compact File Metadata Card
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
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
                  size: 22,
                ),
                const SizedBox(width: 10),
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        displayName,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        '${getFileTypeDescription(displayName)} • ${formatBytes(displaySize)}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Single Layout Badge
          if (_layoutComplexity != null) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
              decoration: BoxDecoration(
                color: _layoutComplexity!.toUpperCase() == 'COMPLEX'
                    ? Colors.amber.shade900.withValues(alpha: 0.12)
                    : colorScheme.primary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: _layoutComplexity!.toUpperCase() == 'COMPLEX'
                      ? Colors.amber.shade600
                      : colorScheme.primary.withValues(alpha: 0.4),
                  width: 1.0,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _layoutComplexity!.toUpperCase() == 'COMPLEX'
                        ? Icons.auto_awesome
                        : Icons.bolt,
                    size: 12,
                    color: _layoutComplexity!.toUpperCase() == 'COMPLEX'
                        ? Colors.amber.shade700
                        : colorScheme.primary,
                  ),
                  const SizedBox(width: 5),
                  Text(
                    _layoutComplexity!.toUpperCase() == 'COMPLEX'
                        ? 'Complex Layout'
                        : 'Simple Layout',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: _layoutComplexity!.toUpperCase() == 'COMPLEX'
                          ? Colors.amber.shade700
                          : colorScheme.primary,
                      letterSpacing: 0.3,
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 12),

          if (isCompleted) ...[
            Icon(
              Icons.check_circle_outline,
              size: 44,
              color: Colors.green.shade600,
            ),
            const SizedBox(height: 8),
            Text(
              'Conversion Complete!',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.green.shade700,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Searchable PDF ready for preview & download',
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            if (_outputPdfToken != null) ...[
              const SizedBox(height: 6),
              SelectableText(
                'Token: $_outputPdfToken',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.tertiary,
                  fontFamily: 'monospace',
                  fontSize: 10,
                ),
              ),
            ],
            const SizedBox(height: 12),
            FilledButton.icon(
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: _isLoadingPreview ? null : _toggleSplitPreview,
              icon: _isLoadingPreview
                  ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Icon(Icons.vertical_split_rounded, size: 18),
              label: const Text('Proceed to My File', style: TextStyle(fontWeight: FontWeight.bold)),
            ),

          ] else if (isFailed) ...[
            Icon(
              Icons.error_outline,
              size: 44,
              color: colorScheme.error,
            ),
            const SizedBox(height: 8),
            Text(
              'Conversion Failed',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.error,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              _errorMessage ?? 'An error occurred during OCR processing.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ] else if (isUploading) ...[
            Icon(
              Icons.cloud_upload_outlined,
              size: 40,
              color: colorScheme.primary,
            ),
            const SizedBox(height: 8),
            Text(
              'Uploading Document...',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              widget.uploadTotalBytes > 0
                  ? '${formatBytes(widget.uploadSentBytes)} of ${formatBytes(widget.uploadTotalBytes)} (${(widget.uploadSentBytes / widget.uploadTotalBytes * 100).clamp(0, 100).toInt()}%)'
                  : 'Streaming document to RAM-disk...',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: 360,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: widget.uploadTotalBytes > 0
                      ? (widget.uploadSentBytes / widget.uploadTotalBytes).clamp(0.0, 1.0)
                      : null,
                  minHeight: 8,
                  backgroundColor: colorScheme.surfaceContainerHighest,
                  valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),
                ),
              ),
            ),
          ] else ...[
            AnimatedHourglassIcon(
              size: 40,
              color: colorScheme.primary,
            ),
            const SizedBox(height: 8),
            Text(
              (_coldStartActive && _currentPage == 0)
                  ? 'Getting things ready...'
                  : (_currentPage == 0 || _status == 'QUEUED')
                      ? 'Your document is in queue for conversion...'
                      : 'Processing Document...',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              (_coldStartActive && _currentPage == 0)
                  ? 'Warming up dedicated processing pipeline...'
                  : (_currentPage == 0 || _status == 'QUEUED')
                      ? 'Preparing pages for extraction...'
                      : (_totalPages > 0
                          ? 'Page $_currentPage of $_totalPages ($percentInt%)'
                          : 'Running OCR pipeline...'),
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: 360,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: _totalPages > 0 ? progress : null,
                  minHeight: 8,
                  backgroundColor: colorScheme.surfaceContainerHighest,
                  valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),
                ),
              ),
            ),
          ],

          if (widget.onReset != null) ...[
            const SizedBox(height: 10),
            OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: widget.onReset,
              icon: const Icon(Icons.refresh, size: 15),
              label: const Text('Convert Another File', style: TextStyle(fontSize: 12)),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBatchProgressUI(ThemeData theme, ColorScheme colorScheme) {
    final completedCount = _batchItems.where((i) => i.status == 'COMPLETED' && i.jobId != null).length;
    final failedCount = _batchItems.where((i) => i.status == 'FAILED').length;
    final isAllDone = (completedCount + failedCount) == _batchItems.length;

    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(maxWidth: 720, minHeight: 300),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      padding: const EdgeInsets.all(28),
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

              return Material(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(14),
                child: InkWell(
                  onTap: (isDone && item.jobId != null)
                      ? () => _openResultPage(item.jobId!, item.filename)
                      : null,
                  borderRadius: BorderRadius.circular(14),
                  child: Container(
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
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final bool isCompact = constraints.maxWidth < 480;

                        final fileInfoWidget = Row(
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
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    item.totalPages > 0
                                        ? 'Page ${item.currentPage} of ${item.totalPages} • Converted'
                                        : item.status,
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: isDone
                                          ? Colors.green.shade700
                                          : colorScheme.onSurfaceVariant,
                                      fontWeight: isDone ? FontWeight.w600 : FontWeight.normal,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (isCompact && isDone)
                              Icon(Icons.check_circle, color: Colors.green.shade600, size: 20),
                          ],
                        );

                        if (!isDone || item.jobId == null) {
                          return Row(
                            children: [
                              Expanded(child: fileInfoWidget),
                              const SizedBox(width: 12),
                              if (isErr)
                                Icon(Icons.error_outline, color: colorScheme.error)
                              else
                                const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(strokeWidth: 2.5),
                                ),
                            ],
                          );
                        }

                        // Completed Item Actions: View, Download PDF, More Formats
                        final actionsWidget = Wrap(
                          spacing: 8,
                          runSpacing: 6,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          alignment: WrapAlignment.end,
                          children: [
                            OutlinedButton.icon(
                              onPressed: () => _openResultPage(item.jobId!, item.filename),
                              icon: const Icon(Icons.visibility_outlined, size: 16),
                              label: const Text('View'),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                visualDensity: VisualDensity.compact,
                              ),
                            ),
                            FilledButton.icon(
                              onPressed: () => _downloadBatchItemFile(item.jobId!, item.filename, 'pdf'),
                              icon: const Icon(Icons.download_rounded, size: 16),
                              label: const Text('PDF'),
                              style: FilledButton.styleFrom(
                                backgroundColor: Colors.green.shade700,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                visualDensity: VisualDensity.compact,
                              ),
                            ),
                            PopupMenuButton<String>(
                              tooltip: 'More formats',
                              icon: Icon(Icons.more_vert, size: 18, color: colorScheme.onSurfaceVariant),
                              onSelected: (format) => _downloadBatchItemFile(item.jobId!, item.filename, format),
                              itemBuilder: (context) => [
                                const PopupMenuItem(
                                  value: 'txt',
                                  child: Row(
                                    children: [
                                      Icon(Icons.description_outlined, color: Colors.blueAccent, size: 18),
                                      SizedBox(width: 8),
                                      Text('Download .TXT'),
                                    ],
                                  ),
                                ),
                                const PopupMenuItem(
                                  value: 'md',
                                  child: Row(
                                    children: [
                                      Icon(Icons.code, color: Colors.purpleAccent, size: 18),
                                      SizedBox(width: 8),
                                      Text('Download .MD'),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        );

                        if (isCompact) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              fileInfoWidget,
                              const SizedBox(height: 10),
                              actionsWidget,
                            ],
                          );
                        } else {
                          return Row(
                            children: [
                              Expanded(child: fileInfoWidget),
                              const SizedBox(width: 12),
                              actionsWidget,
                            ],
                          );
                        }
                      },
                    ),
                  ),
                ),
              );
            },
          ),
          if (isAllDone) ...[
            const SizedBox(height: 28),
            Wrap(
              spacing: 16,
              runSpacing: 12,
              alignment: WrapAlignment.center,
              children: [
                if (completedCount > 0)
                  FilledButton.icon(
                    onPressed: _downloadAllCompletedAsZip,
                    icon: const Icon(Icons.archive_rounded, size: 20),
                    label: Text(
                      'Download All as ZIP ($completedCount Searchable ${completedCount == 1 ? "PDF" : "PDFs"})',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.green.shade700,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
                    ),
                  ),
                if (widget.onReset != null)
                  OutlinedButton.icon(
                    onPressed: widget.onReset,
                    icon: const Icon(Icons.refresh_rounded, size: 20),
                    label: const Text(
                      'Convert More Files',
                      style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                    ),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                    ),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class AnimatedHourglassIcon extends StatefulWidget {
  final Color color;
  final double size;

  const AnimatedHourglassIcon({
    super.key,
    required this.color,
    this.size = 56,
  });

  @override
  State<AnimatedHourglassIcon> createState() => _AnimatedHourglassIconState();
}

class _AnimatedHourglassIconState extends State<AnimatedHourglassIcon>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOutCubic,
    );
    _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RotationTransition(
      turns: _animation,
      child: Icon(
        Icons.hourglass_top_rounded,
        size: widget.size,
        color: widget.color,
      ),
    );
  }
}
