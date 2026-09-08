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
                      title: '1. Our Founding Mission & Philosophy',
                      icon: Icons.lightbulb_outline_rounded,
                      body: 'The modern digital landscape is littered with utility websites that promise "free online OCR" only to bait-and-switch visitors behind aggressive paywalls. Users frequently encounter arbitrary 3-page conversion limits, coercive \$15–\$30 monthly subscriptions, intrusive watermarks stamped across output pages, or opaque terms that grant platforms broad rights to inspect, retain, or monetize uploaded private paperwork.\n\n'
                          'freeOCR.me was conceived with a fundamentally different ethos: document accessibility is an essential utility of the information age and must remain universally accessible to everyone, everywhere, without financial friction or privacy compromise. Whether you are a student archiving historical library scans, an independent researcher digitizing out-of-print books, a legal assistant searching through trial discovery records, or an everyday consumer trying to read a faded medical receipt, you deserve an industrial-strength conversion engine that respects your time, your wallet, and your confidentiality.\n\n'
                          'We made a permanent, non-negotiable architectural commitment from day one: freeOCR.me is completely free to use. There are no credit card prompts, no trial subscriptions that silently bill you, no locked enterprise features, and no mandatory account creation. Every visitor instantly receives a 100 MB per-file upload allowance, stackable up to 1,000 MB (1 GB) for heavy multi-hundred-page archives.',
                    ),
                    const SizedBox(height: 16),

                    // Section 2: Open-Source Engines
                    _buildCard(
                      context,
                      title: '2. Transparent Technology Stack Attribution & Neural Engineering',
                      icon: Icons.hub_rounded,
                      body: 'Rather than disguising established open algorithms behind proprietary marketing buzzwords, freeOCR.me proudly attributes and builds upon the extraordinary open-source software and machine learning communities. Our multi-stage pipeline integrates state-of-the-art neural networks, computer vision algorithms, and PDF remastering engines:\n\n'
                          '• Baidu Unlimited OCR (PaddleOCR): A massive ~6 GB deep neural vision architecture that represents the frontier of open optical character recognition. Unlike legacy pattern-matching engines, Baidu Unlimited OCR excels at multi-column newspaper layouts, complex mathematical formulas rendered in TeX syntax, rotated text lines, dense financial tables, and multilingual character sets including Chinese, Japanese, Korean, Arabic, and Latin scripts.\n\n'
                          '• OCRmyPDF: The gold standard in PDF remastering, developed and maintained by open-source contributors worldwide. OCRmyPDF intelligently inspects incoming PDF streams, applies lossless image optimization, corrects page skew, and synthesizes invisible text layers adhering to ISO 32000-1 and PDF/A archiving standards.\n\n'
                          '• Tesseract OCR: Maintained by Google and the global open-source community, Tesseract provides battle-tested, lightning-fast character recognition for standard linear documents, letters, contracts, and single-column text.\n\n'
                          '• PyMuPDF & Artifex MuPDF Core: High-performance C-based rendering and PDF manipulation library enabling sub-second document vectorization, automated DPI upscaling to 300 DPI, and client-side password decryption without writing decrypted files to disk.\n\n'
                          '• FastAPI & Modern Python Asynchronous Core: Our backend microservices are orchestrated with FastAPI and Python 3.13, delivering sub-millisecond routing, strict Pydantic schema validation, and real-time Server-Sent Events (SSE) streaming for page-by-page OCR progress.',
                    ),
                    const SizedBox(height: 16),

                    // Section 3: Transparent Monetization
                    _buildCard(
                      context,
                      title: '3. Transparent Monetization & Infrastructure Sustainability',
                      icon: Icons.monetization_on_outlined,
                      body: 'Running industrial-grade AI models on dedicated GPU clusters and high-core CPU servers incurs significant continuous computing, bandwidth, and electrical costs. How does freeOCR.me maintain a high-performance infrastructure without selling user data or charging subscriptions? The answer lies in radical economic transparency:\n\n'
                          '1. Contextual Display Advertising (Google AdSense & Google Ad Manager): We display non-obstructive, privacy-compliant advertisements positioned cleanly outside the document interaction flow. These ads generate baseline revenue to cover routine cloud compute and server uptime.\n\n'
                          '2. Rewarded Video Extensions (User-Driven Compute Offsetting): For users processing extraordinarily heavy files—such as scanned books or court dockets spanning hundreds of megabytes—we introduced voluntary 15-second rewarded video ads. Watching a brief sponsor message directly offsets the exact GPU compute expenditure needed to perform neural inference across your pages, rewarding you with +50 MB of additional upload capacity per ad up to a huge 1,024 MB (1 GB).\n\n'
                          '3. Zero Data Monetization: We never sell telemetry, we never share document contents with third-party data brokers, and we never use your uploaded files to train commercial machine learning models. User attention directly sustains user compute.',
                    ),
                    const SizedBox(height: 16),

                    // Section 4: Ephemeral RAM-Disk Security
                    _buildCard(
                      context,
                      title: '4. Kernel-Level Ephemeral RAM-Disk Security Guarantee',
                      icon: Icons.security_rounded,
                      body: 'In traditional cloud document processing architectures, uploaded files are written to persistent solid-state drives (SSDs) or cloud storage buckets (e.g., AWS S3 or Google Cloud Storage), where remnants and metadata can persist across filesystem journals, backups, and snapshot volumes for months or years. At freeOCR.me, user confidentiality is enforced at the operating system kernel level:\n\n'
                          '• Linux tmpfs Volatile Memory Execution: All uploaded files, intermediate page bitmaps, deskewed buffers, and OCR artifacts exist exclusively in Linux tmpfs RAM disk mounts. Bytes are written only to volatile DRAM chips. At no point does your document ever touch persistent storage or non-volatile physical disk platters.\n\n'
                          '• Instant Automated Unlink Protocols: The moment your OCR conversion finishes and your output PDF, TXT, or Markdown stream is generated, an automated file unlinking protocol executes immediately. Ephemeral file pointers are severed, and memory allocations are returned to the kernel.\n\n'
                          '• Autonomous Janitor & Watchdog Daemon: A continuous background watchdog process monitors the RAM disk mount. Any orphaned session older than 60 minutes is forcefully unlinked, preventing memory leakage and guaranteeing that no orphaned document ever lingers.\n\n'
                          '• Zero Account & Zero Tracking Footprint: We do not ask for your name, email address, password, or payment information. We set no profiling cookies and maintain zero database records connecting your identity to the documents you convert.',
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
