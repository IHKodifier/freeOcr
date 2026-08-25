import 'package:flutter/material.dart';

/// ExpiredLinkView widget displayed when a download link has expired (HTTP 410 Gone).
/// Formats expiration timestamp into the user's detected local timezone.
class ExpiredLinkView extends StatelessWidget {
  final DateTime? expiredAt;
  final String? rawExpiredAtString;
  final VoidCallback? onUploadNew;

  const ExpiredLinkView({
    super.key,
    this.expiredAt,
    this.rawExpiredAtString,
    this.onUploadNew,
  });

  String _formatLocalExpirationTime() {
    DateTime? dt = expiredAt;
    if (dt == null && rawExpiredAtString != null && rawExpiredAtString!.isNotEmpty) {
      try {
        dt = DateTime.parse(rawExpiredAtString!);
      } catch (_) {}
    }

    if (dt == null) {
      return "24 hours after job creation";
    }

    final localDt = dt.toLocal();
    final year = localDt.year;
    final month = localDt.month.toString().padLeft(2, '0');
    final day = localDt.day.toString().padLeft(2, '0');
    final hour = localDt.hour.toString().padLeft(2, '0');
    final minute = localDt.minute.toString().padLeft(2, '0');
    final second = localDt.second.toString().padLeft(2, '0');
    final timeZoneName = localDt.timeZoneName;

    return "$year-$month-$day $hour:$minute:$second ($timeZoneName)";
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final localTimeStr = _formatLocalExpirationTime();

    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(maxWidth: 640),
      margin: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: colorScheme.error.withOpacity(0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colorScheme.errorContainer,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.timer_off_rounded,
              size: 48,
              color: colorScheme.error,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Download Link Expired',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            'This download link expired on $localTimeStr. Output files are purged after 24h for privacy.',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: colorScheme.onSurfaceVariant,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 28),
          ElevatedButton.icon(
            key: const Key('upload_new_document_button'),
            onPressed: onUploadNew,
            icon: const Icon(Icons.upload_file),
            label: const Text('Upload New Document'),
            style: ElevatedButton.styleFrom(
              backgroundColor: colorScheme.primary,
              foregroundColor: colorScheme.onPrimary,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 2,
            ),
          ),
        ],
      ),
    );
  }
}
