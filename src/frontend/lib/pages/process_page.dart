import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../services/telemetry_service.dart';
import '../widgets/adsense_banner.dart';
import '../widgets/app_header.dart';
import '../widgets/app_footer.dart';
import '../widgets/ocr_progress_view.dart';
import '../main.dart' show themeNotifier;

/// Dedicated Route Page for Upload & OCR Processing (/process or /process/{job_id})
/// Compliant with Google AdSense and Google Ad Manager (GAM) policies:
/// - Direct user-gesture route transition upon drop/selection.
/// - Hero Section (Top, above the fold): Live upload & OCR progress view.
/// - Compact height ensuring both Progress Card & AdSense Banner fit above the fold.
/// - Supplementary Section (Underneath): 1 GAM-ready compliant ad banner.
class ProcessPage extends StatefulWidget {
  final String? jobId;
  final String? filename;
  final int? fileSize;
  final Uint8List? bytes;
  final String? layoutComplexity;
  final bool coldStartActive;
  final List<BatchFileItem>? batchItems;
  final String? password;

  const ProcessPage({
    super.key,
    this.jobId,
    this.filename,
    this.fileSize,
    this.bytes,
    this.layoutComplexity,
    this.coldStartActive = false,
    this.batchItems,
    this.password,
  });

  @override
  State<ProcessPage> createState() => _ProcessPageState();
}

class _ProcessPageState extends State<ProcessPage> {
  String? _jobId;
  late String _status;
  int _uploadSentBytes = 0;
  int _uploadTotalBytes = 0;
  String? _layoutComplexity;
  late bool _coldStartActive;
  String? _errorMessage;
  List<BatchFileItem> _batchItems = [];

  bool _isPasswordRequired = false;
  bool _isUnlocking = false;
  String? _passwordError;
  final TextEditingController _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _jobId = widget.jobId;
    _layoutComplexity = widget.layoutComplexity;
    _coldStartActive = widget.coldStartActive;
    _batchItems = widget.batchItems != null ? List.from(widget.batchItems!) : [];

