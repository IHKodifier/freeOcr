import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:desktop_drop/desktop_drop.dart';
import 'package:file_picker/file_picker.dart';
import '../services/api_service.dart';
import '../utils/limit_evaluator.dart';
import 'adsense_banner.dart';
import 'rewarded_video_ad_modal.dart';


class HeroDropzone extends StatefulWidget {
  final Function(String jobId, String filename, int sizeInBytes)? onUploadSuccess;
  final Function(List<BatchFileItem> batchItems)? onBatchUploadSuccess;

  const HeroDropzone({
    super.key,
    this.onUploadSuccess,
    this.onBatchUploadSuccess,
  });

  @override
  State<HeroDropzone> createState() => _HeroDropzoneState();
}

class _HeroDropzoneState extends State<HeroDropzone> {
  bool _isDragging = false;
  bool _isHovered = false;
  bool _isUploading = false;
  double _activeLimitMb = 10.0;
  DateTime? _boostExpiresAt;
  Timer? _boostTicker;


  bool _isPasswordRequired = false;
  bool _isUnlocking = false;
  String? _passwordError;
  final TextEditingController _passwordController = TextEditingController();
  Uint8List? _lockedFileBytes;
  String? _lockedFilename;
  int? _lockedFileSize;

  List<BatchFileItem> _batchItems = [];
  int _currentProcessingIndex = -1;

  @override
  void initState() {
    super.initState();
    _startBoostTicker();
  }

