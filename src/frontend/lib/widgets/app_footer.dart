import 'package:flutter/material.dart';
import '../utils/url_helper.dart';

/// Global, responsive 4-column footer component for freeOCR.me.
/// Governed by docs/DESIGN.md & Google Stitch Screen 01 specification.
class AppFooter extends StatelessWidget {
  const AppFooter({super.key});

  static const String twitterUrl = 'https://twitter.com/freeocr_me';
  static const String linkedinUrl = 'https://linkedin.com/company/freeocr-me';
  static const String discordUrl = 'https://discord.gg/freeocr';

  static const String baiduOcrUrl = 'https://github.com/PaddlePaddle/PaddleOCR';
  static const String ocrmypdfUrl = 'https://github.com/ocrmypdf/OCRmyPDF';
  static const String tesseractUrl = 'https://github.com/tesseract-ocr/tesseract';
  static const String pymupdfUrl = 'https://github.com/pymupdf/PyMuPDF';

  void _navigateTo(BuildContext context, String routeName) {
    if (ModalRoute.of(context)?.settings.name != routeName) {
      Navigator.pushNamed(context, routeName);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final sectionTitleStyle = TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w700,
      letterSpacing: 0.5,
      color: colorScheme.onSurface,
      fontFamily: 'Inter',
    );

    final linkStyle = TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w400,
      color: colorScheme.onSurfaceVariant,
      fontFamily: 'Inter',
    );

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: isDark
            ? const Color.fromRGBO(15, 23, 42, 0.90)
            : const Color(0xFFF1F5F9),
        border: Border(
          top: BorderSide(
            color: isDark
                ? const Color.fromRGBO(255, 255, 255, 0.10)
                : const Color.fromRGBO(0, 0, 0, 0.08),
            width: 1.0,
          ),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 48.0),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1140),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isMobile = constraints.maxWidth < 700;

              if (isMobile) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildBrandColumn(context, theme, colorScheme, linkStyle),
                    const SizedBox(height: 32),
                    _buildNavColumn(context, sectionTitleStyle, linkStyle),
                    const SizedBox(height: 32),
                    _buildEnginesColumn(context, theme, colorScheme, sectionTitleStyle),
                    const SizedBox(height: 32),
                    _buildLegalColumn(context, sectionTitleStyle, linkStyle),
                  ],
                );
              }

              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 3,
                    child: _buildBrandColumn(context, theme, colorScheme, linkStyle),
                  ),
                  const SizedBox(width: 24),
                  Expanded(
                    flex: 2,
                    child: _buildNavColumn(context, sectionTitleStyle, linkStyle),
                  ),
                  const SizedBox(width: 24),
                  Expanded(
                    flex: 3,
                    child: _buildEnginesColumn(context, theme, colorScheme, sectionTitleStyle),
                  ),
                  const SizedBox(width: 24),
                  Expanded(
                    flex: 2,
                    child: _buildLegalColumn(context, sectionTitleStyle, linkStyle),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  // --- Column 1: Brand & Social Handles ---
  Widget _buildBrandColumn(
    BuildContext context,
    ThemeData theme,
    ColorScheme colorScheme,
    TextStyle linkStyle,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: const Color(0xFF6366F1).withOpacity(0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.document_scanner_rounded,
                  color: Color(0xFF6366F1),
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                'freeOCR.me',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                  color: colorScheme.onSurface,
                  fontFamily: 'Inter',
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Text(
          '© 2026 freeOCR.me • Privacy-First Ephemeral OCR Platform.\nAll rights reserved. Files processed in RAM disk.',
          style: linkStyle.copyWith(fontSize: 13, height: 1.5),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            IconButton(
              key: const Key('footer_social_twitter'),
              icon: const Icon(Icons.flutter_dash, size: 18),
              tooltip: 'Twitter / X',
              style: IconButton.styleFrom(
                padding: const EdgeInsets.all(8),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              onPressed: () => UrlHelper.openUrl(twitterUrl),
            ),
            const SizedBox(width: 8),
            IconButton(
              key: const Key('footer_social_linkedin'),
              icon: const Icon(Icons.business_center, size: 18),
              tooltip: 'LinkedIn',
              style: IconButton.styleFrom(
                padding: const EdgeInsets.all(8),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              onPressed: () => UrlHelper.openUrl(linkedinUrl),
            ),
            const SizedBox(width: 8),
            IconButton(
              key: const Key('footer_social_discord'),
              icon: const Icon(Icons.chat_bubble_outline, size: 18),
              tooltip: 'Discord Community',
              style: IconButton.styleFrom(
                padding: const EdgeInsets.all(8),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              onPressed: () => UrlHelper.openUrl(discordUrl),
            ),
          ],
        ),
      ],
    );
  }

  // --- Column 2: Navigation Links ---
  Widget _buildNavColumn(
    BuildContext context,
    TextStyle titleStyle,
    TextStyle linkStyle,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Navigation', style: titleStyle),
        const SizedBox(height: 14),
        InkWell(
          key: const Key('footer_home_btn'),
          onTap: () => _navigateTo(context, '/'),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4.0),
            child: Text('Home', style: linkStyle),
          ),
        ),
        InkWell(
          key: const Key('footer_kb_btn'),
          onTap: () => _navigateTo(context, '/kb'),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4.0),
            child: Text('Knowledge Base', style: linkStyle),
          ),
        ),
        InkWell(
          key: const Key('footer_docs_btn'),
          onTap: () => _navigateTo(context, '/docs'),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4.0),
            child: Text('API Docs', style: linkStyle),
          ),
        ),
      ],
    );
  }

  // --- Column 3: Open-Source Engine Attributions ---
  Widget _buildEnginesColumn(
    BuildContext context,
    ThemeData theme,
    ColorScheme colorScheme,
    TextStyle titleStyle,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Engines', style: titleStyle),
        const SizedBox(height: 14),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: [
            _buildEngineChip(
              context,
              label: "Baidu Unlimited OCR",
              url: baiduOcrUrl,
              key: const Key('chip_baiduocr'),
            ),
            _buildEngineChip(
              context,
              label: 'Tesseract OCR',
              url: tesseractUrl,
              key: const Key('chip_tesseract'),
            ),
            _buildEngineChip(
              context,
              label: 'OCRmyPDF',
              url: ocrmypdfUrl,
              key: const Key('chip_ocrmypdf'),
            ),
            _buildEngineChip(
              context,
              label: 'PyMuPDF',
              url: pymupdfUrl,
              key: const Key('chip_pymupdf'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildEngineChip(
    BuildContext context, {
    required String label,
    required String url,
    required Key key,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return ActionChip(
      key: key,
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 0),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      label: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: colorScheme.onSurface,
        ),
      ),
      onPressed: () => UrlHelper.openUrl(url),
      backgroundColor: isDark
          ? Colors.white.withOpacity(0.06)
          : colorScheme.surfaceContainer,
      side: BorderSide(
        color: isDark
            ? Colors.white.withOpacity(0.12)
            : const Color(0xFFCBD5E1),
        width: 0.8,
      ),
    );
  }

  // --- Column 4: Legal & Policy Links ---
  Widget _buildLegalColumn(
    BuildContext context,
    TextStyle titleStyle,
    TextStyle linkStyle,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Legal', style: titleStyle),
        const SizedBox(height: 14),
        InkWell(
          key: const Key('footer_privacy_btn'),
          onTap: () => _navigateTo(context, '/privacy'),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4.0),
            child: Text('Privacy Policy', style: linkStyle),
          ),
        ),
        InkWell(
          key: const Key('footer_terms_btn'),
          onTap: () => _navigateTo(context, '/terms'),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4.0),
            child: Text('Terms of Service', style: linkStyle),
          ),
        ),
      ],
    );
  }
}
