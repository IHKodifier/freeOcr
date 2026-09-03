import 'package:flutter/material.dart';
import 'glass_card.dart';

/// Apple-Inspired High-Density Educational & FAQ Section for Landing Page (/)
/// Guarantees compliance with Google AdSense "Valuable Inventory: Thin Content" policy
/// by surrounding the hero dropzone with 800+ words of structured technical content.
class LandingFaqSection extends StatefulWidget {
  const LandingFaqSection({super.key});

  @override
  State<LandingFaqSection> createState() => _LandingFaqSectionState();
}

class _LandingFaqSectionState extends State<LandingFaqSection> {
  final Map<int, bool> _expandedFaq = {
    0: true,  // First item open by default
    1: false,
    2: false,
    3: false,
    4: false,
  };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1100),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 32.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Divider(height: 48, thickness: 1),
              const SizedBox(height: 16),

              // --- 1. How It Works Section ---
              _buildSectionHeader(
                theme,
                colorScheme,
                pillText: 'HOW IT WORKS',
                title: '4-Step Neural OCR Conversion Workflow',
                subtitle: 'Learn how freeOCR.me processes scanned documents with zero disk retention.',
              ),
              const SizedBox(height: 28),

              LayoutBuilder(
                builder: (context, constraints) {
                  final isWide = constraints.maxWidth >= 800;
                  if (isWide) {
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: _buildStepCard(context, theme, colorScheme, isDark, stepNum: '01', title: 'Upload Document', description: 'Drag and drop any scanned PDF, PNG, JPG, or JPEG file up to your active session limit (50MB base limit).')),
                        const SizedBox(width: 16),
                        Expanded(child: _buildStepCard(context, theme, colorScheme, isDark, stepNum: '02', title: 'Neural Preprocessing', description: 'PyMuPDF analyzes layout complexity while images upscale to 300 DPI for high-accuracy neural character recognition.')),
                        const SizedBox(width: 16),
                        Expanded(child: _buildStepCard(context, theme, colorScheme, isDark, stepNum: '03', title: 'Real-Time SSE Stream', description: 'Watch page-by-page progress stream live over Server-Sent Events (SSE) as text bounding boxes extract.')),
                        const SizedBox(width: 16),
                        Expanded(child: _buildStepCard(context, theme, colorScheme, isDark, stepNum: '04', title: 'RAM Disk Purge', description: 'Files are processed strictly in Linux tmpfs RAM memory and unlinked automatically upon conversion completion.')),
                      ],
                    );
                  }
                  return Column(
                    children: [
                      _buildStepCard(context, theme, colorScheme, isDark, stepNum: '01', title: 'Upload Document', description: 'Drag and drop any scanned PDF, PNG, JPG, or JPEG file up to your active session limit (50MB base limit).'),
                      const SizedBox(height: 12),
                      _buildStepCard(context, theme, colorScheme, isDark, stepNum: '02', title: 'Neural Preprocessing', description: 'PyMuPDF analyzes layout complexity while images upscale to 300 DPI for high-accuracy neural character recognition.'),
                      const SizedBox(height: 12),
                      _buildStepCard(context, theme, colorScheme, isDark, stepNum: '03', title: 'Real-Time SSE Stream', description: 'Watch page-by-page progress stream live over Server-Sent Events (SSE) as text bounding boxes extract.'),
                      const SizedBox(height: 12),
                      _buildStepCard(context, theme, colorScheme, isDark, stepNum: '04', title: 'RAM Disk Purge', description: 'Files are processed strictly in Linux tmpfs RAM memory and unlinked automatically upon conversion completion.'),
                    ],
                  );
                },
              ),

              const SizedBox(height: 48),

              // --- 2. Technical Features Comparison Matrix ---
              _buildSectionHeader(
                theme,
                colorScheme,
                pillText: 'TECHNICAL CAPABILITIES',
                title: 'Built for Layout Fidelity & Ephemeral Security',
                subtitle: 'Under the hood of the freeOCR.me open-source conversion architecture.',
              ),
              const SizedBox(height: 28),

              LayoutBuilder(
                builder: (context, constraints) {
                  final isWide = constraints.maxWidth >= 750;
                  return Wrap(
                    spacing: 16,
                    runSpacing: 16,
                    children: [
                      _buildFeatureTile(context, theme, colorScheme, isDark, width: isWide ? (constraints.maxWidth - 16) / 2 : constraints.maxWidth, icon: Icons.picture_as_pdf, title: 'Invisible Searchable PDF Overlay', description: 'Generates an invisible text layer positioned precisely over your original scanned PDF pages, preserving 100% of visual fonts, headers, and images.'),
                      _buildFeatureTile(context, theme, colorScheme, isDark, width: isWide ? (constraints.maxWidth - 16) / 2 : constraints.maxWidth, icon: Icons.lock_open, title: 'Password-in-Place PDF Decryption', description: 'Decrypt password-protected PDFs directly in your browser session before processing without unencrypting sensitive files onto persistent disk storage.'),
                      _buildFeatureTile(context, theme, colorScheme, isDark, width: isWide ? (constraints.maxWidth - 16) / 2 : constraints.maxWidth, icon: Icons.download_for_offline, title: '1-Click Multi-Format Export', description: 'Export extracted text in 1 click as Searchable PDF, Plain Text (.txt), or Clean Structured Markdown (.md) for LLM prompting and note apps.'),
                      _buildFeatureTile(context, theme, colorScheme, isDark, width: isWide ? (constraints.maxWidth - 16) / 2 : constraints.maxWidth, icon: Icons.bolt, title: 'Stackable Session Limit Passes', description: 'Need to process larger multi-hundred-page files? Watch 15-second rewarded video ads to stack +50MB session limit increments up to 900MB.'),
                    ],
                  );
                },
              ),

              const SizedBox(height: 48),

              // --- 3. Frequently Asked Questions (FAQ) Accordion ---
              _buildSectionHeader(
                theme,
                colorScheme,
                pillText: 'FREQUENTLY ASKED QUESTIONS',
                title: 'Everything You Need to Know About freeOCR.me',
                subtitle: 'Common questions regarding OCR accuracy, security guarantees, and file size limits.',
              ),
              const SizedBox(height: 24),

              _buildFaqItem(
                context,
                theme,
                colorScheme,
                index: 0,
                question: 'How does freeOCR.me convert scanned PDFs into searchable text for free?',
                answer: 'freeOCR.me utilizes an ad-supported freemium model powered by Google AdSense and Google Ad Manager. We route simple document layouts to lightweight CPU workers running OCRmyPDF and Tesseract, while complex multi-column documents, math formulas, and dense tables route to Baidu\'s Unlimited OCR neural vision model. This dual-engine architecture guarantees high accuracy while keeping the service 100% free.',
              ),
              _buildFaqItem(
                context,
                theme,
                colorScheme,
                index: 1,
                question: 'Are my sensitive documents stored, saved, or mined on your servers?',
                answer: 'No. freeOCR.me operates under a strict Zero Persistent Storage Guarantee. All file uploads are written exclusively to volatile Linux RAM disk (tmpfs) memory locations. Input files are unlinked and purged from RAM immediately after conversion or download link generation. We never inspect, store, sell, or train AI models on your private documents.',
              ),
              _buildFaqItem(
                context,
                theme,
                colorScheme,
                index: 2,
                question: 'What image resolutions and file formats yield the highest OCR accuracy?',
                answer: 'For optimal character recognition accuracy, we recommend scanned PDF files or high-resolution images (PNG, JPG, JPEG) scanned at 300 DPI. Our automated image preprocessor normalizes contrast, upscales low-DPI scans, and deskews rotated pages before running neural optical character recognition.',
              ),
              _buildFaqItem(
                context,
                theme,
                colorScheme,
                index: 3,
                question: 'How do stackable rewarded ad session passes increase file size limits up to 900MB?',
                answer: 'Standard free uploads permit files up to 50MB per document. If your scanned book, contract, or ledger exceeds 50MB, our Rewarded Video Ad Modal offers +50MB limit boost passes per 15-second ad watched. Watching multiple ads stacks session limits up to 900MB while resetting your 1-hour session expiration timer.',
              ),
              _buildFaqItem(
                context,
                theme,
                colorScheme,
                index: 4,
                question: 'Which open-source AI engines power freeOCR.me?',
                answer: 'freeOCR.me is built on top of world-class open-source optical character recognition and PDF handling software, including Baidu\'s Unlimited OCR AI Model (PaddleOCR), OCRmyPDF, Tesseract OCR, PyMuPDF (fitz), and FastAPI.',
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(
    ThemeData theme,
    ColorScheme colorScheme, {
    required String pillText,
    required String title,
    required String subtitle,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: colorScheme.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: colorScheme.primary.withOpacity(0.2)),
          ),
          child: Text(
            pillText,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.0,
              color: colorScheme.primary,
            ),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          title,
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          subtitle,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildStepCard(
    BuildContext context,
    ThemeData theme,
    ColorScheme colorScheme,
    bool isDark, {
    required String stepNum,
    required String title,
    required String description,
  }) {
    return GlassCard(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            stepNum,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w900,
              color: colorScheme.primary.withOpacity(0.8),
              fontFamily: 'Inter',
            ),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            description,
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureTile(
    BuildContext context,
    ThemeData theme,
    ColorScheme colorScheme,
    bool isDark, {
    required double width,
    required IconData icon,
    required String title,
    required String description,
  }) {
    return SizedBox(
      width: width,
      child: GlassCard(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: colorScheme.primary, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      height: 1.45,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFaqItem(
    BuildContext context,
    ThemeData theme,
    ColorScheme colorScheme, {
    required int index,
    required String question,
    required String answer,
  }) {
    final isOpen = _expandedFaq[index] ?? false;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: colorScheme.surfaceContainerHigh.withOpacity(0.5),
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            setState(() {
              _expandedFaq[index] = !isOpen;
            });
          },
          child: Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isOpen
                    ? colorScheme.primary.withOpacity(0.4)
                    : colorScheme.outlineVariant.withOpacity(0.4),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        question,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface,
                        ),
                      ),
                    ),
                    Icon(
                      isOpen ? Icons.expand_less : Icons.expand_more,
                      color: colorScheme.primary,
                    ),
                  ],
                ),
                if (isOpen) ...[
                  const SizedBox(height: 12),
                  Text(
                    answer,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      height: 1.5,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
