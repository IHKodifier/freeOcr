import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:desktop_drop/desktop_drop.dart';
import 'package:http/http.dart' as http;
import '../widgets/app_header.dart';
import '../widgets/app_footer.dart';
import '../widgets/adsense_banner.dart';
import '../main.dart';

class SelectedPdfFile {
  final String name;
  final int sizeBytes;
  final Uint8List? bytes;
  final String? path;

  const SelectedPdfFile({
    required this.name,
    required this.sizeBytes,
    this.bytes,
    this.path,
  });

  String get formattedSize {
    if (sizeBytes < 1024) return '$sizeBytes B';
    if (sizeBytes < 1024 * 1024) return '${(sizeBytes / 1024).toStringAsFixed(1)} KB';
    return '${(sizeBytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}

class PdfMergePage extends StatefulWidget {
  final List<SelectedPdfFile>? initialFiles;

  const PdfMergePage({
    super.key,
    this.initialFiles,
  });

  @override
  State<PdfMergePage> createState() => _PdfMergePageState();
}

class _PdfMergePageState extends State<PdfMergePage> {
  late List<SelectedPdfFile> _files;
  bool _isDragging = false;
  bool _isMerging = false;
  String? _errorMessage;
  Uint8List? _mergedPdfBytes;
  int? _mergedSizeBytes;

  @override
  void initState() {
    super.initState();
    _files = widget.initialFiles != null ? List.from(widget.initialFiles!) : [];
  }

  int get _totalSizeBytes => _files.fold(0, (sum, f) => sum + f.sizeBytes);

  String get _formattedTotalSize {
    final bytes = _totalSizeBytes;
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  Future<void> _pickFiles() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        allowMultiple: true,
        type: FileType.custom,
        allowedExtensions: ['pdf'],
        withData: true,
      );

      if (result != null && result.files.isNotEmpty) {
        setState(() {
          for (final f in result.files) {
            if (f.name.toLowerCase().endsWith('.pdf')) {
              _files.add(
                SelectedPdfFile(
                  name: f.name,
                  sizeBytes: f.size,
                  bytes: f.bytes,
                  path: f.path,
                ),
              );
            }
          }
          _errorMessage = null;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to select files: $e';
      });
    }
  }

  Future<void> _handleDrop(DropDoneDetails details) async {
    final newFiles = <SelectedPdfFile>[];
    for (final xfile in details.files) {
      if (xfile.name.toLowerCase().endsWith('.pdf')) {
        final length = await xfile.length();
        final bytes = await xfile.readAsBytes();
        newFiles.add(
          SelectedPdfFile(
            name: xfile.name,
            sizeBytes: length,
            bytes: bytes,
            path: xfile.path,
          ),
        );
      }
    }

    if (newFiles.isNotEmpty) {
      setState(() {
        _files.addAll(newFiles);
        _errorMessage = null;
      });
    }
  }

  void _removeFileAt(int index) {
    setState(() {
      _files.removeAt(index);
    });
  }

  void _onReorder(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) {
        newIndex -= 1;
      }
      final item = _files.removeAt(oldIndex);
      _files.insert(newIndex, item);
    });
  }

  Future<void> _executeMerge() async {
    if (_files.length < 2) return;

    setState(() {
      _isMerging = true;
      _errorMessage = null;
    });

    try {
      final uri = Uri.parse('/api/v1/tools/merge');
      final request = http.MultipartRequest('POST', uri);

      for (int i = 0; i < _files.length; i++) {
        final file = _files[i];
        if (file.bytes != null) {
          request.files.add(
            http.MultipartFile.fromBytes(
              'files',
              file.bytes!,
              filename: file.name,
            ),
          );
        }
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        setState(() {
          _mergedPdfBytes = response.bodyBytes;
          _mergedSizeBytes = response.bodyBytes.length;
          _isMerging = false;
        });
      } else {
        String detail = 'Merge failed (HTTP ${response.statusCode})';
        try {
          final decoded = jsonDecode(response.body);
          if (decoded['detail'] != null) detail = decoded['detail'];
        } catch (_) {}
        setState(() {
          _errorMessage = detail;
          _isMerging = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Network error during merge: $e';
        _isMerging = false;
      });
    }
  }

  void _reset() {
    setState(() {
      _files.clear();
      _mergedPdfBytes = null;
      _mergedSizeBytes = null;
      _errorMessage = null;
      _isMerging = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppHeader(
        currentRoute: '/merge',
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
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 860),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const AdSenseBanner(),
                      const SizedBox(height: 24),

                      // Tool Header Icon
                      Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFEF4444), Color(0xFFDC2626)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFEF4444).withOpacity(0.3),
                              blurRadius: 16,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.call_merge_rounded,
                          color: Colors.white,
                          size: 32,
                        ),
                      ),
                      const SizedBox(height: 16),

                      Text(
                        'Merge PDF Files',
                        style: theme.textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Combine multiple PDFs into a single document in your desired order.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: isDark ? Colors.white60 : Colors.black54,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 28),

                      if (_errorMessage != null) ...[
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.red.withOpacity(0.3)),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.error_outline, color: Colors.red, size: 20),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  _errorMessage!,
                                  style: const TextStyle(color: Colors.red, fontSize: 13),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],

                      // Success State
                      if (_mergedPdfBytes != null)
                        _buildSuccessCard(theme, isDark)
                      else ...[
                        // Dropzone Area
                        _buildDropzone(theme, isDark),
                        const SizedBox(height: 20),

                        // Selected Files Reorderable List
                        if (_files.isNotEmpty) ...[
                          _buildFilesHeader(theme, isDark),
                          const SizedBox(height: 12),
                          _buildReorderableList(theme, isDark),
                          const SizedBox(height: 24),
                        ],

                        // Merge Action Button
                        _buildActionButton(theme),
                      ],

                      const SizedBox(height: 48),
                    ],
                  ),
                ),
              ),
            ),
            const AppFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildDropzone(ThemeData theme, bool isDark) {
    return DropTarget(
      onDragEntered: (_) => setState(() => _isDragging = true),
      onDragExited: (_) => setState(() => _isDragging = false),
      onDragDone: _handleDrop,
      child: InkWell(
        onTap: _pickFiles,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 24),
          decoration: BoxDecoration(
            color: _isDragging
                ? (isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9))
                : (isDark ? const Color(0xFF0F172A) : Colors.white),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: _isDragging
                  ? const Color(0xFFEF4444)
                  : (isDark ? Colors.white12 : Colors.black12),
              width: _isDragging ? 2 : 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.cloud_upload_outlined,
                size: 48,
                color: _isDragging
                    ? const Color(0xFFEF4444)
                    : (isDark ? Colors.white70 : Colors.black45),
              ),
              const SizedBox(height: 12),
              Text(
                'Drop PDF files here, or click to browse',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Supports up to 50 files • Max 100MB free tier',
                style: TextStyle(
                  fontSize: 13,
                  color: isDark ? Colors.white54 : Colors.black45,
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _pickFiles,
                icon: const Icon(Icons.add_rounded, size: 18),
                label: const Text('Select PDF Files'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
                  foregroundColor: isDark ? Colors.white : Colors.black87,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                    side: BorderSide(color: isDark ? Colors.white12 : Colors.black12),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilesHeader(ThemeData theme, bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Text(
              '${_files.length} files selected',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 15,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: const Color(0xFFEF4444).withOpacity(0.12),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                _formattedTotalSize,
                style: const TextStyle(
                  color: Color(0xFFEF4444),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        TextButton.icon(
          onPressed: _pickFiles,
          icon: const Icon(Icons.add, size: 16),
          label: const Text('Add More'),
          style: TextButton.styleFrom(
            foregroundColor: const Color(0xFFEF4444),
            textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }

  Widget _buildReorderableList(ThemeData theme, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F172A) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: isDark ? Colors.white12 : Colors.black12),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: ReorderableListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _files.length,
          onReorder: _onReorder,
          itemBuilder: (context, index) {
            final file = _files[index];
            return Container(
              key: ValueKey('${file.name}_$index'),
              decoration: BoxDecoration(
                border: Border(
                  bottom: index < _files.length - 1
                      ? BorderSide(color: isDark ? Colors.white10 : Colors.black12)
                      : BorderSide.none,
                ),
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                leading: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEF4444).withOpacity(0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.picture_as_pdf_rounded,
                    color: Color(0xFFEF4444),
                    size: 20,
                  ),
                ),
                title: Text(
                  file.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                subtitle: Text(
                  file.formattedSize,
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? Colors.white54 : Colors.black45,
                  ),
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.close, size: 18),
                      tooltip: 'Remove file',
                      onPressed: () => _removeFileAt(index),
                      color: isDark ? Colors.white54 : Colors.black45,
                    ),
                    const SizedBox(width: 4),
                    const Icon(Icons.drag_indicator, size: 20, color: Colors.grey),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildActionButton(ThemeData theme) {
    final canMerge = _files.length >= 2 && !_isMerging;

    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: canMerge ? _executeMerge : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFEF4444),
          foregroundColor: Colors.white,
          disabledBackgroundColor: Colors.grey.withOpacity(0.2),
          disabledForegroundColor: Colors.grey,
          elevation: canMerge ? 4 : 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(vertical: 14),
        ),
        child: _isMerging
            ? const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                  SizedBox(width: 12),
                  Text(
                    'Merging PDFs...',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                ],
              )
            : Text(
                _files.length < 2 ? 'Merge PDFs' : 'Merge PDFs (${_files.length})',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
      ),
    );
  }

  Widget _buildSuccessCard(ThemeData theme, bool isDark) {
    final sizeKb = (_mergedSizeBytes ?? 0) / 1024;
    final sizeStr = sizeKb > 1024
        ? '${(sizeKb / 1024).toStringAsFixed(1)} MB'
        : '${sizeKb.toStringAsFixed(1)} KB';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F172A) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.green.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withOpacity(0.06),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.check_circle_outline, color: Colors.green, size: 32),
          ),
          const SizedBox(height: 16),
          Text(
            'PDFs Merged Successfully!',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Your combined document is ready ($sizeStr).',
            style: TextStyle(color: isDark ? Colors.white60 : Colors.black54),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton.icon(
              onPressed: () {
                // Trigger download in web
              },
              icon: const Icon(Icons.download_rounded),
              label: const Text('Download Merged PDF', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF10B981),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
          const SizedBox(height: 12),
          TextButton.icon(
            onPressed: _reset,
            icon: const Icon(Icons.refresh_rounded, size: 16),
            label: const Text('Merge Another PDF'),
            style: TextButton.styleFrom(foregroundColor: isDark ? Colors.white70 : Colors.black54),
          ),
        ],
      ),
    );
  }
}