  void _startBoostTicker() {
    _boostTicker = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_boostExpiresAt != null) {
        if (DateTime.now().isAfter(_boostExpiresAt!)) {
          setState(() {
            _activeLimitMb = 10.0;
            _boostExpiresAt = null;
          });
          _showToast('Session limit boost expired. Reverted to standard limit.', isError: true);
        } else {
          setState(() {}); // Rebuild for countdown ticker display
        }
      }
    });
  }

  @override
  void dispose() {
    _boostTicker?.cancel();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _pickFileWithDialog() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
        allowMultiple: true,
        withData: true,
      );

      if (result != null && result.files.isNotEmpty) {
        final List<Map<String, dynamic>> rawFiles = [];
        for (final file in result.files) {
          if (file.bytes != null) {
            rawFiles.add({
              'filename': file.name,
              'size': file.size,
              'bytes': file.bytes!,
            });
          }
        }
        await _processMultipleFiles(rawFiles);
      }
    } catch (e) {
      debugPrint('[HeroDropzone] FilePicker Error: $e');
      _showToast('Error opening file picker: $e', isError: true);
    }
  }

  Future<void> _processMultipleFiles(List<Map<String, dynamic>> rawFiles) async {
    final List<BatchFileItem> validItems = [];
    final allowedExts = ['.pdf', '.jpg', '.jpeg', '.png'];

    // Fetch canonical limits configuration from backend API dynamically
    final config = await ApiService.fetchRuntimeConfig();
    final limits = config['limits'] as Map<String, dynamic>? ?? {};
    final monetization = config['monetization'] as Map<String, dynamic>? ?? {};

    final double baseLimitMb = (limits['base_max_file_mb'] as num?)?.toDouble() ?? 10.0;
    final double boostPerAdMb = (limits['boost_per_ad_mb'] as num?)?.toDouble() ?? 20.0;
    final double maxStackMb = (limits['max_stack_file_mb'] as num?)?.toDouble() ?? 500.0;
    final int adDuration = (monetization['rewarded_ad_duration_seconds'] as num?)?.toInt() ?? 15;

    double activeLimit = _activeLimitMb < baseLimitMb ? baseLimitMb : _activeLimitMb;

    for (int i = 0; i < rawFiles.length; i++) {
      final String filename = rawFiles[i]['filename'] as String;
      final int size = rawFiles[i]['size'] as int;
      final Uint8List bytes = rawFiles[i]['bytes'] as Uint8List;

      final lowerName = filename.toLowerCase();
      final hasValidExt = allowedExts.any((ext) => lowerName.endsWith(ext));

      if (!hasValidExt) {
        _showToast('Skipped $filename: Unsupported format.', isError: true);
        continue;
      }

      if (size == 0) {
        _showToast('Skipped $filename: Empty 0-byte file.', isError: true);
        continue;
      }

      bool isAccepted = false;

      while (!isAccepted) {
        final double currentActiveLimit = _activeLimitMb < baseLimitMb ? baseLimitMb : _activeLimitMb;
        final limitEval = LimitEvaluator.evaluate(
          fileSizeInBytes: size,
          currentLimitMb: currentActiveLimit,
        );

        if (!limitEval.isExceeded) {
          isAccepted = true;
          validItems.add(
            BatchFileItem(
              id: 'file_${DateTime.now().millisecondsSinceEpoch}_$i',
              filename: filename,
              sizeInBytes: size,
              bytes: bytes,
            ),
          );
          break;
        }

        // Oversized file: Pop Rewarded Video Ad Modal cleanly without toast error noise
        bool userWatchedAd = false;
        double? boostedLimitFromModal;

        if (mounted) {
          await RewardedVideoAdModal.show(
            context: context,
            filename: filename,
            fileSizeInBytes: size,
            currentLimitMb: currentActiveLimit,
            boostPerAdMb: boostPerAdMb,
            maxStackMb: maxStackMb,
            adDurationSeconds: adDuration,
            onWatchAd: (boostedLimit) {
              userWatchedAd = true;
              boostedLimitFromModal = boostedLimit;
              if (mounted) {
                setState(() {
                  _activeLimitMb = boostedLimit > maxStackMb ? maxStackMb : boostedLimit;
                  _boostExpiresAt = DateTime.now().add(const Duration(seconds: 3600));
                  _isUploading = true;
                  _batchItems = [
                    BatchFileItem(
                      id: 'file_${DateTime.now().millisecondsSinceEpoch}_$i',
                      filename: filename,
                      sizeInBytes: size,
                      bytes: bytes,
                      status: 'UPLOADING',
                    )
                  ];
                });
              }
            },
            onCancel: () {
              userWatchedAd = false;
            },
          );
        }

        if (!userWatchedAd) {
          _showToast('Skipped $filename: Exceeds limit of ${currentActiveLimit.toInt()}MB.', isError: true);
          break;
        }

        if (boostedLimitFromModal != null && mounted) {
          setState(() {
            _activeLimitMb = boostedLimitFromModal! > maxStackMb ? maxStackMb : boostedLimitFromModal!;
            _boostExpiresAt = DateTime.now().add(const Duration(seconds: 3600));
          });
        }
      }
    }


    if (validItems.isEmpty) {
      if (mounted) {
        setState(() {
          _isUploading = false;
        });
      }
      return;
    }

    // Trigger immediate AdSense rotation on file drop / upload start
    AdSenseBanner.rotateAd();

    if (validItems.length == 1) {
      // Single file upload path
      final item = validItems.first;
      await _processSingleUpload(item.filename, item.sizeInBytes, item.bytes);
      return;
    }

    // Multi-file batch queue upload path
    setState(() {
      _isUploading = true;
      _batchItems = validItems;
      _currentProcessingIndex = 0;
    });


    for (int i = 0; i < _batchItems.length; i++) {
      setState(() {
        _currentProcessingIndex = i;
        _batchItems[i].status = 'UPLOADING';
      });

      final item = _batchItems[i];
      final result = await ApiService.uploadDocument(
        filename: item.filename,
        bytes: item.bytes,
        onProgress: (sent, total) {
          if (mounted) {
            setState(() {
              item.sentBytes = sent;
              item.totalBytes = total > 0 ? total : item.sizeInBytes;
            });
          }
        },
      );

      if (mounted) {
        setState(() {
          if (result.isSuccess && result.jobId != null) {
            item.jobId = result.jobId;
            item.status = 'QUEUED';
          } else {
            item.status = 'FAILED';
            item.errorMessage = result.errorMessage ?? 'Upload failed.';
          }
        });
      }
    }

    if (!mounted) return;

    setState(() {
      _isUploading = false;
    });

    _showToast('Batch upload completed (${_batchItems.length} files queued)!');

    if (widget.onBatchUploadSuccess != null) {
      widget.onBatchUploadSuccess!(_batchItems);
    }
  }

  Future<void> _processSingleUpload(
    String filename,
    int sizeInBytes,
    Uint8List bytes, {
    String? password,
  }) async {
    setState(() {
      _isUploading = true;
      _batchItems = [
        BatchFileItem(
          id: 'single_${DateTime.now().millisecondsSinceEpoch}',
          filename: filename,
          sizeInBytes: sizeInBytes,
          bytes: bytes,
          status: 'UPLOADING',
        )
      ];
      _currentProcessingIndex = 0;
    });

    final item = _batchItems.first;
    final result = await ApiService.uploadDocument(
      filename: filename,
      bytes: bytes,
      password: password,
      onProgress: (sent, total) {
        if (mounted) {
          setState(() {
            item.sentBytes = sent;
            item.totalBytes = total > 0 ? total : sizeInBytes;
          });
        }
      },
    );

    if (!mounted) return;

    setState(() {
      _isUploading = false;
    });

    if (result.isSuccess && result.jobId != null) {
      setState(() {
        _isPasswordRequired = false;
        _passwordError = null;
        _lockedFileBytes = null;
        _lockedFilename = null;
        _lockedFileSize = null;
      });
      _showToast('Uploaded $filename (${formatBytes(sizeInBytes)}) • Job ID: ${result.jobId}');
      if (widget.onUploadSuccess != null) {
        widget.onUploadSuccess!(result.jobId!, filename, sizeInBytes);
      }

    } else if (result.isPasswordRequired) {
      setState(() {
        _isPasswordRequired = true;
        _lockedFileBytes = bytes;
        _lockedFilename = filename;
        _lockedFileSize = sizeInBytes;
        if (password != null && password.isNotEmpty) {
          _passwordError = 'Incorrect password. Please try again.';
        } else {
          _passwordError = null;
        }
      });
    } else {
      _showToast(result.errorMessage ?? 'Upload failed.', isError: true);
    }
  }

  Future<void> _submitPasswordUnlock() async {
    if (_lockedFileBytes == null || _lockedFilename == null || _lockedFileSize == null) return;
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
    await _processSingleUpload(
      _lockedFilename!,
      _lockedFileSize!,
      _lockedFileBytes!,
      password: password,
    );
    if (mounted) {
      setState(() {
        _isUnlocking = false;
      });
    }
  }

  void _showToast(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError
            ? Theme.of(context).colorScheme.error
            : Theme.of(context).colorScheme.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        duration: const Duration(seconds: 4),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isActive = _isDragging || _isHovered;

    int totalBatchBytes = _batchItems.fold(0, (sum, item) => sum + item.sizeInBytes);

    return DropTarget(
      onDragEntered: (_) => setState(() => _isDragging = true),
      onDragExited: (_) => setState(() => _isDragging = false),
      onDragDone: (details) async {
        setState(() => _isDragging = false);
        if (details.files.isNotEmpty) {
          final List<Map<String, dynamic>> rawFiles = [];
          for (final file in details.files) {
            final bytes = await file.readAsBytes();
            final length = await file.length();
            rawFiles.add({
              'filename': file.name,
              'size': length,
              'bytes': bytes,
            });
          }
          debugPrint('[HeroDropzone] Dropped ${rawFiles.length} file(s)');
          await _processMultipleFiles(rawFiles);
        }
      },
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          width: double.infinity,
          constraints: const BoxConstraints(maxWidth: 680, minHeight: 300),
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: isActive
                ? colorScheme.primaryContainer.withValues(alpha: 0.25)
                : colorScheme.surfaceContainerHigh.withValues(alpha: 0.4),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isActive ? colorScheme.primary : colorScheme.outlineVariant,
              width: isActive ? 2.5 : 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: isActive
                    ? colorScheme.primary.withValues(alpha: 0.15)
                    : Colors.black.withValues(alpha: 0.03),
                blurRadius: isActive ? 20 : 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (_isPasswordRequired) ...[
                Container(
                  constraints: const BoxConstraints(maxWidth: 480),
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
                        size: 44,
                        color: _passwordError != null ? colorScheme.error : colorScheme.primary,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Password Protected PDF',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${_lockedFilename ?? "This PDF"} is password-protected. Enter password to unlock:',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
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
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          OutlinedButton(
                            onPressed: () {
                              setState(() {
                                _isPasswordRequired = false;
                                _passwordError = null;
                                _lockedFileBytes = null;
                                _lockedFilename = null;
                                _lockedFileSize = null;
                                _passwordController.clear();
                              });
                            },
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
              ] else if (_isUploading) ...[
                if (_batchItems.length > 1) ...[
                  // Multi-File Batch Progress Header
                  Text(
                    'Batch Upload Queue (${_batchItems.length} Files • ${formatBytes(totalBatchBytes)})',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _batchItems.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 10),

                    itemBuilder: (context, index) {
                      final item = _batchItems[index];
                      final isCurrent = index == _currentProcessingIndex;

                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        decoration: BoxDecoration(
                          color: isCurrent
                              ? colorScheme.primaryContainer.withValues(alpha: 0.3)
                              : colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isCurrent ? colorScheme.primary : colorScheme.outlineVariant,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              item.filename.toLowerCase().endsWith('.pdf')
                                  ? Icons.picture_as_pdf
                                  : Icons.image,
                              color: colorScheme.primary,
                              size: 24,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.filename,
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(
                                    '${getFileTypeDescription(item.filename)} • ${formatBytes(item.sizeInBytes)}',
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            if (item.status == 'UPLOADING') ...[
                              Text(
                                '${(item.uploadProgress * 100).round()}%',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: colorScheme.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(width: 8),
                              const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              ),
                            ] else if (item.status == 'QUEUED' || item.status == 'COMPLETED') ...[
                              Icon(Icons.check_circle, color: Colors.green.shade600, size: 20),
                            ] else if (item.status == 'FAILED') ...[
                              Icon(Icons.error, color: colorScheme.error, size: 20),
                            ] else ...[
                              Text(
                                'Queued',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ],
                        ),
                      );
                    },
                  ),
                ] else ...[
                  // Single File Upload Badge & Progress Bar
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: colorScheme.outlineVariant),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _batchItems.first.filename.toLowerCase().endsWith('.pdf')
                              ? Icons.picture_as_pdf
                              : Icons.image,
                          color: colorScheme.primary,
                          size: 32,
                        ),
                        const SizedBox(width: 14),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _batchItems.first.filename,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${getFileTypeDescription(_batchItems.first.filename)} • ${formatBytes(_batchItems.first.sizeInBytes)}',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Uploading to OCR Engine... ${(_batchItems.first.uploadProgress * 100).round()}%',
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${formatBytes(_batchItems.first.sentBytes)} / ${formatBytes(_batchItems.first.totalBytes)}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: 320,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: _batchItems.first.uploadProgress,
                        minHeight: 10,
                        backgroundColor: colorScheme.surfaceContainerHighest,
                        valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),
                      ),
                    ),
                  ),
                ],
              ] else ...[
                AnimatedScale(
                  scale: isActive ? 1.1 : 1.0,
                  duration: const Duration(milliseconds: 200),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: colorScheme.primaryContainer.withValues(alpha: 0.5),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.cloud_upload_outlined,
                      size: 48,
                      color: colorScheme.primary,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Drag & Drop PDFs or Images',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                if (_boostExpiresAt != null && DateTime.now().isBefore(_boostExpiresAt!)) ...[
                  Builder(
                    builder: (context) {
                      final remaining = _boostExpiresAt!.difference(DateTime.now());
                      final minutes = remaining.inMinutes.remainder(60).toString().padLeft(2, '0');
                      final seconds = remaining.inSeconds.remainder(60).toString().padLeft(2, '0');
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.amber.shade900.withValues(alpha: 0.4),
                              Colors.purple.shade900.withValues(alpha: 0.3),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.amber.shade400.withValues(alpha: 0.6), width: 1.5),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.amber.shade500.withValues(alpha: 0.2),
                              blurRadius: 12,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.bolt_rounded, color: Colors.amber, size: 20),
                            const SizedBox(width: 6),
                            Text(
                              '⚡ Boost Active: Up to ${_activeLimitMb.toInt()}MB each (Expires in $minutes:$seconds)',
                              style: TextStyle(
                                color: Colors.amber.shade200,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ] else ...[
                  Text(
                    'Supports Single or Multiple PDF, JPG, PNG files up to ${_activeLimitMb.toInt()}MB each',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
                const SizedBox(height: 24),
                FilledButton.icon(
                  onPressed: _pickFileWithDialog,
                  icon: const Icon(Icons.file_open_outlined),
                  label: const Text('Select Files'),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
