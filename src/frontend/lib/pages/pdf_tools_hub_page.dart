import 'package:flutter/material.dart';
import '../widgets/app_header.dart';
import '../widgets/app_footer.dart';
import '../widgets/adsense_banner.dart';
import '../widgets/tool_card.dart';
import '../services/telemetry_service.dart';
import '../main.dart';

class ToolItemData {
  final String id;
  final String name;
  final String description;
  final String category;
  final String route;
  final IconData icon;
  final String? badge;

  const ToolItemData({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.route,
    required this.icon,
    this.badge,
  });
}

const List<ToolItemData> kPdfToolsCatalog = [
  // Page Operations (6 tools)
  ToolItemData(
    id: 'merge',
    name: 'Merge PDF',
    description: 'Combine multiple PDF files into a single unified document in any order.',
    category: 'page_ops',
    route: '/merge',
    icon: Icons.call_merge_rounded,
    badge: 'POPULAR',
  ),
  ToolItemData(
    id: 'split',
    name: 'Split PDF',
    description: 'Extract individual pages or custom ranges into standalone PDF documents.',
    category: 'page_ops',
    route: '/split',
    icon: Icons.call_split_rounded,
    badge: 'POPULAR',
  ),
  ToolItemData(
    id: 'rotate',
    name: 'Rotate PDF',
    description: 'Rotate PDF pages clockwise or counter-clockwise permanently.',
    category: 'page_ops',
    route: '/rotate',
    icon: Icons.rotate_right_rounded,
  ),
  ToolItemData(
    id: 'delete-pages',
    name: 'Delete Pages',
    description: 'Remove unwanted, blank, or duplicate pages from your PDF file effortlessly.',
    category: 'page_ops',
    route: '/delete-pages',
    icon: Icons.delete_sweep_rounded,
  ),
  ToolItemData(
    id: 'extract-pages',
    name: 'Extract Pages',
    description: 'Select specific pages to extract into a fresh new PDF document.',
    category: 'page_ops',
    route: '/extract-pages',
    icon: Icons.file_copy_rounded,
  ),
  ToolItemData(
    id: 'number-pages',
    name: 'Number Pages',
    description: 'Add clean, customizable page numbers to your PDF documents.',
    category: 'page_ops',
    route: '/number-pages',
    icon: Icons.format_list_numbered_rounded,
    badge: 'NEW',
  ),

  // Security & Optimization (5 tools)
  ToolItemData(
    id: 'compress',
    name: 'Compress PDF',
    description: 'Reduce PDF file size while preserving high visual resolution and fidelity.',
    category: 'security',
    route: '/compress',
    icon: Icons.compress_rounded,
    badge: 'POPULAR',
  ),
  ToolItemData(
    id: 'watermark',
    name: 'Watermark PDF',
    description: 'Stamp custom text or transparent image watermarks across your document.',
    category: 'security',
    route: '/watermark',
    icon: Icons.branding_watermark_rounded,
  ),
  ToolItemData(
    id: 'crop',
    name: 'Crop PDF',
    description: 'Trim page margins or select custom viewport boundaries for your PDF.',
    category: 'security',
    route: '/crop',
    icon: Icons.crop_rounded,
  ),
  ToolItemData(
    id: 'redact',
    name: 'Redact PDF',
    description: 'Permanently black out sensitive text, data, and confidential areas.',
    category: 'security',
    route: '/redact',
    icon: Icons.security_rounded,
    badge: 'SECURITY',
  ),
  ToolItemData(
    id: 'sign',
    name: 'Sign PDF',
    description: 'Draw, type, or upload verifiable digital signatures to sign PDF documents.',
    category: 'security',
    route: '/sign',
    icon: Icons.draw_rounded,
    badge: 'POPULAR',
  ),

  // AI & Conversions (5 tools)
  ToolItemData(
    id: 'ocr',
    name: 'OCR PDF',
    description: 'Convert scanned PDFs and images into searchable PDFs and selectable text.',
    category: 'ai_conversions',
    route: '/ocr',
    icon: Icons.document_scanner_rounded,
    badge: 'AI',
  ),
  ToolItemData(
    id: 'annotate',
    name: 'Annotate PDF',
    description: 'Highlight text, add notes, boxes, and freehand markup directly on PDF.',
    category: 'ai_conversions',
    route: '/annotate',
    icon: Icons.edit_note_rounded,
  ),
  ToolItemData(
    id: 'edit-text',
    name: 'Edit Text',
    description: 'Modify, correct, and update existing text inside PDF documents directly.',
    category: 'ai_conversions',
    route: '/edit-text',
    icon: Icons.text_fields_rounded,
    badge: 'NEW',
  ),
  ToolItemData(
    id: 'pdf-to-word',
    name: 'Convert to Word',
    description: 'Convert PDF documents to editable Microsoft Word .docx format accurately.',
    category: 'ai_conversions',
    route: '/pdf-to-word',
    icon: Icons.article_rounded,
    badge: 'POPULAR',
  ),
  ToolItemData(
    id: 'summarize',
    name: 'Summarize PDF',
    description: 'Generate concise AI summaries, key takeaways, and outline briefs from long PDFs.',
    category: 'ai_conversions',
    route: '/summarize',
    icon: Icons.auto_stories_rounded,
    badge: 'AI',
  ),
];

class PdfToolsHubPage extends StatefulWidget {
  const PdfToolsHubPage({super.key});

  @override
  State<PdfToolsHubPage> createState() => _PdfToolsHubPageState();
}

