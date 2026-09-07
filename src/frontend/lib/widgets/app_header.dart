import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../utils/url_helper.dart';

/// Reusable Apple-inspired AppHeader with Navigation & Theme Toggle
/// Governed by docs/DESIGN.md & Stitch Screen 01 (freeOCR.me Scanner Logo)
class AppHeader extends StatelessWidget implements PreferredSizeWidget {
  final String currentRoute;
  final VoidCallback? onThemeToggle;

  const AppHeader({
    super.key,
    this.currentRoute = '/',
    this.onThemeToggle,
  });

  @override
  Size get preferredSize => const Size.fromHeight(64);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final navTextStyle = TextStyle(
      fontSize: 13,
      fontWeight: FontWeight.w600,
      color: theme.colorScheme.onSurface,
    );

    final activeNavStyle = TextStyle(
      fontSize: 13,
      fontWeight: FontWeight.w700,
      color: theme.colorScheme.primary,
    );

    final headerContent = SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
        child: Row(
          children: [
            if (Navigator.canPop(context)) ...[
              IconButton(
                icon: const Icon(Icons.arrow_back_rounded, size: 20),
                tooltip: 'Back',
                onPressed: () => Navigator.pop(context),
              ),
              const SizedBox(width: 4),
            ],
            // --- Brand Logo & Scanner Icon ---
            InkWell(
              onTap: () {
                if (currentRoute != '/') {
                  Navigator.of(context).pushNamed('/');
                }
              },
              borderRadius: BorderRadius.circular(8),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ClipRRect(
                    key: const Key('header_brand_logo'),
                    borderRadius: BorderRadius.circular(8),
                    child: Image.asset(
                      'assets/images/brand_logo_icon.png',
                      width: 32,
                      height: 32,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        if (kIsWeb) {
                          return Image.network(
                            'favicon.png',
                            width: 32,
                            height: 32,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: const Color(0xFF6366F1).withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: const Color(0xFF6366F1).withValues(alpha: 0.3),
                                  width: 1,
                                ),
                              ),
                              child: const Icon(
                                Icons.document_scanner_rounded,
                                color: Color(0xFF6366F1),
                                size: 20,
                              ),
                            ),
                          );
                        }
                        return Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: const Color(0xFF6366F1).withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: const Color(0xFF6366F1).withValues(alpha: 0.3),
                              width: 1,
                            ),
                          ),
                          child: const Icon(
                            Icons.document_scanner_rounded,
                            color: Color(0xFF6366F1),
                            size: 20,
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  RichText(
                    text: TextSpan(
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5,
                        color: theme.colorScheme.onSurface,
                        fontFamily: 'Inter',
                      ),
                      children: const [
                        TextSpan(text: 'freeOCR'),
                        TextSpan(
                          text: '.me',
                          style: TextStyle(color: Color(0xFF6366F1)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const Spacer(),

            // --- Desktop / Mobile Navigation Row ---
            LayoutBuilder(
              builder: (context, constraints) {
                final isMobile = MediaQuery.of(context).size.width < 640;
                if (isMobile) {
                  return Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      PopupMenuButton<String>(
                        icon: Icon(Icons.menu_rounded, color: theme.colorScheme.onSurface),
                        onSelected: (route) {
                          if (currentRoute != route) {
                            Navigator.of(context).pushNamed(route);
                          }
                        },
                        itemBuilder: (context) => [
                          const PopupMenuItem(
                            value: '/',
                            child: Text('Home'),
                          ),
                          const PopupMenuItem(
                            value: '/kb',
                            child: Text('Knowledge Base'),
                          ),
                          const PopupMenuItem(
                            value: '/docs',
                            child: Text('API Docs'),
                          ),
                        ],
                      ),
                      const SizedBox(width: 4),
                      _buildThemeToggleButton(context, isDark),
                    ],
                  );
                }

                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextButton(
                      key: const Key('header_home_btn'),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      onPressed: () {
                        if (currentRoute != '/') {
                          Navigator.of(context).pushNamed('/');
                        }
                      },
                      child: Text(
                        'Home',
                        style: currentRoute == '/' ? activeNavStyle : navTextStyle,
                      ),
                    ),
                    const SizedBox(width: 4),
                    TextButton(
                      key: const Key('header_kb_btn'),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      onPressed: () {
                        if (currentRoute != '/kb') {
                          Navigator.of(context).pushNamed('/kb');
                        }
                      },
                      child: Text(
                        'Knowledge Base',
                        style: currentRoute.startsWith('/kb') ? activeNavStyle : navTextStyle,
                      ),
                    ),
                    const SizedBox(width: 4),
                    TextButton(
                      key: const Key('header_docs_btn'),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      onPressed: () {
                        if (currentRoute != '/docs') {
                          Navigator.of(context).pushNamed('/docs');
                        }
                      },
                      child: Text(
                        'API Docs',
                        style: currentRoute == '/docs' ? activeNavStyle : navTextStyle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    _buildThemeToggleButton(context, isDark),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );

    return Container(
      decoration: BoxDecoration(
        color: isDark
            ? (kIsWeb ? const Color(0xFF0F172A) : const Color.fromRGBO(15, 23, 42, 0.85))
            : (kIsWeb ? const Color(0xFFF8FAFC) : const Color.fromRGBO(248, 250, 252, 0.85)),
        border: Border(
          bottom: BorderSide(
            color: isDark
                ? const Color.fromRGBO(255, 255, 255, 0.10)
                : const Color.fromRGBO(0, 0, 0, 0.08),
            width: 1.0,
          ),
        ),
      ),
      child: ClipRect(
        child: kIsWeb
            ? headerContent
            : BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 16.0, sigmaY: 16.0),
                child: headerContent,
              ),
      ),
    );
  }

  Widget _buildThemeToggleButton(BuildContext context, bool isDark) {
    return IconButton(
      key: const Key('header_theme_toggle_btn'),
      tooltip: isDark ? 'Switch to Light Mode' : 'Switch to Dark Mode',
      onPressed: onThemeToggle,
      constraints: const BoxConstraints(),
      padding: const EdgeInsets.all(8),
      style: IconButton.styleFrom(
        backgroundColor: isDark
            ? Colors.white.withOpacity(0.1)
            : const Color(0xFF6366F1).withOpacity(0.08),
      ),
      icon: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        transitionBuilder: (child, anim) => RotationTransition(
          turns: anim,
          child: ScaleTransition(scale: anim, child: child),
        ),
        child: Icon(
          isDark ? Icons.wb_sunny_rounded : Icons.nightlight_round,
          key: ValueKey(isDark),
          color: isDark ? const Color(0xFFF59E0B) : const Color(0xFF6366F1),
          size: 18,
        ),
      ),
    );
  }
}
