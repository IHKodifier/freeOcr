import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/api_service.dart';
import '../services/download_helper.dart';
import '../services/telemetry_service.dart';




class SplitPreviewViewer extends StatefulWidget {
  final String jobId;
  final String filename;
  final List<dynamic> pages;
  final VoidCallback? onClose;

  const SplitPreviewViewer({
    super.key,
    required this.jobId,
    required this.filename,
    required this.pages,
    this.onClose,
  });

  @override
  State<SplitPreviewViewer> createState() => _SplitPreviewViewerState();
}

class _SplitPreviewViewerState extends State<SplitPreviewViewer> {
  int _currentPageIndex = 0;
  double _splitRatio = 0.5; // 50/50 split default
  bool _isMarkdownMode = false;
  late TextEditingController _textEditingController;
  bool _copiedToClipboard = false;
  late List<dynamic> _pages;
  bool _isReloading = false;
  Timer? _pollTimer;
  late TransformationController _transformationController;
  double _zoomScale = 1.0;

  @override
  void initState() {
    super.initState();
    _pages = List.from(widget.pages);
    _textEditingController = TextEditingController();
    _transformationController = TransformationController();
    _transformationController.addListener(_onTransformationChanged);
    _updateTextForCurrentPage();

    // Auto-reload preview data if lines are empty (e.g. backend OCR worker was still processing)
    if (_hasEmptyLines()) {
      _reloadPreviewData();
      _startPollingForLines();
    }
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    _textEditingController.dispose();
    _transformationController.removeListener(_onTransformationChanged);
    _transformationController.dispose();
    super.dispose();
  }

  void _onTransformationChanged() {
    final scale = _transformationController.value.getMaxScaleOnAxis();
    if ((scale - _zoomScale).abs() > 0.02) {
      setState(() {
        _zoomScale = double.parse(scale.clamp(0.5, 3.0).toStringAsFixed(2));
      });
    }
  }

  void _setZoom(double newScale) {
    final target = double.parse(newScale.clamp(0.5, 3.0).toStringAsFixed(2));
    setState(() {
      _zoomScale = target;
      _transformationController.value = Matrix4.identity()..scale(target, target);
    });
  }

  void _zoomIn() {
    _setZoom(_zoomScale + 0.25);
  }

  void _zoomOut() {
    _setZoom(_zoomScale - 0.25);
  }

  void _resetZoom() {
    _setZoom(1.0);
  }

  void _startPollingForLines() {
    _pollTimer?.cancel();
    _pollTimer = Timer.periodic(const Duration(seconds: 3), (timer) async {
      if (!mounted) {
        timer.cancel();
        return;
      }
      await _reloadPreviewData();
      if (!_hasEmptyLines() || timer.tick >= 30) {
        timer.cancel();
      }
    });
  }

  bool _hasEmptyLines() {
    if (_pages.isEmpty) return true;
    for (final page in _pages) {
      final lines = page['lines'] as List<dynamic>? ?? [];
      if (lines.isEmpty) return true;
    }
    return false;
  }

  Future<void> _reloadPreviewData() async {
    if (_isReloading) return;
    setState(() {
      _isReloading = true;
    });

    final data = await ApiService.fetchJobPreview(widget.jobId);
    if (mounted) {
      setState(() {
        _isReloading = false;
        if (data != null && data.containsKey('pages')) {
          _pages = data['pages'] as List<dynamic>? ?? [];
          _updateTextForCurrentPage();
          if (!_hasEmptyLines()) {
            _pollTimer?.cancel();
          }
        }
      });
    }
  }