class _PdfToolsHubPageState extends State<PdfToolsHubPage> {
  String _searchQuery = '';
  String _selectedCategory = 'all'; // 'all', 'page_ops', 'security', 'ai_conversions'
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    TelemetryService.trackPageView('/hub', pageTitle: 'FreePDFToolz — All PDF Tools');
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<ToolItemData> get _filteredTools {
    return kPdfToolsCatalog.where((tool) {
      final matchesCategory = _selectedCategory == 'all' || tool.category == _selectedCategory;
      final query = _searchQuery.trim().toLowerCase();
      final matchesSearch = query.isEmpty ||
          tool.name.toLowerCase().contains(query) ||
          tool.description.toLowerCase().contains(query);
      return matchesCategory && matchesSearch;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppHeader(
        currentRoute: '/hub',
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
                constraints: const BoxConstraints(maxWidth: 1200),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const AdSenseBanner(),
                      const SizedBox(height: 24),
                      _buildHeroHeader(theme, isDark),
                      const SizedBox(height: 24),
                      _buildSearchBarAndFilters(theme, isDark),
                      const SizedBox(height: 32),
                      _buildToolsGrid(theme, isDark),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 48),
            const AppFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroHeader(ThemeData theme, bool isDark) {
    return Column(
      children: [
        Container(
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
                  '16 Free Tools • 100% In-Memory • Zero File Retention',
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
        ),
        const SizedBox(height: 16),
        RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            style: TextStyle(
              fontSize: 38,
              fontWeight: FontWeight.w800,
              letterSpacing: -1.0,
              color: theme.colorScheme.onSurface,
              fontFamily: 'Inter',
              height: 1.2,
            ),
            children: const [
              TextSpan(text: 'Free, All-in-One '),
              TextSpan(
                text: 'PDF Tools Suite',
                style: TextStyle(color: Color(0xFF6366F1)),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 640),
          child: Text(
            'Free, fast, and completely private PDF Tools Suite. Process pages, edit documents, convert formats, and extract OCR without file retention.',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSearchBarAndFilters(ThemeData theme, bool isDark) {
    return Column(
      children: [
        // Search Input
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 540),
          child: TextField(
            controller: _searchController,
            onChanged: (val) => setState(() => _searchQuery = val),
            decoration: InputDecoration(
              hintText: 'Search tools (e.g. merge, split, compress, ocr)...',
              hintStyle: TextStyle(
                color: theme.colorScheme.onSurfaceVariant.withOpacity(0.7),
                fontSize: 14,
              ),
              prefixIcon: Icon(
                Icons.search_rounded,
                color: theme.colorScheme.primary,
              ),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear_rounded, size: 18),
                      onPressed: () {
                        _searchController.clear();
                        setState(() => _searchQuery = '');
                      },
                    )
                  : null,
              filled: true,
              fillColor: isDark
                  ? const Color(0xFF1E293B).withOpacity(0.7)
                  : Colors.white,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: isDark ? Colors.white12 : Colors.black.withOpacity(0.08),
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: isDark ? Colors.white12 : Colors.black.withOpacity(0.08),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: theme.colorScheme.primary,
                  width: 1.5,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        // Filter Chips
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildCategoryChip('all', 'All (16)', theme),
              const SizedBox(width: 8),
              _buildCategoryChip('page_ops', 'Page Operations (6)', theme),
              const SizedBox(width: 8),
              _buildCategoryChip('security', 'Security & Privacy', theme),
              const SizedBox(width: 8),
              _buildCategoryChip('ai_conversions', 'AI & Conversions (5)', theme),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryChip(String categoryId, String label, ThemeData theme) {
    final isSelected = _selectedCategory == categoryId;
    return FilterChip(
      selected: isSelected,
      label: Text(
        label,
        style: TextStyle(
          fontSize: 13,
          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
          color: isSelected ? Colors.white : theme.colorScheme.onSurface,
        ),
      ),
      selectedColor: theme.colorScheme.primary,
      checkmarkColor: Colors.white,
      backgroundColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: isSelected
              ? theme.colorScheme.primary
              : theme.colorScheme.onSurface.withOpacity(0.12),
        ),
      ),
      onSelected: (selected) {
        setState(() {
          _selectedCategory = categoryId;
        });
      },
    );
  }

  Widget _buildToolsGrid(ThemeData theme, bool isDark) {
    final tools = _filteredTools;

    if (tools.isEmpty) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 48),
        alignment: Alignment.center,
        child: Column(
          children: [
            Icon(
              Icons.search_off_rounded,
              size: 54,
              color: theme.colorScheme.onSurfaceVariant.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'No matching PDF tools found',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Try adjusting your search terms or clearing category filters.',
              style: TextStyle(
                fontSize: 14,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                _searchController.clear();
                setState(() {
                  _searchQuery = '';
                  _selectedCategory = 'all';
                });
              },
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text('Reset Filters'),
            ),
          ],
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        int crossAxisCount = 1;
        if (constraints.maxWidth >= 1050) {
          crossAxisCount = 4;
        } else if (constraints.maxWidth >= 760) {
          crossAxisCount = 3;
        } else if (constraints.maxWidth >= 500) {
          crossAxisCount = 2;
        }

        return GridView.builder(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 18,
            mainAxisSpacing: 18,
            mainAxisExtent: 220,
          ),
          itemCount: tools.length,
          itemBuilder: (context, index) {
            final tool = tools[index];
            return ToolCard(
              key: ValueKey(tool.id),
              id: tool.id,
              name: tool.name,
              description: tool.description,
              category: tool.category,
              route: tool.route,
              icon: tool.icon,
              badge: tool.badge,
            );
          },
        );
      },
    );
  }
}
