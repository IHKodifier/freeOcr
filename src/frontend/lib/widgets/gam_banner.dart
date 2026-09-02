import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'gam_js_interop.dart';

/// Google Ad Manager (GAM / AdX) GPT Banner Widget
/// Supports declared 31-second server-side ad refresh inventory slots
/// Compliant with Google Ad Manager policy via GPT `gpt.js` viewability focus listeners.
class GamBannerWidget extends StatefulWidget {
  final double height;
  final double maxWidth;
  final int autoRefreshSeconds;

  /// Global notifier to trigger immediate GAM slot refresh.
  static final ValueNotifier<int> refreshTrigger = ValueNotifier<int>(0);

  /// Global total refresh counter for GAM / AdX slots.
  static int globalRefreshCount = 0;

  /// Reset global counter (for testing or fresh sessions).
  static void resetSessionCount() {
    globalRefreshCount = 0;
  }

  /// Triggers a Google Ad Manager (GAM / AdX) slot refresh via gpt.js interop.
  static void refreshGamSlot() {
    refreshTrigger.value++;
    triggerGamAdSlotRefresh();
  }

  const GamBannerWidget({
    super.key,
    this.height = 90.0,
    this.maxWidth = 728.0,
    this.autoRefreshSeconds = 31,
  });

  @override
  State<GamBannerWidget> createState() => GamBannerWidgetState();
}

