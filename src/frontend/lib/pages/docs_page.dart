import 'package:flutter/material.dart';
import '../services/telemetry_service.dart';
import '../widgets/adsense_banner.dart';
import '../widgets/app_footer.dart';
import '../widgets/app_header.dart';
import '../widgets/glass_card.dart';
import '../main.dart' show themeNotifier;

/// Developer API Teaser Page (/docs)
/// Fully aligned with Google Stitch "freeOCR.me - Developer API Teaser" specification.
class DocsPage extends StatefulWidget {
  const DocsPage({super.key});

  @override
  State<DocsPage> createState() => _DocsPageState();
}

class _DocsPageState extends State<DocsPage> {
  final TextEditingController _emailController = TextEditingController();
  bool _submitted = false;

  @override
  void initState() {
    super.initState();
    TelemetryService.trackPageView('/docs', pageTitle: 'freeOCR.me — API Access Coming Soon');
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _handleSubscribe() {
    if (_emailController.text.trim().isNotEmpty) {
      setState(() {
        _submitted = true;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Thank you! You are on the Developer API early access list.'),
          backgroundColor: Color(0xFF6366F1),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppHeader(
        currentRoute: '/docs',
        onThemeToggle: () {
          themeNotifier.value = isDark ? ThemeMode.light : ThemeMode.dark;
        },
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1100),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 32.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // --- 1. Hero Section ---
                      _buildHeroBadge(context, isDark),
                      const SizedBox(height: 20),

                      Text(
                        'freeOCR.me Developer API',
                        style: TextStyle(
                          fontSize: 38,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -1.0,
                          color: colorScheme.onSurface,
                          fontFamily: 'Inter',
                          height: 1.15,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'API Access Coming Soon',
                        style: const TextStyle(
                          fontSize: 34,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.8,
                          color: Color(0xFF6366F1),
                          fontFamily: 'Inter',
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),

                      ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 680),
                        child: Text(
                          'High-throughput OCR, searchable PDF composition, and SSE status streaming for developers building document-heavy workflows.',
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                            height: 1.6,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),

                      const SizedBox(height: 36),

                      // --- 2. Roadmap Card & Code Teaser Container ---
                      _buildCodeTeaserCard(context, theme, colorScheme, isDark),

                      const SizedBox(height: 36),
                      const AdSenseBanner(),
                      const SizedBox(height: 48),

                      // --- 3. Core Capabilities (2x2 Bento Grid) ---
                      Text(
                        'Core Capabilities',
                        style: theme.textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.5,
                          color: colorScheme.onSurface,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),

                      LayoutBuilder(
                        builder: (context, constraints) {
                          final isWide = constraints.maxWidth > 700;

                          return GridView.count(
                            crossAxisCount: isWide ? 2 : 1,
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            crossAxisSpacing: 20,
                            mainAxisSpacing: 20,
                            childAspectRatio: isWide ? 1.5 : 1.1,
                            children: [
                              _buildBentoCard(
                                context,
                                icon: Icons.cloud_upload_rounded,
                                title: 'REST API Upload',
                                description:
                                    'Seamlessly push documents via standard REST endpoints with robust multipart/form-data support and generous file size limits.',
                              ),
                              _buildBentoCard(
                                context,
                                icon: Icons.sensors_rounded,
                                title: 'Real-Time SSE Stream',
                                description:
                                    'Subscribe to Server-Sent Events (SSE) to monitor the exact phase of document ingestion, parsing, and rendering in real-time.',
                              ),
                              _buildBentoCard(
                                context,
                                icon: Icons.mark_email_read_rounded,
                                title: 'Instant Email Dispatch',
                                description:
                                    'Configure automated routing to deliver fully processed, searchable PDFs directly to user inboxes upon completion.',
                              ),
                              _buildBentoCard(
                                context,
                                icon: Icons.code_rounded,
                                title: 'OpenAPI 3.0 Spec',
                                description:
                                    'Generate strongly typed clients in minutes using our comprehensive OpenAPI 3.0 specification, complete with mocked endpoints.',
                              ),
                            ],
                          );
                        },
                      ),

                      const SizedBox(height: 56),

                      // --- 4. Early Access CTA Section ---
                      _buildEarlyAccessCta(context, theme, colorScheme, isDark),
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

  // --- Top Hero Badge ---
  Widget _buildHeroBadge(BuildContext context, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
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
            ),
          ),
          const SizedBox(width: 8),
          Text(
            'Public Developer API — LAUNCHING POST-MVP',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: isDark ? const Color(0xFFA5B4FC) : const Color(0xFF4338CA),
            ),
          ),
        ],
      ),
    );
  }

