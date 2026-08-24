import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:desktop_drop/desktop_drop.dart';
import 'package:file_picker/file_picker.dart';
import '../services/api_service.dart';

class HeroDropzone extends StatefulWidget {
  final Function(String jobId, String filename)? onUploadSuccess;

  const HeroDropzone({
    super.key,
    this.onUploadSuccess,
  });

  @override
  State<HeroDropzone> createState() => _HeroDropzoneState();
}

class _HeroDropzoneState extends State<HeroDropzone> {
  bool _isDragging = false;
  bool _isHovered = false;
  bool _isUploading = false;
  String? _uploadingFileName;

  Future<void> _pickFileWithDialog() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
        withData: true,
      );

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        final bytes = file.bytes;
        if (bytes != null) {
          await _processAndUploadFile(file.name, file.size, bytes);
        }
      }
    } catch (e) {
      _showToast('Error opening file picker: $e', isError: true);
    }
  }

  Future<void> _processAndUploadFile(
    String filename,
    int sizeInBytes,
    Uint8List bytes,
  ) async {
    final lowerName = filename.toLowerCase();
    final allowedExts = ['.pdf', '.jpg', '.jpeg', '.png'];

    final hasValidExt = allowedExts.any((ext) => lowerName.endsWith(ext));
    if (!hasValidExt) {
      _showToast('Unsupported file format.', isError: true);
      return;
    }

    if (sizeInBytes == 0) {
      _showToast('File is empty. Please select a valid document.', isError: true);
      return;
    }

    const maxBytes = 10 * 1024 * 1024; // 10MB
    if (sizeInBytes > maxBytes) {
      _showToast('File size exceeds free tier limit of 10MB.', isError: true);
      return;
    }

    setState(() {
      _isUploading = true;
      _uploadingFileName = filename;
    });

    final result = await ApiService.uploadDocument(
      filename: filename,
      bytes: bytes,
    );

    if (!mounted) return;

    setState(() {
      _isUploading = false;
      _uploadingFileName = null;
    });

    if (result.isSuccess && result.jobId != null) {
      _showToast('Document uploaded successfully! Job ID: ${result.jobId}');
      if (widget.onUploadSuccess != null) {
        widget.onUploadSuccess!(result.jobId!, filename);
      }
    } else {
      _showToast(result.errorMessage ?? 'Upload failed.', isError: true);
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

    return DropTarget(
      onDragEntered: (_) => setState(() => _isDragging = true),
      onDragExited: (_) => setState(() => _isDragging = false),
      onDragDone: (details) async {
        setState(() => _isDragging = false);
        if (details.files.isNotEmpty) {
          final file = details.files.first;
          final bytes = await file.readAsBytes();
          final length = await file.length();
          await _processAndUploadFile(file.name, length, bytes);
        }
      },
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          width: double.infinity,
          constraints: const BoxConstraints(maxWidth: 680, minHeight: 280),
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
              if (_isUploading) ...[
                const CircularProgressIndicator(),
                const SizedBox(height: 16),
                Text(
                  'Uploading ${_uploadingFileName ?? "file"}...',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: colorScheme.primary,
                  ),
                ),
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
                  'Drag & Drop PDF or Image',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Supports PDF, JPG, PNG up to 10MB • 100% Free & Ephemeral',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                FilledButton.icon(
                  onPressed: _pickFileWithDialog,
                  icon: const Icon(Icons.file_open_outlined),
                  label: const Text('Select File'),
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
