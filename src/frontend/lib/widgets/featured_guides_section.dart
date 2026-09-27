import 'package:flutter/material.dart';
import 'glass_card.dart';
import '../utils/url_helper.dart';

/// Model representing a featured knowledge base engineering guide card.
class FeaturedGuideItem {
  final String title;
  final String category;
  final String summary;
  final String readTime;
  final String path;
  final Color categoryColor;
  final IconData icon;

  const FeaturedGuideItem({
    required this.title,
    required this.category,
    required this.summary,
    required this.readTime,
    required this.path,
    required this.categoryColor,
    required this.icon,
  });
}

/// Featured Knowledge Base & Engineering Guides Section for Landing Page (/)
/// Bridges the interactive Flutter canvas directly to the 23 static HTML twin whitepapers,
/// ensuring Google AdSense human reviewers immediately perceive substantial visible editorial value.
class FeaturedGuidesSection extends StatelessWidget {
  const FeaturedGuidesSection({super.key});

  static const List<FeaturedGuideItem> _guides = [
    FeaturedGuideItem(
      title: 'Understanding OCR & Deep Vision Models',
      category: 'NEURAL AI & ARCHITECTURE',
      summary:
          'How deep neural networks, vision transformers, and attention mechanisms extract text from degraded documents with superior precision over heuristic OCR.',
      readTime: '6 min read',
      path: '/kb/ocr-guide',
      categoryColor: Color(0xFF6366F1), // Indigo
      icon: Icons.psychology_outlined,
    ),
    FeaturedGuideItem(
      title: 'Optimal DPI Settings (150 vs 300 vs 600)',
      category: 'SCAN OPTIMIZATION',
      summary:
          'Empirical benchmark analysis measuring character error rates, memory footprint, and processing throughput across standard scanner resolutions.',
      readTime: '5 min read',
      path: '/kb/optimal-dpi-settings',
      categoryColor: Color(0xFF10B981), // Emerald
      icon: Icons.photo_size_select_actual_outlined,
    ),
    FeaturedGuideItem(
      title: 'Dual-Layer Searchable PDF Architecture',
      category: 'PDF STANDARDS',
      summary:
          'Technical breakdown of ISO 32000-1 font render mode 3 (\'Neither fill nor stroke text\'), invisible coordinate synthesis, and sub-pixel bounding box mapping.',
      readTime: '7 min read',
      path: '/kb/pdf-to-searchable-pdf-guide',
      categoryColor: Color(0xFFF59E0B), // Amber
      icon: Icons.layers_outlined,
    ),
    FeaturedGuideItem(
      title: 'PDF Standards Comparison (PDF/A, PDF/X)',
      category: 'LONG-TERM ARCHIVAL',
      summary:
          'Detailed compliance comparison between PDF/A-1b, PDF/A-2u, and print-ready PDF/X formats for regulatory filings and institutional records preservation.',
      readTime: '6 min read',
      path: '/kb/pdf-standards',
      categoryColor: Color(0xFF8B5CF6), // Purple
      icon: Icons.account_balance_outlined,
    ),
    FeaturedGuideItem(
      title: 'Ephemeral RAM-Disk Security Guarantee',
      category: 'SECURITY & PRIVACY',
      summary:
          'Why storing temporary uploads in volatile Linux tmpfs RAM disks with automated POSIX unlink protocols eliminates persistent cloud data leaks.',
      readTime: '5 min read',
      path: '/kb/privacy-security',
      categoryColor: Color(0xFFEF4444), // Rose/Red
      icon: Icons.lock_outline,
    ),
    FeaturedGuideItem(
      title: 'Deskewing & Rotated Scan Correction',
      category: 'COMPUTER VISION',
      summary:
          'Mathematical fundamentals of Radon transform projection profiles for sub-degree rotational correction, Lanczos-4 interpolation, and adaptive binarization.',
      readTime: '6 min read',
      path: '/kb/fixing-skewed-rotated-scans',
      categoryColor: Color(0xFF06B6D4), // Cyan
      icon: Icons.crop_rotate_outlined,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1100),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Divider(height: 48, thickness: 1),
              const SizedBox(height: 16),

              // Section Header Row
              LayoutBuilder(
                builder: (context, constraints) {
                  final isWide = constraints.maxWidth >= 720;
                  final headerText = Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: isDark
                              ? const Color.fromRGBO(99, 102, 241, 0.15)
                              : const Color.fromRGBO(99, 102, 241, 0.08),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isDark
                                ? const Color.fromRGBO(99, 102, 241, 0.3)
                                : const Color.fromRGBO(99, 102, 241, 0.22),
                          ),
                        ),
                        child: Text(
                          'ENGINEERING GUIDES & KNOWLEDGE BASE',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.6,
                            color: isDark ? const Color(0xFFA5B4FC) : const Color(0xFF4F46E5),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Featured Technical Whitepapers',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: colorScheme.onSurface,
                          letterSpacing: -0.3,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'In-depth architectural analyses on neural optical character recognition, ISO PDF standards, DPI calibration, and volatile RAM computing.',
                        style: TextStyle(
                          fontSize: 14,
                          color: colorScheme.onSurfaceVariant,
                          height: 1.4,
                        ),
                      ),
                    ],
                  );

                  final viewAllButton = OutlinedButton.icon(
                    onPressed: () => UrlHelper.navigateToPath('/kb'),
                    icon: const Icon(Icons.menu_book_outlined, size: 16),
                    label: const Text('View All 23 Guides →'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      foregroundColor: const Color(0xFF6366F1),
                      side: BorderSide(
                        color: isDark
                            ? const Color.fromRGBO(99, 102, 241, 0.4)
                            : const Color.fromRGBO(99, 102, 241, 0.3),
                      ),
                    ),
                  );

                  if (isWide) {
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(child: headerText),
                        const SizedBox(width: 16),
                        viewAllButton,
                      ],
                    );
                  }

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      headerText,
                      const SizedBox(height: 16),
                      viewAllButton,
                    ],
                  );
                },
              ),

              const SizedBox(height: 28),

              // Responsive Cards Grid
              LayoutBuilder(
                builder: (context, constraints) {
                  int crossAxisCount = 1;
                  if (constraints.maxWidth >= 900) {
                    crossAxisCount = 3;
                  } else if (constraints.maxWidth >= 600) {
                    crossAxisCount = 2;
                  }

                  if (crossAxisCount == 1) {
                    return Column(
                      children: _guides
                          .map((g) => Padding(
                                padding: const EdgeInsets.only(bottom: 16.0),
                                child: _buildGuideCard(context, g, isDark, colorScheme),
                              ))
                          .toList(),
                    );
                  }

                  // Multi-column row layout
                  final List<Widget> rows = [];
                  for (int i = 0; i < _guides.length; i += crossAxisCount) {
                    final rowItems = <Widget>[];
                    for (int j = 0; j < crossAxisCount; j++) {
                      if (i + j < _guides.length) {
                        rowItems.add(
                          Expanded(
                            child: _buildGuideCard(
                              context,
                              _guides[i + j],
                              isDark,
                              colorScheme,
                            ),
                          ),
                        );
                      } else {
                        rowItems.add(const Expanded(child: SizedBox()));
                      }
                      if (j < crossAxisCount - 1) {
                        rowItems.add(const SizedBox(width: 16));
                      }
                    }
                    rows.add(
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: rowItems,
                        ),
                      ),
                    );
                  }

                  return Column(children: rows);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGuideCard(
    BuildContext context,
    FeaturedGuideItem guide,
    bool isDark,
    ColorScheme colorScheme,
  ) {
    return GlassCard(
      padding: const EdgeInsets.all(20.0),
      borderRadius: 16.0,
      onTap: () => UrlHelper.navigateToPath(guide.path),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Category Pill + Read Time
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: guide.categoryColor.withOpacity(isDark ? 0.18 : 0.10),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(guide.icon, size: 12, color: guide.categoryColor),
                    const SizedBox(width: 4),
                    Text(
                      guide.category,
                      style: TextStyle(
                        fontSize: 9.5,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                        color: guide.categoryColor,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                guide.readTime,
                style: TextStyle(
                  fontSize: 11,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Title
          Text(
            guide.title,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: colorScheme.onSurface,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 8),

          // Summary
          Text(
            guide.summary,
            style: TextStyle(
              fontSize: 13,
              color: colorScheme.onSurfaceVariant,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 16),

          // Bottom CTA Link
          Row(
            children: [
              Text(
                'Read Engineering Guide',
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF6366F1),
                ),
              ),
              const SizedBox(width: 4),
              const Icon(
                Icons.arrow_forward,
                size: 14,
                color: Color(0xFF6366F1),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
