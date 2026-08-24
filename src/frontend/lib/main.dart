import 'package:flutter/material.dart';
import 'theme/app_theme.dart';
import 'services/api_service.dart';
import 'widgets/hero_dropzone.dart';
import 'widgets/ocr_progress_view.dart';

void main() {
  runApp(const FreeOcrApp());
}

class FreeOcrApp extends StatelessWidget {
  const FreeOcrApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'freeOCR.me',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      home: const HomePage(),
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

  void _onUploadSuccess(String jobId, String filename, int sizeInBytes) {
    setState(() {
      _activeJobId = jobId;
      _activeFilename = filename;
      _activeFileSize = sizeInBytes;
      _batchItems = [];
    });
  }

  void _onBatchUploadSuccess(List<BatchFileItem> items) {
    setState(() {
      _batchItems = items;
      _activeJobId = null;
      _activeFilename = null;
      _activeFileSize = null;
    });
  }

  void _resetConversion() {
    setState(() {
      _activeJobId = null;
      _activeFilename = null;
      _activeFileSize = null;
      _batchItems = [];
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final bool hasActiveItems = _activeJobId != null || _batchItems.isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        title: const Text('freeOCR.me'),
        backgroundColor: colorScheme.surfaceContainer,
        centerTitle: true,
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
                const SizedBox(height: 24),
                if (!hasActiveItems)
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
