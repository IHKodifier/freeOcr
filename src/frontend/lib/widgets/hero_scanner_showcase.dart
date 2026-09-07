import 'package:flutter/material.dart';

/// HeroScannerShowcase
///
/// Implements the right-hand column showcase card from the Stitch
/// "freeOCR.me - 2-Column Hero Landing Page" design.
/// Displays the 3D neural scanner illustration with real-time status pill
/// and dual architectural / accuracy metric feature badges.
class HeroScannerShowcase extends StatelessWidget {
  const HeroScannerShowcase({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final cardBg = isDark
        ? const Color(0xFF1E293B).withOpacity(0.9)
        : Colors.white.withOpacity(0.95);
    final borderColor = isDark
        ? Colors.white.withOpacity(0.12)
        : const Color(0xFFCBD5E1).withOpacity(0.5);
    final chipBg = isDark
        ? const Color(0xFF0F172A).withOpacity(0.6)
        : const Color(0xFFF1F5F9);
    final chipBorder = isDark
        ? Colors.white.withOpacity(0.08)
        : const Color(0xFFE2E8F0);

    return Container(
      constraints: const BoxConstraints(maxWidth: 520),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(20.0),
        border: Border.all(color: borderColor, width: 1.0),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withOpacity(0.4)
                : const Color(0xFF6366F1).withOpacity(0.08),
            blurRadius: 28,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header: Status Indicator + Live Badge
          Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: const BoxDecoration(
                        color: Color(0xFF10B981),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Color(0x6610B981),
                            blurRadius: 6,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'NEURAL OCR ENGINE',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.8,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF6366F1).withOpacity(0.12),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFF6366F1).withOpacity(0.25),
                      width: 1,
                    ),
                  ),
                  child: const Text(
                    'File Size up to 1 GB',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF6366F1),
                    ),
                  ),
                ),
              ],
            ),
          ),

          Divider(height: 1, thickness: 1, color: borderColor),
          const SizedBox(height: 12),

          // Center Image Showcase
          ClipRRect(
            borderRadius: BorderRadius.circular(14.0),
            child: Container(
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
                border: Border.all(color: borderColor, width: 1.0),
                borderRadius: BorderRadius.circular(14.0),
              ),
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: Image.asset(
                  'assets/images/hero_scanner_3d.png',
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Center(
                      child: Icon(
                        Icons.document_scanner_rounded,
                        size: 64,
                        color: const Color(0xFF6366F1).withOpacity(0.5),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Bottom Dual Feature Chips
          Row(
            children: [
              Expanded(
                child: _buildMetricCard(
                  chipBg: chipBg,
                  chipBorder: chipBorder,
                  theme: theme,
                  tag: 'RAM-DISK SECURITY',
                  title: 'Zero File Retention',
                  subtitle: 'Auto-purged post OCR',
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildMetricCard(
                  chipBg: chipBg,
                  chipBorder: chipBorder,
                  theme: theme,
                  tag: 'DUAL-LAYER PDF',
                  title: 'Searchable & Selectable',
                  subtitle: 'Full text + layout fidelity',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCard({
    required Color chipBg,
    required Color chipBorder,
    required ThemeData theme,
    required String tag,
    required String title,
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: chipBg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: chipBorder, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            tag,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: Color(0xFF6366F1),
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 11,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
