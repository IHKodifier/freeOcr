import 'package:flutter/material.dart';
import '../services/telemetry_service.dart';
import '../widgets/adsense_banner.dart';
import '../widgets/app_footer.dart';
import '../widgets/app_header.dart';
import '../main.dart' show themeNotifier;

/// Dedicated About Page (/about)
/// Built for Google AdSense compliance, transparency, and EEAT authority.
class AboutPage extends StatefulWidget {
  const AboutPage({super.key});

  @override
  State<AboutPage> createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {
  @override
  void initState() {
    super.initState();
    TelemetryService.trackPageView('/about', pageTitle: 'freeOCR.me — About Us');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppHeader(
        currentRoute: '/about',
        onThemeToggle: () {
          themeNotifier.value = isDark ? ThemeMode.light : ThemeMode.dark;
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
                    // Header Badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFF6366F1).withOpacity(0.12),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0xFF6366F1).withOpacity(0.3)),
                      ),
                      child: const Text(
                        'ABOUT FREEOCR.ME',
                        style: TextStyle(
                          color: Color(0xFF6366F1),
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Democratizing Document OCR with Zero-Storage Privacy',
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'freeOCR.me is a high-performance web utility converting scanned documents into searchable PDFs and clean digital text without accounts, paywalls, or privacy trade-offs.',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 20),
                    const AdSenseBanner(),
                    const SizedBox(height: 28),

                    // Section 1: Our Mission
                    _buildCard(
                      context,
                      title: '1. Our Mission & Philosophy',
                      icon: Icons.lightbulb_outline_rounded,
                      body: 'Traditional online OCR tools typically lock users behind steep monthly subscriptions, place arbitrary 5-page conversion limits, or compromise document privacy by retaining uploaded files on server disks.\n\n'
                          'freeOCR.me was conceived with a single guiding principle: document accessibility tools should be accessible to everyone, everywhere, without compromising data confidentiality. We offer a generous 100 MB base upload limit that can be extended up to 1 GB completely free.',
                    ),
                    const SizedBox(height: 16),

                    // Section 2: Ephemeral Architecture
                    _buildCard(
                      context,
                      title: '2. Ephemeral RAM-Disk Security (Zero Retention)',
                      icon: Icons.security_rounded,
                      body: 'Privacy is not an afterthought at freeOCR.me — it is the foundation of our engineering architecture:\n\n'
                          '• Volatile Memory Processing: All uploaded PDFs and images are processed inside Linux tmpfs RAM disks rather than persistent hard drives.\n'
                          '• Instant Ephemeral Cleanup: As soon as your OCR conversion completes and you download the result, files are purged immediately.\n'
                          '• Zero User Accounts: We do not require registration, passwords, or personal email addresses to use the core utility.',
                    ),
                    const SizedBox(height: 16),

                    // Section 3: Open-Source Engines
                    _buildCard(
                      context,
                      title: '3. Open-Source AI Engines',
                      icon: Icons.hub_rounded,
                      body: 'We stand on the shoulders of giants. freeOCR.me is powered by leading open-source machine learning and document processing technologies:\n\n'
                          '• Baidu Unlimited OCR (PaddleOCR): Industrial-grade deep learning model delivering exceptional recognition accuracy across multilingual and complex document layouts.\n'
                          '• OCRmyPDF: The gold standard in PDF remastering, generating ISO-compliant searchable PDF/A documents with invisible text overlays.\n'
                          '• Tesseract OCR: The battle-tested optical character recognition engine maintained by Google and open-source contributors.\n'
                          '• PyMuPDF: Ultra-fast PDF rendering and geometry parsing.',
                    ),
                    const SizedBox(height: 16),

                    // Section 4: Transparent Monetization
                    _buildCard(
                      context,
                      title: '4. Transparent Monetization & Sustainability',
                      icon: Icons.monetization_on_outlined,
                      body: 'To keep freeOCR.me permanently free for users around the globe without charging subscription fees or selling user data, we sustain our server infrastructure through:\n\n'
                          '1. Google AdSense: Minimal, non-intrusive display advertisements placed in designated non-obstructive page sections.\n'
                          '2. Rewarded Extensions: Users processing exceptionally large documents can watch a brief 15-second video sponsor ad to earn +50 MB extra capacity up to 1,000 MB (1 GB).',
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 40),
            const AppFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required String body,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF111827) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.white.withOpacity(0.08) : const Color(0xFFE2E8F0),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: const Color(0xFF6366F1), size: 22),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            body,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}
