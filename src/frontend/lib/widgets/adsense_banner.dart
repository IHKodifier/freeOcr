import 'dart:async';
import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../utils/web_console.dart';


/// Configurable AdSense Display Ad Banner Container Widget
/// Fetches `ad_rotation_interval_seconds` dynamically from GET /api/v1/config.
/// Auto-rotates ad units periodically and pauses timer on tab switch / window blur.
class AdSenseBanner extends StatefulWidget {
  final double height;
  final double maxWidth;
  final int? overrideRotationSeconds;

  /// Global notifier to trigger immediate ad unit rotation on conversion stage events.
  static final ValueNotifier<int> rotationTrigger = ValueNotifier<int>(0);

  /// Global session counter preserving total ad unit rotations across route navigations.
  static int globalAdRefreshCount = 0;

  /// Reset global ad unit session count (for testing or fresh sessions).
  static void resetSessionCount() {
    globalAdRefreshCount = 0;
  }

  /// Trigger an immediate rotation of the AdSense banner (e.g. on file drop, upload, processing start, completion).
  static void rotateAd() {
    rotationTrigger.value++;
  }

  const AdSenseBanner({
    super.key,
    this.height = 90.0,
    this.maxWidth = 728.0,
    this.overrideRotationSeconds,
  });

  @override
  State<AdSenseBanner> createState() => AdSenseBannerState();
}

