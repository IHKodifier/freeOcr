import 'package:flutter/material.dart';
import '../utils/url_helper.dart';

/// Centralized configuration and safe launcher for freeOCR.me official social channels and contact endpoints.
/// Guarantees zero 404 navigation errors for search engine crawlers and AdSense reviewers.
class SocialLinks {
  // Configured target URLs. Leave empty or set to active handle once claimed.
  // Intended handles:
  // Twitter/X: https://x.com/freeocrme (CLAIMED & LIVE)
  // Instagram: https://instagram.com/freeocrme (CLAIMED & LIVE)
  // Facebook:  https://facebook.com/freeocrme
  // YouTube:   https://youtube.com/@freeocrme
  static const String twitterUrl = 'https://x.com/freeocrme';
  static const String instagramUrl = 'https://instagram.com/freeocrme';
  static const String facebookUrl = 'https://facebook.com/freeOCRme';
  static const String youtubeUrl = '';

  // Support and privacy communication channels
  static const String supportEmail = 'support@freeocr.me';
  static const String privacyEmail = 'privacy@freeocr.me';

  // Open-source engine attribution URLs
  static const String baiduOcrUrl = 'https://github.com/PaddlePaddle/PaddleOCR';
  static const String ocrmypdfUrl = 'https://github.com/ocrmypdf/OCRmyPDF';
  static const String tesseractUrl =
      'https://github.com/tesseract-ocr/tesseract';
  static const String pymupdfUrl = 'https://github.com/pymupdf/PyMuPDF';
  static const String githubRepoUrl = 'https://github.com/IHKodifier/freeOcr';

  /// Safely open a social channel or present an informational dialog if the handle is in launch phase.
  static void openSocialChannel(
    BuildContext context, {
    required String platformName,
    required String? url,
  }) {
    if (url != null && url.isNotEmpty && !url.contains('#')) {
      UrlHelper.openUrl(url);
      return;
    }

    // Graceful fallback dialog to prevent 404s
    showDialog(
      context: context,
      builder: (ctx) {
        final theme = Theme.of(ctx);
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              const Icon(
                Icons.campaign_rounded,
                color: Color(0xFF6366F1),
                size: 24,
              ),
              const SizedBox(width: 10),
              Text(
                '$platformName Channel',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ],
          ),
          content: Text(
            'Our official $platformName presence is launching soon! For announcements, updates, or direct assistance, reach our team at $supportEmail.',
            style: theme.textTheme.bodyMedium?.copyWith(height: 1.5),
          ),
          actions: [
            TextButton(
              style: TextButton.styleFrom(
                foregroundColor: theme.colorScheme.onSurfaceVariant,
              ),
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Close'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: theme.colorScheme.onPrimary,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 11,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 0,
              ),
              onPressed: () {
                Navigator.of(ctx).pop();
                Navigator.of(context).pushNamed('/contact');
              },
              child: const Text(
                'Contact Support',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        );
      },
    );
  }
}