    if (_jobId != null && _jobId!.isNotEmpty) {
      _status = 'QUEUED';
      TelemetryService.trackPageView(
        '/process/$_jobId',
        pageTitle: 'freeOCR.me — Processing Document',
      );
    } else {
      _status = 'UPLOADING';
      _uploadTotalBytes = widget.fileSize ?? (widget.bytes?.length ?? 0);
      TelemetryService.trackPageView(
        '/process',
        pageTitle: 'freeOCR.me — Uploading Document',
      );
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _startUpload();
      });
    }
  }

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _startUpload({String? overridePassword}) async {
    if (_batchItems.length > 1) {
      // Multi-file batch upload path
      setState(() {
        _status = 'UPLOADING';
      });

      for (int i = 0; i < _batchItems.length; i++) {
        final item = _batchItems[i];
        setState(() {
          item.status = 'UPLOADING';
        });

        final result = await ApiService.uploadDocument(
          filename: item.filename,
          bytes: item.bytes,
          password: overridePassword,
          onProgress: (sent, total) {
            if (mounted) {
              setState(() {
                item.sentBytes = sent;
                item.totalBytes = total > 0 ? total : item.sizeInBytes;
                _uploadSentBytes = sent;
                _uploadTotalBytes = total > 0 ? total : item.sizeInBytes;
              });
            }
          },
          onAnalyzing: () {
            if (mounted) {
              setState(() {
                item.status = 'ANALYZING';
              });
            }
          },
        );

        if (!mounted) return;

        if (result.isSuccess && result.jobId != null) {
          setState(() {
            item.jobId = result.jobId;
            item.status = 'QUEUED';
            item.layoutComplexity = result.layoutComplexity;
            item.targetEngine = result.targetEngine;
            item.coldStartActive = result.coldStartActive;
          });
          TelemetryService.trackDocumentUploaded(
            filename: item.filename,
            fileSizeInBytes: item.sizeInBytes,
            source: 'batch_upload',
          );
        } else {
          setState(() {
            item.status = 'FAILED';
            item.errorMessage = result.errorMessage ?? 'Upload failed.';
          });
        }
      }

      if (mounted) {
        final successfulItems = _batchItems.where((it) => it.jobId != null).toList();
        if (successfulItems.isNotEmpty) {
          setState(() {
            _jobId = successfulItems.first.jobId;
            _status = 'QUEUED';
          });
          TelemetryService.trackPageView(
            '/process/${successfulItems.first.jobId}',
            pageTitle: 'freeOCR.me — Processing Batch',
          );
        } else {
          setState(() {
            _status = 'FAILED';
            _errorMessage = 'All files in the batch failed to upload.';
          });
        }
      }
      return;
    }

    // Single file upload path
    final fileBytes = widget.bytes ?? (_batchItems.isNotEmpty ? _batchItems.first.bytes : null);
    final fileName = widget.filename ?? (_batchItems.isNotEmpty ? _batchItems.first.filename : 'document.pdf');
    final fileSize = widget.fileSize ?? (fileBytes?.length ?? 0);

    if (fileBytes == null) {
      setState(() {
        _status = 'FAILED';
        _errorMessage = 'No document data found for upload.';
      });
      return;
    }

    setState(() {
      _status = 'UPLOADING';
      _isPasswordRequired = false;
      _passwordError = null;
    });

    final result = await ApiService.uploadDocument(
      filename: fileName,
      bytes: fileBytes,
      password: overridePassword ?? widget.password,
      onProgress: (sent, total) {
        if (mounted) {
          setState(() {
            _uploadSentBytes = sent;
            _uploadTotalBytes = total > 0 ? total : fileSize;
            _status = 'UPLOADING';
          });
        }
      },
      onAnalyzing: () {
        if (mounted) {
          setState(() {
            _status = 'ANALYZING';
          });
        }
      },
    );

    if (!mounted) return;

    if (result.isSuccess && result.jobId != null) {
      setState(() {
        _jobId = result.jobId;
        _layoutComplexity = result.layoutComplexity;
        _coldStartActive = result.coldStartActive;
        _status = 'QUEUED';
        _isPasswordRequired = false;
        _passwordError = null;
      });

      TelemetryService.trackDocumentUploaded(
        filename: fileName,
        fileSizeInBytes: fileSize,
        source: 'single_upload',
      );
      TelemetryService.trackPageView(
        '/process/${result.jobId}',
        pageTitle: 'freeOCR.me — Processing Document',
      );
    } else if (result.isPasswordRequired) {
      setState(() {
        _isPasswordRequired = true;
        _status = 'PASSWORD_REQUIRED';
        if (overridePassword != null && overridePassword.isNotEmpty) {
          _passwordError = 'Incorrect password. Please try again.';
        } else {
          _passwordError = null;
        }
      });
    } else {
      setState(() {
        _status = 'FAILED';
        _errorMessage = result.errorMessage ?? 'Upload failed.';
      });
    }
  }

  Future<void> _submitPasswordUnlock() async {
    final password = _passwordController.text.trim();
    if (password.isEmpty) {
      setState(() {
        _passwordError = 'Please enter password to unlock.';
      });
      return;
    }
    setState(() {
      _isUnlocking = true;
      _passwordError = null;
    });
    await _startUpload(overridePassword: password);
    if (mounted) {
      setState(() {
        _isUnlocking = false;
      });
    }
  }

  void _handleReset() {
    Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final String displayName = widget.filename ?? (_batchItems.isNotEmpty ? _batchItems.first.filename : 'Document');
    final int displaySize = widget.fileSize ?? (_batchItems.isNotEmpty ? _batchItems.first.sizeInBytes : 0);

    return Scaffold(
      appBar: AppHeader(
        currentRoute: '/process',
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
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 860),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // HERO Section: Active Upload & OCR Progress Card (Above the fold)
                      if (_isPasswordRequired) ...[
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.6),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: _passwordError != null ? colorScheme.error : colorScheme.primary.withValues(alpha: 0.5),
                              width: 1.5,
                            ),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.lock_person_outlined,
                                size: 40,
                                color: _passwordError != null ? colorScheme.error : colorScheme.primary,
                              ),
                              const SizedBox(height: 10),
                              Text(
                                'Password Protected PDF',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: colorScheme.onSurface,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '$displayName is password-protected. Enter password to unlock:',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: colorScheme.onSurfaceVariant,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 14),
                              TextField(
                                controller: _passwordController,
                                obscureText: true,
                                autofocus: true,
                                decoration: InputDecoration(
                                  hintText: 'Enter PDF Password',
                                  prefixIcon: const Icon(Icons.key_outlined),
                                  errorText: _passwordError,
                                  filled: true,
                                  fillColor: colorScheme.surface,
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                onSubmitted: (_) => _submitPasswordUnlock(),
                              ),
                              const SizedBox(height: 16),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  OutlinedButton(
                                    onPressed: _handleReset,
                                    style: OutlinedButton.styleFrom(
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                    ),
                                    child: const Text('Cancel'),
                                  ),
                                  const SizedBox(width: 12),
                                  FilledButton.icon(
                                    onPressed: _isUnlocking ? null : _submitPasswordUnlock,
                                    icon: _isUnlocking
                                        ? const SizedBox(
                                            width: 16,
                                            height: 16,
                                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                          )
                                        : const Icon(Icons.lock_open_outlined, size: 18),
                                    label: Text(_isUnlocking ? 'Unlocking...' : 'Unlock & Process'),
                                    style: FilledButton.styleFrom(
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ] else ...[
                        OcrProgressView(
                          jobId: _jobId,
                          filename: displayName,
                          fileSize: displaySize,
                          layoutComplexity: _layoutComplexity,
                          coldStartActive: _coldStartActive,
                          batchItems: _batchItems.isNotEmpty ? _batchItems : widget.batchItems,
                          uploadSentBytes: _uploadSentBytes,
                          uploadTotalBytes: _uploadTotalBytes,
                          status: _status,
                          errorMessage: _errorMessage,
                          onReset: _handleReset,
                        ),
                      ],
                      const SizedBox(height: 12),
                      // Underneath Hero Section: 1 GAM-ready AdSense banner (fits comfortably above the fold)
                      const AdSenseBanner(),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            const AppFooter(),
          ],
        ),
      ),
    );
  }
}
