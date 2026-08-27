import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'theme/app_theme.dart';
import 'services/api_service.dart';
import 'widgets/hero_dropzone.dart';
import 'widgets/ocr_progress_view.dart';
import 'widgets/adsense_banner.dart';
import 'widgets/expired_link_view.dart';


import 'pages/result_page.dart';

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
      appBar: AppBar(
        title: const Text('freeOCR.me'),
        backgroundColor: colorScheme.surfaceContainer,
        centerTitle: true,
        actions: [
          IconButton(
            tooltip: isDark ? 'Switch to Light Theme' : 'Switch to Dark Theme',
            icon: Icon(
              isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
              color: colorScheme.onSurfaceVariant,
            ),
            onPressed: () {
              if (isDark) {
                themeNotifier.value = ThemeMode.light;
              } else {
                themeNotifier.value = ThemeMode.dark;
              }
            },
          ),
          if (kDebugMode)
            IconButton(
              tooltip: '[DEV] Toggle Expired Link UI Preview',
              icon: Icon(
                _showExpiredDevPreview ? Icons.timer_off : Icons.timer_off_outlined,
                color: _showExpiredDevPreview ? colorScheme.error : colorScheme.onSurfaceVariant,
              ),
              onPressed: () {
                setState(() {
                  _showExpiredDevPreview = !_showExpiredDevPreview;
                });
              },
            ),
        ],
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.document_scanner,
                  size: 56,
                  color: colorScheme.primary,
                ),
                const SizedBox(height: 12),
                Text(
                  'Scanned PDF to Searchable PDF/Text',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 6),
                Text(
                  '100% Free & Privacy Ephemeral • Zero Registration',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: colorScheme.tertiary,
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
      ),
    );
  }
}