  @override
  void didUpdateWidget(covariant SplitPreviewViewer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.pages != widget.pages) {
      setState(() {
        _pages = List.from(widget.pages);
        _updateTextForCurrentPage();
      });
      if (_hasEmptyLines()) {
        _reloadPreviewData();
        _startPollingForLines();
      }
    }
  }

  void _updateTextForCurrentPage() {
    if (_pages.isNotEmpty && _currentPageIndex < _pages.length) {
      final pageData = _pages[_currentPageIndex];
      final rawText = pageData['text'] as String? ?? '';
      _textEditingController.text = rawText;
    } else {
      _textEditingController.text = '';
    }
  }


  void _goToPreviousPage() {
    if (_currentPageIndex > 0) {
      setState(() {
        _currentPageIndex--;
        _resetZoom();
        _updateTextForCurrentPage();
      });
    }
  }

  void _goToNextPage() {
    if (_currentPageIndex < _pages.length - 1) {
      setState(() {
        _currentPageIndex++;
        _resetZoom();
        _updateTextForCurrentPage();
      });
    }
  }

  void _copyTextToClipboard() {
    Clipboard.setData(ClipboardData(text: _textEditingController.text));
    setState(() {
      _copiedToClipboard = true;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('OCR text copied to clipboard!'),
        duration: Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _copiedToClipboard = false;
        });
      }
    });
  }

  void _downloadFile(String format) {
    final url = ApiService.getDownloadUrl(widget.jobId, format);
    final dotIndex = widget.filename.lastIndexOf('.');
    final stem = dotIndex > 0 ? widget.filename.substring(0, dotIndex) : widget.filename;
    final ext = format == 'pdf' ? '_searchable.pdf' : '_extracted.$format';
    final outFilename = '$stem$ext';

    DownloadHelper.triggerDownload(url, outFilename);
    TelemetryService.trackDownloadClicked(
      jobId: widget.jobId,
      format: format,
      filename: outFilename,
    );
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Initiating direct download of $outFilename...'),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final totalPages = _pages.length;
    final currentPageNum = totalPages > 0 ? _currentPageIndex + 1 : 0;
    final currentLines = _pages.isNotEmpty && _currentPageIndex < _pages.length
        ? (_pages[_currentPageIndex]['lines'] as List<dynamic>? ?? [])
        : [];

    return Container(
      width: double.infinity,
      height: 650,
      constraints: const BoxConstraints(maxWidth: 1100),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHigh.withValues(alpha: 0.65),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: colorScheme.primary.withValues(alpha: 0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.15),
            blurRadius: 32,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20.0, sigmaY: 20.0),
          child: Column(
            children: [
              // Top Glassmorphic Header Bar
              _buildTopHeader(theme, colorScheme, currentPageNum, totalPages),

              // Split Panes Container
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final bool isNarrow = constraints.maxWidth < 700;
                    if (isNarrow) {
                      return _buildStackedView(theme, colorScheme);
                    }
                    return _buildSplitView(theme, colorScheme, constraints.maxWidth);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopHeader(ThemeData theme, ColorScheme colorScheme, int currentPageNum, int totalPages) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
        border: Border(
          bottom: BorderSide(color: colorScheme.outlineVariant.withValues(alpha: 0.5)),
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.style, color: colorScheme.primary, size: 24),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              widget.filename,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                letterSpacing: -0.2,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 12),

          // Reload Bounding Blocks Button
          IconButton(
            icon: _isReloading
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.refresh, size: 20),
            onPressed: _isReloading ? null : _reloadPreviewData,
            tooltip: 'Reload Bounding Blocks & Extracted Text',
          ),
          const SizedBox(width: 8),

          // Page Navigation Controls
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.7),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: colorScheme.outlineVariant),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left, size: 20),
                  onPressed: _currentPageIndex > 0 ? _goToPreviousPage : null,
                  tooltip: 'Previous Page',
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Text(
                    'Page $currentPageNum of $totalPages',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right, size: 20),
                  onPressed: _currentPageIndex < totalPages - 1 ? _goToNextPage : null,
                  tooltip: 'Next Page',
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),

          // Email Links Button
          IconButton(
            icon: const Icon(Icons.email_outlined, size: 20),
            onPressed: () => _showEmailDeliveryDialog(context),
            tooltip: 'Send Download Links via Email',
          ),
          const SizedBox(width: 4),

          // 1-Click Direct Multi-Format Download Menu Button
          PopupMenuButton<String>(
            tooltip: 'Download Multi-Format Document',
            onSelected: (value) {
              if (value == 'email') {
                _showEmailDeliveryDialog(context);
              } else {
                _downloadFile(value);
              }
            },
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: colorScheme.primary,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: colorScheme.primary.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.download_rounded, color: Colors.white, size: 18),
                  SizedBox(width: 6),
                  Text(
                    'Download',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                  SizedBox(width: 2),
                  Icon(Icons.arrow_drop_down, color: Colors.white, size: 18),
                ],
              ),
            ),
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              const PopupMenuItem<String>(
                value: 'pdf',
                child: Row(
                  children: [
                    Icon(Icons.picture_as_pdf, color: Colors.redAccent, size: 20),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text('Searchable PDF (.pdf)', style: TextStyle(fontWeight: FontWeight.w600), overflow: TextOverflow.ellipsis),
                    ),
                  ],
                ),
              ),
              const PopupMenuItem<String>(
                value: 'txt',
                child: Row(
                  children: [
                    Icon(Icons.description_outlined, color: Colors.blueAccent, size: 20),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text('Plain Text (.txt)', style: TextStyle(fontWeight: FontWeight.w600), overflow: TextOverflow.ellipsis),
                    ),
                  ],
                ),
              ),
              const PopupMenuItem<String>(
                value: 'md',
                child: Row(
                  children: [
                    Icon(Icons.code, color: Colors.purpleAccent, size: 20),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text('Markdown (.md)', style: TextStyle(fontWeight: FontWeight.w600), overflow: TextOverflow.ellipsis),
                    ),
                  ],
                ),
              ),
              const PopupMenuDivider(),
              const PopupMenuItem<String>(
                value: 'email',
                child: Row(
                  children: [
                    Icon(Icons.mark_email_read_outlined, color: Colors.teal, size: 20),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text('Send Email Links (24h)', style: TextStyle(fontWeight: FontWeight.w600), overflow: TextOverflow.ellipsis),
                    ),
                  ],
                ),
              ),
            ],


          ),
          const SizedBox(width: 8),

          if (widget.onClose != null)
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: widget.onClose,
              tooltip: 'Close Preview',
            ),
        ],
      ),
    );
  }

  void _showEmailDeliveryDialog(BuildContext context) {
    final emailController = TextEditingController();
    bool isSubmitting = false;
    String? errorMessage;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            final theme = Theme.of(context);
            final colorScheme = theme.colorScheme;

            return AlertDialog(
              backgroundColor: colorScheme.surfaceContainer,
              surfaceTintColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color: colorScheme.outlineVariant.withValues(alpha: 0.8),
                  width: 1.5,
                ),
              ),
              title: Row(
                children: [
                  Icon(Icons.email_outlined, color: colorScheme.primary, size: 26),
                  const SizedBox(width: 10),
                  const Text('Email Download Links', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                ],
              ),
              content: SizedBox(
                width: 420,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Receive 24-hour expiring download links for PDF, TXT, and Markdown directly in your inbox.',
                      style: theme.textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 16),

                    // Privacy Warning Banner (AC-1)
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.amber.shade900.withValues(alpha: 0.35),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.amber.shade600.withValues(alpha: 0.6)),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.warning_amber_rounded, color: Colors.amber.shade400, size: 22),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Input file is deleted immediately. Ensure email address is correct.',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 12,
                                color: Colors.amber.shade200,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Email Input Field
                    TextField(
                      controller: emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        labelText: 'Email Address',
                        hintText: 'user@example.com',
                        prefixIcon: const Icon(Icons.mail_outline),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        errorText: errorMessage,
                      ),
                      enabled: !isSubmitting,
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: isSubmitting ? null : () => Navigator.of(dialogContext).pop(),
                  child: const Text('Cancel'),
                ),
                ElevatedButton.icon(
                  onPressed: isSubmitting
                      ? null
                      : () async {
                          final email = emailController.text.trim();
                          if (email.isEmpty || !email.contains('@')) {
                            setDialogState(() {
                              errorMessage = 'Please enter a valid email address.';
                            });
                            return;
                          }

                          setDialogState(() {
                            isSubmitting = true;
                            errorMessage = null;
                          });

                          final res = await ApiService.sendEmailLinks(widget.jobId, email);

                          if (!dialogContext.mounted) return;

                          if (res['status'] == 'SUCCESS') {
                            final domain = email.contains('@') ? email.split('@').last : 'unknown';
                            TelemetryService.trackEmailSent(
                              jobId: widget.jobId,
                              recipientDomain: domain,
                            );
                            Navigator.of(dialogContext).pop();
                            final msg = res['message'] as String? ?? 'Download links sent to $email! Original input file purged.';
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(msg),
                                backgroundColor: Colors.green.shade700,
                                duration: const Duration(seconds: 5),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          } else {
                            setDialogState(() {
                              isSubmitting = false;
                              errorMessage = res['detail'] as String? ?? 'Failed to send email download links.';
                            });
                          }
                        },
                  icon: isSubmitting
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Icon(Icons.send_rounded, size: 18),
                  label: Text(isSubmitting ? 'Sending...' : 'Send Download Links'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }



  Widget _buildSplitView(ThemeData theme, ColorScheme colorScheme, double totalWidth) {
    const minPaneWidth = 250.0;
    final leftWidth = (_splitRatio * totalWidth).clamp(minPaneWidth, totalWidth - minPaneWidth);
    final rightWidth = totalWidth - leftWidth - 8.0;

    return Row(
      children: [
        // Left Pane: Interactive Document Page Preview
        SizedBox(
          width: leftWidth,
          child: _buildDocumentPreviewPane(theme, colorScheme),
        ),

        // Split Drag Handle
        GestureDetector(
          behavior: HitTestBehavior.translucent,
          onHorizontalDragUpdate: (details) {
            setState(() {
              _splitRatio = (_splitRatio + details.delta.dx / totalWidth).clamp(0.2, 0.8);
            });
          },
          child: Container(
            width: 8,
            color: colorScheme.outlineVariant.withValues(alpha: 0.3),
            child: Center(
              child: Container(
                width: 4,
                height: 48,
                decoration: BoxDecoration(
                  color: colorScheme.primary.withValues(alpha: 0.7),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          ),
        ),

        // Right Pane: Selectable OCR Text Editor & Format Toggles
        SizedBox(
          width: rightWidth,
          child: _buildRightTextPane(theme, colorScheme),
        ),
      ],
    );
  }

  Widget _buildStackedView(ThemeData theme, ColorScheme colorScheme) {
    return SingleChildScrollView(
      child: Column(
        children: [
          SizedBox(
            height: 350,
            child: _buildDocumentPreviewPane(theme, colorScheme),
          ),
          Divider(height: 1, color: colorScheme.outlineVariant),
          SizedBox(
            height: 350,
            child: _buildRightTextPane(theme, colorScheme),
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentPreviewPane(ThemeData theme, ColorScheme colorScheme) {
    final currentPageNum = _currentPageIndex + 1;
    final totalPages = _pages.isNotEmpty ? _pages.length : 1;
    final pageImageUrl = ApiService.getPageImageUrl(widget.jobId, currentPageNum);

    return Container(
      color: colorScheme.surfaceContainerLow.withValues(alpha: 0.5),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header & Zoom Controls Toolbar
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 8,
            runSpacing: 6,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.picture_as_pdf_outlined, size: 18, color: colorScheme.primary),
                  const SizedBox(width: 8),
                  Text(
                    'Document Page Preview',
                    style: theme.textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.primary,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: colorScheme.primary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: colorScheme.primary.withValues(alpha: 0.3)),
                    ),
                    child: Text(
                      'Page $currentPageNum',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),

              // Zoom Controls (Zoom Out, Slider, Zoom In, Reset Chip)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: colorScheme.outlineVariant.withValues(alpha: 0.6)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.zoom_out, size: 16),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(minWidth: 26, minHeight: 26),
                      onPressed: _zoomScale > 0.5 ? _zoomOut : null,
                      tooltip: 'Zoom Out',
                    ),
                    SizedBox(
                      width: 90,
                      child: SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                          trackHeight: 3,
                          thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                          overlayShape: const RoundSliderOverlayShape(overlayRadius: 10),
                          activeTrackColor: colorScheme.primary,
                          inactiveTrackColor: colorScheme.outlineVariant,
                          thumbColor: colorScheme.primary,
                        ),
                        child: Slider(
                          value: _zoomScale.clamp(0.5, 3.0),
                          min: 0.5,
                          max: 3.0,
                          divisions: 25,
                          onChanged: (val) => _setZoom(val),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.zoom_in, size: 16),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(minWidth: 26, minHeight: 26),
                      onPressed: _zoomScale < 3.0 ? _zoomIn : null,
                      tooltip: 'Zoom In',
                    ),
                    InkWell(
                      onTap: _resetZoom,
                      borderRadius: BorderRadius.circular(6),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: colorScheme.surface,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: colorScheme.outlineVariant.withValues(alpha: 0.5)),
                        ),
                        child: Text(
                          '${(_zoomScale * 100).round()}%',
                          style: theme.textTheme.labelSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            fontFamily: 'monospace',
                            fontSize: 11,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Interactive Pan & Zoom Viewport
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: colorScheme.outlineVariant),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: InteractiveViewer(
                  transformationController: _transformationController,
                  minScale: 0.5,
                  maxScale: 3.0,
                  boundaryMargin: const EdgeInsets.all(100),
                  clipBehavior: Clip.hardEdge,
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Image.network(
                        pageImageUrl,
                        key: ValueKey('${widget.jobId}_page_$currentPageNum'),
                        fit: BoxFit.contain,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const SizedBox(
                                  width: 28,
                                  height: 28,
                                  child: CircularProgressIndicator(strokeWidth: 2.5),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  'Rendering Page $currentPageNum Preview...',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: colorScheme.onSurfaceVariant,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) {
                          return Center(
                            child: Padding(
                              padding: const EdgeInsets.all(24.0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.image_not_supported_outlined, size: 40, color: Colors.grey.shade500),
                                  const SizedBox(height: 12),
                                  Text(
                                    'Page $currentPageNum Preview Not Available',
                                    style: theme.textTheme.titleSmall?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey.shade800,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    'High-fidelity preview is unavailable or expired.',
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: Colors.grey.shade600,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 12),
                                  OutlinedButton.icon(
                                    onPressed: () {
                                      setState(() {});
                                    },
                                    icon: const Icon(Icons.refresh, size: 16),
                                    label: const Text('Retry Preview'),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRightTextPane(ThemeData theme, ColorScheme colorScheme) {
    return Container(
      color: colorScheme.surfaceContainerHigh.withValues(alpha: 0.3),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Toolbar with Format Toggles & Copy Button
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 8,
            runSpacing: 8,
            children: [
              // Segmented Format Toggle
              Container(
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: colorScheme.outlineVariant),
                ),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildTabOption(
                        label: 'Plain Text (.txt)',
                        isActive: !_isMarkdownMode,
                        onTap: () => setState(() => _isMarkdownMode = false),
                        colorScheme: colorScheme,
                      ),
                      _buildTabOption(
                        label: 'Markdown (.md)',
                        isActive: _isMarkdownMode,
                        onTap: () => setState(() => _isMarkdownMode = true),
                        colorScheme: colorScheme,
                      ),
                    ],
                  ),
                ),
              ),

              // Copy Button
              ElevatedButton.icon(
                onPressed: _copyTextToClipboard,
                icon: Icon(
                  _copiedToClipboard ? Icons.check : Icons.copy_all_rounded,
                  size: 18,
                ),
                label: Text(_copiedToClipboard ? 'Copied!' : 'Copy Text'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _copiedToClipboard ? Colors.green.shade600 : colorScheme.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // OCR Text Editor Pane
          Expanded(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colorScheme.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: colorScheme.outlineVariant),
              ),
              child: TextField(
                controller: _textEditingController,
                maxLines: null,
                keyboardType: TextInputType.multiline,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontFamily: _isMarkdownMode ? 'sans-serif' : 'monospace',
                  height: 1.5,
                ),
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  hintText: 'No OCR text extracted for this page...',
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabOption({
    required String label,
    required bool isActive,
    required VoidCallback onTap,
    required ColorScheme colorScheme,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isActive ? colorScheme.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(9),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isActive ? colorScheme.onPrimary : colorScheme.onSurfaceVariant,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}