class GamBannerWidgetState extends State<GamBannerWidget>
    with WidgetsBindingObserver, SingleTickerProviderStateMixin {
  int get refreshCount => GamBannerWidget.globalRefreshCount;

  Timer? _refreshTimer;
  int _secondsUntilNextRefresh = 31;
  bool _isViewable = true;

  late AnimationController _flashController;
  late Animation<double> _flashAnimation;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    GamBannerWidget.refreshTrigger.addListener(_onExternalRefreshTriggered);

    _secondsUntilNextRefresh = widget.autoRefreshSeconds;

    _flashController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _flashAnimation = CurvedAnimation(
      parent: _flashController,
      curve: Curves.easeOut,
    );

    _startAutoRefreshTimer();
    debugPrint('[GamBannerWidget] 🚀 GAM GPT Banner Mounted (31s Declared Auto-Refresh Active)');
  }

  void _startAutoRefreshTimer() {
    _refreshTimer?.cancel();
    _refreshTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      if (!_isViewable) return; // Viewability observer: pause timer when hidden

      setState(() {
        if (_secondsUntilNextRefresh > 1) {
          _secondsUntilNextRefresh--;
        } else {
          _secondsUntilNextRefresh = widget.autoRefreshSeconds;
          GamBannerWidget.refreshGamSlot();
          debugPrint('[GamBannerWidget] 🔄 GAM Slot Auto-Refreshed (#$refreshCount)');
        }
      });
    });
  }

  void _triggerFlashAnimation() {
    if (mounted) {
      _flashController.forward(from: 0.0);
    }
  }

  void _onExternalRefreshTriggered() {
    if (mounted) {
      setState(() {
        GamBannerWidget.globalRefreshCount++;
        _secondsUntilNextRefresh = widget.autoRefreshSeconds;
      });
      _triggerFlashAnimation();
      debugPrint('[GamBannerWidget] ⚡ External GAM Refresh Triggered (#$refreshCount)');
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    final isResumed = state == AppLifecycleState.resumed;
    if (_isViewable != isResumed) {
      setState(() {
        _isViewable = isResumed;
      });
      debugPrint('[GamBannerWidget] Viewability state changed: viewable = $_isViewable');
    }
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    GamBannerWidget.refreshTrigger.removeListener(_onExternalRefreshTriggered);
    WidgetsBinding.instance.removeObserver(this);
    _flashController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return AnimatedBuilder(
      animation: _flashAnimation,
      builder: (context, child) {
        final flashValue = 1.0 - _flashAnimation.value;
        final flashColor = isDark ? Colors.amber : theme.primaryColor;

        final borderColor = Color.lerp(
          isDark ? Colors.amber.withValues(alpha: 0.25) : const Color(0xFFCBD5E1),
          flashColor.withValues(alpha: 0.9),
          flashValue,
        )!;

        final borderWidth = 1.0 + (1.5 * flashValue);

        return LayoutBuilder(
          builder: (context, constraints) {
            final screenWidth = MediaQuery.of(context).size.width;
            final effectiveWidth = constraints.maxWidth < screenWidth ? constraints.maxWidth : screenWidth;
            final isMobile = effectiveWidth < 550;
            final isVerySmall = effectiveWidth < 380;

            return Center(
              child: Container(
                key: const Key('gam_banner_container'),
                constraints: BoxConstraints(
                  maxWidth: widget.maxWidth,
                  minHeight: widget.height,
                ),
                margin: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 12.0),
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(12.0),
                  border: Border.all(
                    color: borderColor,
                    width: borderWidth,
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12.0),
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: isMobile ? 10.0 : 16.0,
                      vertical: isMobile ? 8.0 : 12.0,
                    ),
                    child: Row(
                      children: [
                        // GAM Badge & Countdown Ticker
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                              decoration: BoxDecoration(
                                color: isDark
                                    ? Colors.amber.withValues(alpha: 0.15)
                                    : theme.primaryColor.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(6.0),
                                border: Border.all(
                                  color: isDark
                                      ? Colors.amber.withValues(alpha: 0.3)
                                      : theme.primaryColor.withValues(alpha: 0.3),
                                ),
                              ),
                              child: Text(
                                'GAM / AdX',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: isDark ? Colors.amber : theme.primaryColor,
                                  letterSpacing: 0.8,
                                ),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.timer_outlined,
                                  size: 10,
                                  color: isDark ? Colors.amber.shade300 : theme.primaryColor,
                                ),
                                const SizedBox(width: 2),
                                Text(
                                  '${_secondsUntilNextRefresh}s',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: isDark ? Colors.amber.shade200 : theme.primaryColor,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        SizedBox(width: isMobile ? 8 : 12),
                        // Ad Content & GPT Container Simulation
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
                                    isVerySmall ? 'GAM AdX Ad' : 'Google Ad Manager (GAM / AdX) Leaderboard',
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      fontWeight: FontWeight.w600,
                                      fontSize: isVerySmall ? 10 : 11,
                                      color: isDark ? Colors.white70 : Colors.black87,
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6.0,
                                      vertical: 2.0,
                                    ),
                                    decoration: BoxDecoration(
                                      color: _isViewable
                                          ? Colors.green.withValues(alpha: 0.15)
                                          : Colors.orange.withValues(alpha: 0.15),
                                      borderRadius: BorderRadius.circular(4.0),
                                    ),
                                    child: Text(
                                      _isViewable
                                          ? 'Declared 31s Refresh • #$refreshCount'
                                          : 'Paused (Tab Hidden)',
                                      style: TextStyle(
                                        fontSize: 9,
                                        fontWeight: FontWeight.w500,
                                        color: _isViewable ? Colors.green : Colors.orange,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                isMobile
                                    ? 'Slot: /1234567/freeocr_leaderboard_728x90 (#$refreshCount)'
                                    : 'Slot: /1234567/freeocr_leaderboard_728x90 • GPT Single Request Mode (Refresh #$refreshCount)',
                                key: ValueKey('gam_unit_key_$refreshCount'),
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
                        // Refresh button
                        IconButton(
                          icon: const Icon(Icons.refresh_rounded, size: 18),
                          tooltip: 'Trigger Immediate GAM Refresh',
                          color: isDark ? Colors.amber : theme.primaryColor,
                          onPressed: () {
                            GamBannerWidget.refreshGamSlot();
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
