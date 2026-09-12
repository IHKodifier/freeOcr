import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'theme/app_theme.dart';
import 'services/api_service.dart';
import 'services/telemetry_service.dart';
import 'services/host_resolver.dart';
import 'widgets/hero_dropzone.dart';
import 'widgets/adsense_banner.dart';
import 'widgets/app_header.dart';
import 'widgets/app_footer.dart';
import 'widgets/landing_faq_section.dart';
import 'widgets/hero_scanner_showcase.dart';

import 'pages/process_page.dart';
import 'pages/result_page.dart';
import 'pages/kb_page.dart';
import 'pages/docs_page.dart';
import 'pages/privacy_page.dart';
import 'pages/terms_page.dart';
import 'pages/about_page.dart';
import 'pages/contact_page.dart';
import 'pages/pdf_tools_hub_page.dart';
import 'pages/tool_placeholder_page.dart';
import 'utils/url_strategy_helper.dart';
import 'utils/theme_storage_helper.dart';

final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier<ThemeMode>(ThemeStorageHelper.loadTheme());

void main() {
  configureAppUrlStrategy();
  themeNotifier.addListener(() {
    ThemeStorageHelper.saveTheme(themeNotifier.value);
  });
  runApp(const FreeOcrApp());
}

class FreeOcrApp extends StatelessWidget {
  const FreeOcrApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (context, currentMode, _) {
        return MaterialApp(
          title: HostResolver.getBrandTitle(),
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: currentMode,
          builder: (context, child) {
            return Overlay(
              initialEntries: [
                OverlayEntry(
                  builder: (context) => SelectionArea(
                    child: child ?? const SizedBox.shrink(),
                  ),
                ),
              ],
            );
          },
          onGenerateRoute: (settings) {
            final name = settings.name;

            // FreePDFToolz Hub route
            if (name == '/hub') {
              return MaterialPageRoute(
                builder: (context) => const PdfToolsHubPage(),
                settings: settings,
              );
            }

            // Dedicated OCR route
            if (name == '/ocr') {
              return MaterialPageRoute(
                builder: (context) => const HomePage(),
                settings: settings,
              );
            }

            // Specific PDF tools route matching
            if (name != null && name.startsWith('/')) {
              for (final tool in kPdfToolsCatalog) {
                if (tool.route == name && tool.id != 'ocr') {
                  return MaterialPageRoute(
                    builder: (context) => ToolPlaceholderPage(
                      toolId: tool.id,
                      toolTitle: tool.name,
                      description: tool.description,
                      icon: tool.icon,
                    ),
                    settings: settings,
                  );
                }
              }
            }

            if (name != null && (name == '/process' || name.startsWith('/process/'))) {
              final jobId = name.startsWith('/process/') ? name.replaceFirst('/process/', '') : null;
              final args = settings.arguments;
              String? filename;
              int? fileSize;
              Uint8List? bytes;
              String? layoutComplexity;
              bool coldStartActive = false;
              List<BatchFileItem>? batchItems;

              if (args is Map<String, dynamic>) {
                filename = args['filename'] as String?;
                fileSize = args['fileSize'] as int?;
                bytes = args['bytes'] as Uint8List?;
                layoutComplexity = args['layoutComplexity'] as String?;
                coldStartActive = args['coldStartActive'] as bool? ?? false;
                batchItems = args['batchItems'] as List<BatchFileItem>?;
              }

              return MaterialPageRoute(
                builder: (context) => ProcessPage(
                  jobId: jobId,
                  filename: filename,
                  fileSize: fileSize,
                  bytes: bytes,
                  layoutComplexity: layoutComplexity,
                  coldStartActive: coldStartActive,
                  batchItems: batchItems,
                ),
                settings: settings,
              );
            }
            if (name != null && name.startsWith('/result/')) {
              final jobId = name.replaceFirst('/result/', '');
              return MaterialPageRoute(
                builder: (context) => ResultPage(jobId: jobId),
                settings: settings,
              );
            }
            if (name != null && (name == '/kb' || name == '/knowledge-base' || name.startsWith('/kb/') || name.startsWith('/knowledge-base/'))) {
              final slug = (name == '/kb' || name == '/knowledge-base')
                  ? null
                  : (name.startsWith('/kb/')
                      ? name.replaceFirst('/kb/', '')
                      : name.replaceFirst('/knowledge-base/', ''));
              return MaterialPageRoute(
                builder: (context) => KbPage(initialArticleSlug: slug),
                settings: settings,
              );
            }
            if (name == '/docs' || name == '/api-docs') {
              return MaterialPageRoute(
                builder: (context) => const DocsPage(),
                settings: settings,
              );
            }
            if (name == '/privacy') {
              return MaterialPageRoute(
                builder: (context) => const PrivacyPage(),
                settings: settings,
              );
            }
            if (name == '/terms') {
              return MaterialPageRoute(
                builder: (context) => const TermsPage(),
                settings: settings,
              );
            }
            if (name == '/about') {
              return MaterialPageRoute(
                builder: (context) => const AboutPage(),
                settings: settings,
              );
            }
            if (name == '/contact') {
              return MaterialPageRoute(
                builder: (context) => const ContactPage(),
                settings: settings,
              );
            }

            // Root route '/': host-aware fallback
            if (HostResolver.isFreePdfToolsDomain()) {
              return MaterialPageRoute(
                builder: (context) => const PdfToolsHubPage(),
                settings: settings,
              );
            }

            return MaterialPageRoute(
              builder: (context) => const HomePage(),
              settings: settings,
            );
          },
        );
      },
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    ApiService.prewarmBackend();
    TelemetryService.trackPageView('/', pageTitle: 'freeOCR.me — Home');
  }

  void _onUploadSuccess(String jobId, String filename, int sizeInBytes, {String? layoutComplexity, bool coldStartActive = false}) {
    Navigator.pushNamed(
      context,
      '/process/$jobId',
      arguments: {
        'filename': filename,
        'fileSize': sizeInBytes,
        'layoutComplexity': layoutComplexity,
        'coldStartActive': coldStartActive,
      },
    );
  }

  void _onBatchUploadSuccess(List<BatchFileItem> items) {
    if (items.isEmpty) return;
    final primaryJobId = items.first.jobId ?? 'batch';
    Navigator.pushNamed(
      context,
      '/process/$primaryJobId',
      arguments: {
        'batchItems': items,
        'filename': items.first.filename,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppHeader(
        currentRoute: '/',
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
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final bool isDesktop = constraints.maxWidth >= 992;
                    if (isDesktop) {
                      return ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 1200),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const AdSenseBanner(),
                            const SizedBox(height: 14),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Left Column (flex 7)
                                Expanded(
                                  flex: 7,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      _buildPulseBadge(isDark),
                                      const SizedBox(height: 8),
                                      _buildHeadline(theme, textAlign: TextAlign.left),
                                      const SizedBox(height: 6),
                                      _buildSubtitle(theme, textAlign: TextAlign.left),
                                      const SizedBox(height: 12),
                                      HeroDropzone(
                                        onUploadSuccess: _onUploadSuccess,
                                        onBatchUploadSuccess: _onBatchUploadSuccess,
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 28),
                                // Right Column (flex 5)
                                const Expanded(
                                  flex: 5,
                                  child: HeroScannerShowcase(),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    } else {
                      return ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 640),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const AdSenseBanner(),
                            const SizedBox(height: 12),
                            _buildPulseBadge(isDark),
                            const SizedBox(height: 8),
                            _buildHeadline(theme, textAlign: TextAlign.center, fontSize: 32),
                            const SizedBox(height: 6),
                            _buildSubtitle(theme, textAlign: TextAlign.center),
                            const SizedBox(height: 12),
                            HeroDropzone(
                              onUploadSuccess: _onUploadSuccess,
                              onBatchUploadSuccess: _onBatchUploadSuccess,
                            ),
                            const SizedBox(height: 20),
                            const HeroScannerShowcase(),
                          ],
                        ),
                      );
                    }
                  },
                ),
              ),
            ),
            const LandingFaqSection(),
            const SizedBox(height: 32),
            const AppFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildPulseBadge(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF6366F1).withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFF6366F1).withOpacity(0.25),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: Color(0xFF10B981),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Color(0x6610B981),
                  blurRadius: 4,
                  spreadRadius: 1,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              '100% Free • Zero File Retention • No Registration',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isDark ? const Color(0xFFA5B4FC) : const Color(0xFF4338CA),
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeadline(ThemeData theme, {TextAlign textAlign = TextAlign.left, double fontSize = 40}) {
    return RichText(
      textAlign: textAlign,
      text: TextSpan(
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.w800,
          letterSpacing: -1.0,
          color: theme.colorScheme.onSurface,
          fontFamily: 'Inter',
          height: 1.15,
        ),
        children: const [
          TextSpan(text: 'Extract Text with '),
          TextSpan(
            text: 'Precision',
            style: TextStyle(color: Color(0xFF6366F1)),
          ),
        ],
      ),
    );
  }

  Widget _buildSubtitle(ThemeData theme, {TextAlign textAlign = TextAlign.left}) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 600),
      child: Text(
        'Secure, fast, and highly accurate optical character recognition powered by advanced neural engines. Files are processed in memory and never stored.',
        style: theme.textTheme.bodyLarge?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
          height: 1.5,
        ),
        textAlign: textAlign,
      ),
    );
  }
}
