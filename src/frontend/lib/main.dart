import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'theme/app_theme.dart';
import 'services/api_service.dart';
import 'services/telemetry_service.dart';
import 'widgets/hero_dropzone.dart';
import 'widgets/ocr_progress_view.dart';
import 'widgets/adsense_banner.dart';
import 'widgets/expired_link_view.dart';
import 'widgets/app_header.dart';
import 'widgets/app_footer.dart';

import 'pages/result_page.dart';
import 'pages/kb_page.dart';
import 'pages/docs_page.dart';
import 'pages/privacy_page.dart';
import 'pages/terms_page.dart';

final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier<ThemeMode>(ThemeMode.light);

void main() {
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
          title: 'freeOCR.me',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: currentMode,
          onGenerateRoute: (settings) {
            final name = settings.name;
            if (name != null && name.startsWith('/result/')) {
              final jobId = name.replaceFirst('/result/', '');
              return MaterialPageRoute(
                builder: (context) => ResultPage(jobId: jobId),
                settings: settings,
              );
            }
            if (name != null && (name == '/kb' || name.startsWith('/kb/'))) {
              final slug = name == '/kb' ? null : name.replaceFirst('/kb/', '');
              return MaterialPageRoute(
                builder: (context) => KbPage(initialArticleSlug: slug),
                settings: settings,
              );
            }
            if (name == '/docs') {
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
  String? _activeJobId;
  String? _activeFilename;
  int? _activeFileSize;
  List<BatchFileItem> _batchItems = [];
  bool _showExpiredDevPreview = false;

  @override
  void initState() {
    super.initState();
    ApiService.prewarmBackend();
    TelemetryService.trackPageView('/', pageTitle: 'freeOCR.me — Home');
  }

  void _onUploadSuccess(String jobId, String filename, int sizeInBytes) {
    setState(() {
      _activeJobId = jobId;
      _activeFilename = filename;
      _activeFileSize = sizeInBytes;
      _batchItems = [];
      _showExpiredDevPreview = false;
    });
  }

  void _onBatchUploadSuccess(List<BatchFileItem> items) {
    setState(() {
      _batchItems = items;
      _activeJobId = null;
      _activeFilename = null;
      _activeFileSize = null;
      _showExpiredDevPreview = false;
    });
  }

  void _resetConversion() {
    setState(() {
      _activeJobId = null;
      _activeFilename = null;
      _activeFileSize = null;
      _batchItems = [];
      _showExpiredDevPreview = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final bool hasActiveItems = _activeJobId != null || _batchItems.isNotEmpty;
    final bool isDark = theme.brightness == Brightness.dark;

    return Scaffold(
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
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 32.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Top Pill Badge with Pulse Indicator
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
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
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '100% Free & Privacy Ephemeral • Zero Registration',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: isDark ? const Color(0xFFA5B4FC) : const Color(0xFF4338CA),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        style: TextStyle(
                          fontSize: 42,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -1.0,
                          color: theme.colorScheme.onSurface,
                          fontFamily: 'Inter',
                          height: 1.1,
                        ),
                        children: const [
                          TextSpan(text: 'Extract Text with '),
                          TextSpan(
                            text: 'Precision',
                            style: TextStyle(color: Color(0xFF6366F1)),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 620),
                      child: Text(
                        'Secure, fast, and highly accurate optical character recognition powered by advanced neural engines. Files are never stored.',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                          height: 1.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const AdSenseBanner(),
                    const SizedBox(height: 16),
                    if (kDebugMode && _showExpiredDevPreview)
                      ExpiredLinkView(
                        expiredAt: DateTime.now().subtract(const Duration(hours: 25)),
                        onUploadNew: _resetConversion,
                      )
                    else if (!hasActiveItems)
                      HeroDropzone(
                        onUploadSuccess: _onUploadSuccess,
                        onBatchUploadSuccess: _onBatchUploadSuccess,
                      )
                    else
                      OcrProgressView(
                        jobId: _activeJobId,
                        filename: _activeFilename,
                        fileSize: _activeFileSize,
                        batchItems: _batchItems.isNotEmpty ? _batchItems : null,
                        onReset: _resetConversion,
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
