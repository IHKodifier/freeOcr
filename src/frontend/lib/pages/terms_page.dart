import 'package:flutter/material.dart';
import '../services/telemetry_service.dart';
import '../widgets/adsense_banner.dart';
import '../widgets/app_footer.dart';
import '../widgets/app_header.dart';
import '../main.dart' show themeNotifier;

/// Terms of Service Page (/terms)
class TermsPage extends StatefulWidget {
  const TermsPage({super.key});

  @override
  State<TermsPage> createState() => _TermsPageState();
}

class _TermsPageState extends State<TermsPage> {
  @override
  void initState() {
    super.initState();
    TelemetryService.trackPageView('/terms', pageTitle: 'freeOCR.me — Terms of Service');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppHeader(
        currentRoute: '/terms',
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
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 900),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Terms of Service', style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text('Last Updated: August 30, 2026', style: theme.textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant)),
                    const SizedBox(height: 16),
                    const AdSenseBanner(),
                    const SizedBox(height: 20),

                    _buildSection(
                      context,
                      title: '1. Acceptable Use Policy',
                      body: 'freeOCR.me is provided as a free, open-source online document processing utility. You agree to use the service only for lawful document OCR conversion purposes. Uploading malware, illegal content, or attempting to overload system APIs via automated denial-of-service is strictly prohibited.',
                    ),
                    _buildSection(
                      context,
                      title: '2. Service Limits & Ad Boost Passes',
                      body: 'Standard uploads are limited to 50MB per file. Users may extend session limits up to 500MB by engaging with rewarded video advertisements. We reserve the right to apply automated IP rate limiting to maintain server stability.',
                    ),
                    _buildSection(
                      context,
                      title: '3. Disclaimer of Warranties & Limitation of Liability',
                      body: 'freeOCR.me is provided "AS IS" and "AS AVAILABLE" without warranties of any kind. In no event shall the authors, maintainers, or open-source contributors be liable for any data loss, conversion inaccuracies, or service interruptions.',
                    ),
                    _buildSection(
                      context,
                      title: '4. Open Source & Engine Attribution',
                      body: 'freeOCR.me integrates upstream open-source software libraries and AI models under GPL-3.0, AGPL, and Apache-2.0 licenses, including Baidu\'s Unlimited OCR AI Model, OCRmyPDF, Tesseract OCR, and PyMuPDF.',
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

  Widget _buildSection(BuildContext context, {required String title, required String body}) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          Text(body, style: theme.textTheme.bodyMedium?.copyWith(height: 1.5, color: colorScheme.onSurface)),
        ],
      ),
    );
  }
}
