import 'package:flutter/material.dart';

class ToolCard extends StatefulWidget {
  final String id;
  final String name;
  final String description;
  final String category;
  final String route;
  final IconData icon;
  final String? badge;
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
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          transform: _isHovered
              ? (Matrix4.identity()..translateByDouble(0.0, -4.0, 0.0, 1.0))
              : Matrix4.identity(),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: isDark
                ? (_isHovered ? const Color(0xFF1E293B) : const Color(0xFF0F172A).withValues(alpha: 0.85))
                : (_isHovered ? Colors.white : Colors.white.withValues(alpha: 0.9)),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: _isHovered
                  ? primaryColor.withValues(alpha: 0.4)
                  : (isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.06)),
              width: _isHovered ? 1.5 : 1.0,
            ),
            boxShadow: [
              if (_isHovered)
                BoxShadow(
                  color: primaryColor.withValues(alpha: isDark ? 0.25 : 0.12),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                )
              else
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.15 : 0.03),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Icon container
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: _getIconGradient(widget.category, primaryColor),
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: _getIconGradient(widget.category, primaryColor).first.withValues(alpha: 0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Icon(
                      widget.icon,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const Spacer(),
                  if (widget.badge != null) _buildBadge(widget.badge!),
                ],
              ),
              const SizedBox(height: 14),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.name,
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.3,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    widget.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13,
                      height: 1.4,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      _formatCategory(widget.category),
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.arrow_forward_rounded,
                    size: 16,
                    color: _isHovered ? primaryColor : Colors.grey.withValues(alpha: 0.5),
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
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: fg.withValues(alpha: 0.3), width: 1),
      ),
      child: Text(
        badge.toUpperCase(),
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: fg,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  List<Color> _getIconGradient(String category, Color primaryColor) {
    switch (category) {
      case 'page_ops':
        return [const Color(0xFF3B82F6), const Color(0xFF1D4ED8)];
      case 'security':
        return [const Color(0xFF10B981), const Color(0xFF047857)];
      case 'ai_conversions':
        return [const Color(0xFF8B5CF6), const Color(0xFF6D28D9)];
      default:
        return [primaryColor, primaryColor.withValues(alpha: 0.8)];
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