  // --- Code Teaser Card (Stitch Spec) ---
  Widget _buildCodeTeaserCard(
    BuildContext context,
    ThemeData theme,
    ColorScheme colorScheme,
    bool isDark,
  ) {
    return GlassCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          // Mac Window Header Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withOpacity(0.04)
                  : const Color(0xFFE2E8F0),
              border: Border(
                bottom: BorderSide(
                  color: colorScheme.outlineVariant.withOpacity(0.3),
                ),
              ),
            ),
            child: Row(
              children: [
                Container(width: 10, height: 10, decoration: const BoxDecoration(color: Color(0xFFEF4444), shape: BoxShape.circle)),
                const SizedBox(width: 6),
                Container(width: 10, height: 10, decoration: const BoxDecoration(color: Color(0xFFF59E0B), shape: BoxShape.circle)),
                const SizedBox(width: 6),
                Container(width: 10, height: 10, decoration: const BoxDecoration(color: Color(0xFF10B981), shape: BoxShape.circle)),
                const SizedBox(width: 12),
                Text(
                  'POST /v1/process — Developer Teaser',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurfaceVariant,
                    fontFamily: 'JetBrains Mono',
                  ),
                ),
              ],
            ),
          ),

          // Code Teaser Grid Body
          LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth >= 700;

              if (isWide) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      flex: 5,
                      child: Padding(
                        padding: const EdgeInsets.all(28.0),
                        child: _buildTeaserFeaturesList(context, theme, colorScheme),
                      ),
                    ),
                    Expanded(
                      flex: 5,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: _buildTerminalCodeBox(context),
                      ),
                    ),
                  ],
                );
              }

              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: _buildTeaserFeaturesList(context, theme, colorScheme),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                    child: _buildTerminalCodeBox(context),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTeaserFeaturesList(BuildContext context, ThemeData theme, ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'The Next Generation of Document Processing',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w800,
            letterSpacing: -0.3,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 16),
        _buildCheckBullet('Asynchronous processing architecture for massive payloads.'),
        const SizedBox(height: 12),
        _buildCheckBullet('Automated webhook callbacks and SSE for real-time state.'),
        const SizedBox(height: 12),
        _buildCheckBullet('Native compositing of fully searchable PDF outputs.'),
      ],
    );
  }

  Widget _buildCheckBullet(String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(Icons.check_circle_rounded, color: Color(0xFF6366F1), size: 20),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 14,
              height: 1.4,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTerminalCodeBox(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: SelectableText(
        'POST /v1/process\n'
        'Authorization: Bearer dev_...\n\n'
        '{\n'
        '  "file_url": "s3://bucket/doc.pdf",\n'
        '  "features": ["text", "layout", "tables"],\n'
        '  "output": {\n'
        '    "formats": ["searchable_pdf", "json"],\n'
        '    "webhook_url": "https://app/callback"\n'
        '  }\n'
        '}',
        style: const TextStyle(
          fontFamily: 'JetBrains Mono',
          fontSize: 13,
          color: Color(0xFFC0C1FF),
          height: 1.5,
        ),
      ),
    );
  }

  // --- Bento Grid Capability Card ---
  Widget _buildBentoCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String description,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return GlassCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFF6366F1).withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: const Color(0xFF6366F1), size: 24),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 6),
          Expanded(
            child: Text(
              description,
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
                height: 1.4,
                fontSize: 13,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 4,
            ),
          ),
        ],
      ),
    );
  }

  // --- Early Access CTA Section ---
  Widget _buildEarlyAccessCta(
    BuildContext context,
    ThemeData theme,
    ColorScheme colorScheme,
    bool isDark,
  ) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 720),
      child: GlassCard(
        padding: const EdgeInsets.all(36.0),
        child: Column(
          children: [
            Text(
              'Get Early Access',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w800,
                color: colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Join the waitlist to receive your API keys and documentation access the moment we launch.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),

            if (!_submitted)
              LayoutBuilder(
                builder: (context, constraints) {
                  final isWide = constraints.maxWidth > 500;

                  if (isWide) {
                    return Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _emailController,
                            decoration: InputDecoration(
                              hintText: 'developer@company.com',
                              filled: true,
                              fillColor: isDark
                                  ? Colors.white.withOpacity(0.06)
                                  : const Color(0xFFF1F5F9),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(30),
                                borderSide: BorderSide(color: colorScheme.outlineVariant),
                              ),
                            ),
                            keyboardType: TextInputType.emailAddress,
                          ),
                        ),
                        const SizedBox(width: 12),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF6366F1),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            elevation: 2,
                          ),
                          onPressed: _handleSubscribe,
                          child: const Text('Notify Me at Launch', style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ],
                    );
                  }

                  return Column(
                    children: [
                      TextField(
                        controller: _emailController,
                        decoration: InputDecoration(
                          hintText: 'developer@company.com',
                          filled: true,
                          fillColor: isDark
                              ? Colors.white.withOpacity(0.06)
                              : const Color(0xFFF1F5F9),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: BorderSide(color: colorScheme.outlineVariant),
                          ),
                        ),
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF6366F1),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            elevation: 2,
                          ),
                          onPressed: _handleSubscribe,
                          child: const Text('Notify Me at Launch', style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  );
                },
              )
            else
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: Colors.green),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.check_circle, color: Colors.green),
                    SizedBox(width: 10),
                    Text(
                      'You are on the early-access waitlist!',
                      style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
