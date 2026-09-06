import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Reusable Apple-inspired Frosted Glassmorphism Card Container
/// Adheres strictly to docs/DESIGN.md & Google Stitch design system specifications
class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;
  final double borderRadius;
  final VoidCallback? onTap;
  final Color? borderColor;
  final Color? backgroundColor;

  const GlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(20.0),
    this.margin = EdgeInsets.zero,
    this.borderRadius = 16.0,
    this.onTap,
    this.borderColor,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final defaultBackground = backgroundColor ??
        (isDark
            ? (kIsWeb ? const Color(0xFF1E293B) : const Color.fromRGBO(30, 41, 59, 0.75))
            : (kIsWeb ? Colors.white : const Color.fromRGBO(255, 255, 255, 0.85)));

    final defaultBorder = borderColor ??
        (isDark
            ? const Color.fromRGBO(255, 255, 255, 0.12)
            : const Color.fromRGBO(0, 0, 0, 0.08));

    Widget cardContent = Container(
      padding: padding,
      decoration: BoxDecoration(
        color: defaultBackground,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(color: defaultBorder, width: 1.0),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withOpacity(0.3)
                : const Color.fromRGBO(99, 102, 241, 0.06),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: child,
    );

    // Apply frosted glass blur filter (bypassed on Web where BackdropFilter causes white buffer blowout on zoom)
    Widget glassWidget;
    if (kIsWeb) {
      glassWidget = ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: cardContent,
      );
    } else {
      glassWidget = ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 16.0, sigmaY: 16.0),
          child: cardContent,
        ),
      );
    }

    if (margin != EdgeInsets.zero) {
      glassWidget = Padding(
        padding: margin,
        child: glassWidget,
      );
    }

    if (onTap != null) {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(borderRadius),
        child: glassWidget,
      );
    }

    return glassWidget;
  }
}
