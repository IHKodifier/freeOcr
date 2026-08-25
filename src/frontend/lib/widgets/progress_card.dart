import 'package:flutter/material.dart';

class ProgressCard extends StatelessWidget {
  final String jobId;
  final String status;
  final int currentPage;
  final int totalPages;
  final String? outputPdfToken;
  final String? errorMessage;
  final VoidCallback? onDownload;

  const ProgressCard({
    super.key,
    required this.jobId,
    required this.status,
    required this.currentPage,
    required this.totalPages,
    this.outputPdfToken,
    this.errorMessage,
    this.onDownload,
  });

  double get _progressPercentage {
    if (status == 'COMPLETED') return 1.0;
    if (totalPages <= 0) return 0.0;
    final p = currentPage / totalPages;
    return p.clamp(0.0, 1.0);
  }

  Color _getStatusColor(BuildContext context) {
    switch (status.toUpperCase()) {
      case 'COMPLETED':
        return Colors.green;
      case 'PROCESSING':
        return Colors.blue;
      case 'FAILED':
        return Colors.red;
      case 'QUEUED':
      default:
        return Colors.amber.shade700;
    }
  }

  IconData _getStatusIcon() {
    switch (status.toUpperCase()) {
      case 'COMPLETED':
        return Icons.check_circle_rounded;
      case 'PROCESSING':
        return Icons.autorenew_rounded;
      case 'FAILED':
        return Icons.error_rounded;
      case 'QUEUED':
      default:
        return Icons.hourglass_top_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor(context);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: statusColor.withAlpha(80),
          width: 1.5,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Chip(
                  avatar: Icon(
                    _getStatusIcon(),
                    size: 16,
                    color: statusColor,
                  ),
                  label: Text(
                    status.toUpperCase(),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: statusColor,
                      fontSize: 12,
                    ),
                  ),
                  backgroundColor: statusColor.withAlpha(25),
                  side: BorderSide.none,
                  visualDensity: VisualDensity.compact,
                ),
                if (status.toUpperCase() == 'PROCESSING' && totalPages > 0)
                  Text(
                    'Page $currentPage of $totalPages',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade700,
                        ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            if (status.toUpperCase() == 'QUEUED')
              Text(
                'Preparing document for OCR processing...',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey.shade600,
                    ),
              )
            else if (status.toUpperCase() == 'COMPLETED')
              Text(
                'Conversion Complete!',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.green.shade800,
                    ),
              )
            else if (status.toUpperCase() == 'FAILED')
              Text(
                errorMessage ?? 'An error occurred during OCR conversion.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.red.shade700,
                    ),
              )
            else
              Text(
                'Running Baidu Unlimited OCR AI engine page-by-page...',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey.shade600,
                    ),
              ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: status.toUpperCase() == 'QUEUED'
                    ? null
                    : _progressPercentage,
                minHeight: 8,
                backgroundColor: Colors.grey.shade200,
                color: statusColor,
              ),
            ),
            if (status.toUpperCase() == 'COMPLETED') ...[
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: onDownload,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.shade700,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: const Icon(Icons.download_rounded),
                  label: const Text(
                    'Download Searchable PDF',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
