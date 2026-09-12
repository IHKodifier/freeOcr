import 'package:flutter/material.dart';

/// AdSense Display Ad Banner Container Widget
/// 100% Google AdSense Policy Compliant:
/// - Static display container adhering strictly to Google AdSense guidelines.
/// - No client-side rotation, no automated timers, and no artificial impression generation.
class AdSenseBanner extends StatelessWidget {
  final double height;
  final double maxWidth;

  /// Retained as safe no-ops for API compatibility with existing callers.
  static void resetSessionCount() {}
  static void rotateAd() {}

  const AdSenseBanner({
    super.key,
    this.height = 90.0,
    this.maxWidth = 728.0,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = MediaQuery.of(context).size.width;
        final effectiveWidth = constraints.maxWidth < screenWidth ? constraints.maxWidth : screenWidth;
        final isMobile = effectiveWidth < 550;
        final isVerySmall = effectiveWidth < 380;

        final borderColor = isDark ? Colors.white.withOpacity(0.12) : const Color(0xFFCBD5E1);

        return Center(
          child: Container(
            key: const Key('adsense_banner_container'),
            constraints: BoxConstraints(
              maxWidth: maxWidth,
              minHeight: height,
            ),
            margin: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 12.0),
            decoration: BoxDecoration(
              color: isDark ? Colors.white.withOpacity(0.02) : const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(12.0),
              border: Border.all(
                color: borderColor,
                width: 1.0,
              ),
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: isMobile ? 10.0 : 16.0,
                vertical: isMobile ? 8.0 : 12.0,
              ),
              child: Row(
                children: [
                  // Ad Badge Icon
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                    decoration: BoxDecoration(
                      color: theme.primaryColor.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(6.0),
                    ),
                    child: Text(
                      'AD',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: theme.primaryColor,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ),
                  SizedBox(width: isMobile ? 8 : 12),
                  // Sponsored Label and Attribution
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Wrap(
                          alignment: WrapAlignment.spaceBetween,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          spacing: 8.0,
                          runSpacing: 4.0,
                          children: [
                            Text(
                              isVerySmall ? 'Sponsored' : 'Sponsored Advertisement',
                              style: theme.textTheme.bodySmall?.copyWith(
                                fontWeight: FontWeight.w600,
                                fontSize: isVerySmall ? 10 : 11,
                                color: isDark ? Colors.white70 : Colors.black87,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          isMobile
                              ? 'freeOCR.me is free & local-first. Supported by AdSense.'
                              : 'freeOCR.me is 100% free & local-first. Ephemeral document synthesis supported by Google AdSense.',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontSize: 10,
                            color: isDark ? Colors.white38 : Colors.black45,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
