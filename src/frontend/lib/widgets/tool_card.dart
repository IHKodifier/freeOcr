import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../services/favorites_service.dart';
import 'semantic_pdf_icon.dart';

class ToolCard extends StatefulWidget {
  final String id;
  final String name;
  final String description;
  final String category;
  final String route;
  final IconData icon;
  final String? badge;
  final Color? color;
  final VoidCallback? onTap;

  const ToolCard({
    super.key,
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.route,
    required this.icon,
    this.badge,
    this.color,
    this.onTap,
  });

  @override
  State<ToolCard> createState() => _ToolCardState();
}

class _ToolCardState extends State<ToolCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryColor = theme.colorScheme.primary;
    final accentColor = widget.color ?? _getCategoryColor(widget.category, primaryColor);

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: () {
          if (widget.onTap != null) {
            widget.onTap!();
          } else {
            Navigator.of(context).pushNamed(widget.route);
          }
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOutCubic,
          transform: _isHovered
              ? (Matrix4.identity()..translateByDouble(0.0, -2.0, 0.0, 1.0))
              : Matrix4.identity(),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: isDark
                ? (_isHovered ? const Color(0xFF1E293B) : const Color(0xFF0F172A).withValues(alpha: 0.85))
                : (_isHovered ? Colors.white : Colors.white.withValues(alpha: 0.95)),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _isHovered
                  ? accentColor.withValues(alpha: 0.50)
                  : (isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.07)),
              width: _isHovered ? 1.5 : 1.0,
            ),
            boxShadow: [
              if (_isHovered)
                BoxShadow(
                  color: accentColor.withValues(alpha: isDark ? 0.20 : 0.10),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                )
              else
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.10 : 0.02),
                  blurRadius: 4,
                  offset: const Offset(0, 1),
                ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Semantic Outline Vector Icon Container
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: isDark ? (_isHovered ? 0.25 : 0.16) : (_isHovered ? 0.16 : 0.08)),
                  borderRadius: BorderRadius.circular(9),
                  border: Border.all(
                    color: accentColor.withValues(alpha: isDark ? 0.35 : 0.20),
                    width: 1,
                  ),
                ),
                alignment: Alignment.center,
                child: SemanticPdfIcon(
                  toolId: widget.id,
                  color: accentColor,
                  size: 22,
                ),
              ),
              const SizedBox(width: 10),
              // Tool Name
              Expanded(
                child: Text(
                  widget.name,
                  style: TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.2,
                    color: theme.colorScheme.onSurface,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              // Optional Badge (POPULAR, AI, etc.)
              if (widget.badge != null) ...[
                const SizedBox(width: 6),
                _buildBadge(widget.badge!),
              ],
              const SizedBox(width: 4),
              // Star / Favorite Toggle Button
              ValueListenableBuilder<Set<String>>(
                valueListenable: FavoritesService.favoritesNotifier,
                builder: (context, favorites, _) {
                  final isFav = favorites.contains(widget.id);
                  return Tooltip(
                    message: isFav ? 'Remove from favorites' : 'Add to favorites',
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: () {
                          FavoritesService.toggleFavorite(widget.id);
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(6.0),
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 200),
                            transitionBuilder: (child, anim) => ScaleTransition(scale: anim, child: child),
                            child: SemanticStarIcon(
                              key: ValueKey<bool>(isFav),
                              isFilled: isFav,
                              size: 19,
                              color: isFav
                                  ? const Color(0xFFF59E0B)
                                  : (isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B)),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBadge(String badge) {
    Color bg;
    Color fg;

    switch (badge.toUpperCase()) {
      case 'POPULAR':
        bg = const Color(0xFFF59E0B).withValues(alpha: 0.15);
        fg = const Color(0xFFD97706);
        break;
      case 'AI':
        bg = const Color(0xFF8B5CF6).withValues(alpha: 0.15);
        fg = const Color(0xFF7C3AED);
        break;
      case 'SECURITY':
        bg = const Color(0xFF10B981).withValues(alpha: 0.15);
        fg = const Color(0xFF059669);
        break;
      case 'NEW':
      default:
        bg = const Color(0xFF06B6D4).withValues(alpha: 0.15);
        fg = const Color(0xFF0891B2);
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: fg.withValues(alpha: 0.3), width: 1),
      ),
      child: Text(
        badge.toUpperCase(),
        style: TextStyle(
          fontSize: 9,
          fontWeight: FontWeight.w700,
          color: fg,
          letterSpacing: 0.4,
        ),
      ),
    );
  }

  Color _getCategoryColor(String category, Color primaryColor) {
    switch (category) {
      case 'page_ops':
        return const Color(0xFF4F46E5);
      case 'security':
        return const Color(0xFF0D9488);
      case 'ai_conversions':
        return const Color(0xFF8B5CF6);
      default:
        return primaryColor;
    }
  }
}

/// Pure vector star icon that never fails due to font glyph or unicode tree-shaking issues in Web/CanvasKit/HTML.
class SemanticStarIcon extends StatelessWidget {
  final bool isFilled;
  final Color color;
  final double size;

  const SemanticStarIcon({
    super.key,
    required this.isFilled,
    required this.color,
    this.size = 18,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _StarPainter(isFilled: isFilled, color: color),
      ),
    );
  }
}

class _StarPainter extends CustomPainter {
  final bool isFilled;
  final Color color;

  const _StarPainter({required this.isFilled, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final outerRadius = size.width * 0.48;
    final innerRadius = outerRadius * 0.42;

    final path = Path();
    const int points = 5;
    const double step = math.pi / points;
    double angle = -math.pi / 2;

    for (int i = 0; i < points * 2; i++) {
      final r = (i % 2 == 0) ? outerRadius : innerRadius;
      final x = cx + r * math.cos(angle);
      final y = cy + r * math.sin(angle);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
      angle += step;
    }
    path.close();

    if (isFilled) {
      final paint = Paint()
        ..color = color
        ..style = PaintingStyle.fill;
      canvas.drawPath(path, paint);
    } else {
      final strokePaint = Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.6
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round;
      canvas.drawPath(path, strokePaint);
    }
  }

  @override
  bool shouldRepaint(covariant _StarPainter oldDelegate) {
    return oldDelegate.isFilled != isFilled || oldDelegate.color != color;
  }
}

