import 'package:flutter/material.dart';

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
              ? (Matrix4.identity()..translateByDouble(0.0, -2.5, 0.0, 1.0))
              : Matrix4.identity(),
          padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 10),
          decoration: BoxDecoration(
            color: isDark
                ? (_isHovered ? const Color(0xFF1E293B) : const Color(0xFF0F172A).withValues(alpha: 0.85))
                : (_isHovered ? Colors.white : Colors.white.withValues(alpha: 0.95)),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _isHovered
                  ? accentColor.withValues(alpha: 0.45)
                  : (isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.06)),
              width: _isHovered ? 1.5 : 1.0,
            ),
            boxShadow: [
              if (_isHovered)
                BoxShadow(
                  color: accentColor.withValues(alpha: isDark ? 0.20 : 0.10),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                )
              else
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.12 : 0.02),
                  blurRadius: 4,
                  offset: const Offset(0, 1),
                ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top row: Icon container + Tool Name (Space 5) + Badge
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: accentColor.withValues(alpha: isDark ? (_isHovered ? 0.25 : 0.16) : (_isHovered ? 0.16 : 0.08)),
                      borderRadius: BorderRadius.circular(7),
                      border: Border.all(
                        color: accentColor.withValues(alpha: isDark ? 0.35 : 0.20),
                        width: 1,
                      ),
                    ),
                    child: Icon(
                      widget.icon,
                      color: accentColor,
                      size: 15,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      widget.name,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.2,
                        color: theme.colorScheme.onSurface,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (widget.badge != null) ...[
                    const SizedBox(width: 6),
                    _buildBadge(widget.badge!),
                  ],
                ],
              ),
              const SizedBox(height: 6),
              // Description (takes full height with zero clipping!)
              Expanded(
                child: Text(
                  widget.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11.5,
                    height: 1.35,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              // Bottom Row: Category & Arrow
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      _formatCategory(widget.category),
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w600,
                        color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  AnimatedSlide(
                    duration: const Duration(milliseconds: 150),
                    offset: _isHovered ? const Offset(0.2, 0) : Offset.zero,
                    child: Icon(
                      Icons.arrow_forward_rounded,
                      size: 13,
                      color: _isHovered ? accentColor : (isDark ? Colors.white38 : Colors.black38),
                    ),
                  ),
                ],
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

  String _formatCategory(String category) {
    switch (category) {
      case 'page_ops':
        return 'Page Operations';
      case 'security':
        return 'Security & Optimization';
      case 'ai_conversions':
        return 'AI & Conversions';
      default:
        return category;
    }
  }
}