class AdSenseBannerState extends State<AdSenseBanner>
    with WidgetsBindingObserver, SingleTickerProviderStateMixin {
  int rotationIntervalSeconds = 35;
  Timer? _rotationTimer;
  int get adRefreshCount => AdSenseBanner.globalAdRefreshCount;
  bool isPaused = false;
  bool isLoadingConfig = true;

  late AnimationController _flashController;
  late Animation<double> _flashAnimation;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    AdSenseBanner.rotationTrigger.addListener(_onExternalRotationTriggered);

    _flashController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _flashAnimation = CurvedAnimation(
      parent: _flashController,
      curve: Curves.easeOut,
    );

    _initRotationConfig();
  }

  void _triggerFlashAnimation() {
    if (mounted) {
      _flashController.forward(from: 0.0);
    }
  }

  void _logRotation(String message) {
    debugPrint(message);
    print(message);
    developer.log(message, name: 'AdSenseBanner');
    logToBrowserConsole(message);
  }



  void _onExternalRotationTriggered() {
    if (mounted) {
      setState(() {
        isPaused = false;
        AdSenseBanner.globalAdRefreshCount++;
      });
      _triggerFlashAnimation();
      _logRotation('[AdSenseBanner] 🔄 Ad Rotated to Unit #${adRefreshCount + 1} (Reason: UI Stage Change / User Action - Drop/Upload/Processing/Download View)');
      _startTimer();
    }
  }

  Future<void> _initRotationConfig() async {
    if (widget.overrideRotationSeconds != null) {
      rotationIntervalSeconds = widget.overrideRotationSeconds!;
    } else {
      final interval = await ApiService.fetchAdRotationInterval(
        defaultInterval: 35,
      );
      if (mounted) {
        setState(() {
          rotationIntervalSeconds = interval;
          isLoadingConfig = false;
        });
      }
    }
    if (mounted) {
      setState(() {
        isLoadingConfig = false;
      });
      _logRotation('[AdSenseBanner] 🚀 Ad Mounted at Unit #${adRefreshCount + 1} (Interval: ${rotationIntervalSeconds}s)');
      _startTimer();
    }
  }

  void _startTimer() {
    _rotationTimer?.cancel();
    if (isPaused) return;

    _rotationTimer = Timer.periodic(
      Duration(seconds: rotationIntervalSeconds),
      (timer) {
        if (!isPaused && mounted) {
          setState(() {
            AdSenseBanner.globalAdRefreshCount++;
          });
          _triggerFlashAnimation();
          _logRotation('[AdSenseBanner] ⏱️ Ad Rotated to Unit #${adRefreshCount + 1} (Reason: ${rotationIntervalSeconds}s Auto-Rotation Timeout)');
        }
      },
    );
  }

  void pauseTimer() {
    setState(() {
      isPaused = true;
    });
    _rotationTimer?.cancel();
    _logRotation('[AdSenseBanner] ⏸️ Ad Auto-Rotation Timer Paused (Browser Tab Blurred/Hidden)');
  }

  void resumeTimer() {
    setState(() {
      isPaused = false;
    });
    _logRotation('[AdSenseBanner] ▶️ Ad Auto-Rotation Timer Resumed (Browser Tab Focused)');
    _startTimer();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      resumeTimer();
    } else if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.hidden) {
      pauseTimer();
    }
  }

  @override
  void dispose() {
    AdSenseBanner.rotationTrigger.removeListener(_onExternalRotationTriggered);
    WidgetsBinding.instance.removeObserver(this);
    _flashController.dispose();
    _rotationTimer?.cancel();
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
        final flashColor = theme.primaryColor;

        final containerBg = Color.lerp(
          isDark ? Colors.white.withOpacity(0.04) : Colors.black.withOpacity(0.02),
          flashColor.withOpacity(isDark ? 0.25 : 0.18),
          flashValue,
        );

        final borderColor = Color.lerp(
          isDark ? Colors.white.withOpacity(0.08) : Colors.black.withOpacity(0.06),
          flashColor.withOpacity(0.9),
          flashValue,
        )!;

        final borderWidth = 1.0 + (1.5 * flashValue);

        final boxShadowColor = Color.lerp(
          Colors.black.withOpacity(0.03),
          flashColor.withOpacity(0.4),
          flashValue,
        )!;

        return LayoutBuilder(
          builder: (context, constraints) {
            final screenWidth = MediaQuery.of(context).size.width;
            final effectiveWidth = constraints.maxWidth < screenWidth ? constraints.maxWidth : screenWidth;
            final isMobile = effectiveWidth < 550;
            final isVerySmall = effectiveWidth < 380;

            return Center(
              child: Container(
                key: const Key('adsense_banner_container'),
                constraints: BoxConstraints(
                  maxWidth: widget.maxWidth,
                  minHeight: widget.height,
                ),
                margin: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 12.0),
                decoration: BoxDecoration(
                  color: containerBg,
                  borderRadius: BorderRadius.circular(12.0),
                  border: Border.all(
                    color: borderColor,
                    width: borderWidth,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: boxShadowColor,
                      blurRadius: 10 + (12 * flashValue),
                      spreadRadius: 2 * flashValue,
                      offset: const Offset(0, 4),
                    ),
                  ],
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
                    // Ad Badge Icon & Dynamic Unit Counter
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
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
                        const SizedBox(height: 2),
                        Text(
                          'Unit #${adRefreshCount + 1}',
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            color: theme.primaryColor.withOpacity(0.8),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(width: isMobile ? 8 : 12),
                    // Ad Content with Responsive Wrap Layout
                    Expanded(
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        child: Column(
                          key: ValueKey('ad_unit_animated_$adRefreshCount'),
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
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6.0,
                                    vertical: 2.0,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isPaused
                                        ? Colors.orange.withOpacity(0.15)
                                        : Colors.green.withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(4.0),
                                  ),
                                  child: Text(
                                    isPaused
                                        ? 'Paused'
                                        : isMobile
                                            ? 'Auto (${rotationIntervalSeconds}s) • #${adRefreshCount}'
                                            : 'Auto-rotating (${rotationIntervalSeconds}s) • Rotations: #${adRefreshCount}',
                                    style: TextStyle(
                                      fontSize: 9,
                                      fontWeight: FontWeight.w500,
                                      color: isPaused ? Colors.orange : Colors.green,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              isMobile
                                  ? 'freeOCR.me is free & local-first (Unit #${adRefreshCount + 1})'
                                  : 'freeOCR.me is 100% free & local-first. Support open-source OCR by keeping ads enabled (Ad Unit #${adRefreshCount + 1}).',
                              key: ValueKey('ad_unit_key_$adRefreshCount'),
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


