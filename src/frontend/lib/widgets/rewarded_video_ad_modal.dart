import 'dart:async';
import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../services/api_service.dart';

class RewardedVideoAdModal extends StatefulWidget {
  final String filename;
  final int fileSizeInBytes;
  final double currentLimitMb;
  final double boostPerAdMb;
  final double maxStackMb;
  final int adDurationSeconds;
  final Function(double boostedLimitMb) onWatchAd;
  final VoidCallback? onCancel;

  const RewardedVideoAdModal({
    super.key,
    required this.filename,
    required this.fileSizeInBytes,
    required this.currentLimitMb,
    this.boostPerAdMb = 50.0,
    this.maxStackMb = 1024.0,
    this.adDurationSeconds = 15,
    required this.onWatchAd,
    this.onCancel,
  });

  static Future<void> show({
    required BuildContext context,
    required String filename,
    required int fileSizeInBytes,
    required double currentLimitMb,
    double boostPerAdMb = 50.0,
    double maxStackMb = 1024.0,
    int adDurationSeconds = 15,
    required Function(double boostedLimitMb) onWatchAd,
    VoidCallback? onCancel,
  }) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withValues(alpha: 0.65),
      builder: (BuildContext dialogContext) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: RewardedVideoAdModal(
            filename: filename,
            fileSizeInBytes: fileSizeInBytes,
            currentLimitMb: currentLimitMb,
            boostPerAdMb: boostPerAdMb,
            maxStackMb: maxStackMb,
            adDurationSeconds: adDurationSeconds,
            onWatchAd: (boostedLimit) {
              Navigator.of(dialogContext).pop();
              onWatchAd(boostedLimit);
            },
            onCancel: () {
              Navigator.of(dialogContext).pop();
              if (onCancel != null) onCancel();
            },
          ),
        );
      },
    );
  }

  @override
  State<RewardedVideoAdModal> createState() => _RewardedVideoAdModalState();
}

class _RewardedVideoAdModalState extends State<RewardedVideoAdModal> {
  bool _isPlayingAd = false;
  bool _isSyncing = false;
  bool _isUnlockedSuccess = false;
  bool _isIntermediateMilestone = false;
  double _newLimitMb = 50.0;
  late double _currentActiveLimitMb;
  int _secondsRemaining = 15;
  int _completedAds = 0;
  late int _totalAdsRequired;
  Timer? _adTimer;

  @override
  void initState() {
    super.initState();
    _secondsRemaining = widget.adDurationSeconds;
    _currentActiveLimitMb = widget.currentLimitMb;
    _newLimitMb = widget.currentLimitMb;
    final double fileSizeMb = widget.fileSizeInBytes / (1024 * 1024);
    final double deficitMb = fileSizeMb - widget.currentLimitMb;
    _totalAdsRequired = deficitMb > 0 ? (deficitMb / widget.boostPerAdMb).ceil() : 1;
    if (_totalAdsRequired < 1) _totalAdsRequired = 1;
  }

  @override
  void dispose() {
    _adTimer?.cancel();
    super.dispose();
  }

  void _startAdPlayback() {
    setState(() {
      _isPlayingAd = true;
      _isSyncing = false;
      _isUnlockedSuccess = false;
      _isIntermediateMilestone = false;
      _secondsRemaining = widget.adDurationSeconds;
    });
    _resumeAdPlayback();
  }

  void _resumeAdPlayback() {
    _adTimer?.cancel();
    _adTimer = Timer.periodic(const Duration(seconds: 1), (timer) async {
      if (_secondsRemaining > 1) {
        if (mounted) {
          setState(() {
            _secondsRemaining--;
          });
        }
      } else {
        timer.cancel();
        if (mounted) {
          setState(() {
            _isPlayingAd = false;
            _isSyncing = true;
          });
        }

        // Negotiate boost pass with backend Redis
        _completedAds++;
        final res = await ApiService.notifyRewardedAdWatched();
        final double? returnedLimit = (res['boosted_max_file_mb'] as num?)?.toDouble();
        final double newLimit = (returnedLimit != null && returnedLimit > _currentActiveLimitMb)
            ? returnedLimit
            : (_currentActiveLimitMb + widget.boostPerAdMb);
        final double clampedLimit = newLimit > widget.maxStackMb ? widget.maxStackMb : newLimit;
        final double fileSizeMb = widget.fileSizeInBytes / (1024 * 1024);
        final bool isFullyUnlocked = clampedLimit >= fileSizeMb || clampedLimit >= widget.maxStackMb || _completedAds >= _totalAdsRequired;

        if (mounted) {
          setState(() {
            _isSyncing = false;
            _currentActiveLimitMb = clampedLimit;
            _newLimitMb = clampedLimit;
            _isUnlockedSuccess = isFullyUnlocked;
            _isIntermediateMilestone = !isFullyUnlocked;
          });
        }
      }
    });
  }

  void _confirmEarlyCancel() {
    // Pause ad timer immediately while warning dialog is visible!
    _adTimer?.cancel();

    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.amber),
            SizedBox(width: 8),
            Text('Forfeit Limit Boost?', style: TextStyle(color: Colors.white, fontSize: 18)),
          ],
        ),
        content: Text(
          _completedAds > 0
              ? 'Closing before completion forfeits this next boost (+${widget.boostPerAdMb.toInt()} MB). Your previously earned limit of ${_currentActiveLimitMb.toInt()} MB will remain active for your session.'
              : 'Closing before completion forfeits your limit boost reward. Are you sure you want to exit?',
          style: const TextStyle(color: Color(0xFFCBD5E1), fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              _resumeAdPlayback(); // Resume ad playback timer from remaining seconds
            },
            child: const Text('Resume Ad', style: TextStyle(color: Colors.amber, fontWeight: FontWeight.bold)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(ctx).pop(); // Close confirmation dialog
              _adTimer?.cancel();
              if (_completedAds > 0) {
                widget.onWatchAd(_currentActiveLimitMb);
              } else {
                widget.onCancel?.call();
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            child: const Text('Quit & Forfeit', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double fileSizeMb = widget.fileSizeInBytes / (1024 * 1024);
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    // Theme Color Tokens
    final Color modalBg = isDark
        ? const Color(0xFF0F172A).withValues(alpha: 0.94)
        : Colors.white.withValues(alpha: 0.96);

    final Color modalBorder = isDark
        ? (_isUnlockedSuccess
            ? Colors.greenAccent.withValues(alpha: 0.6)
            : Colors.amber.shade400.withValues(alpha: 0.4))
        : (_isUnlockedSuccess
            ? Colors.green.shade600
            : Colors.amber.shade700);

    final Color primaryText = isDark ? Colors.white : const Color(0xFF0F172A);
    final Color secondaryText = isDark ? const Color(0xFFCBD5E1) : const Color(0xFF475569);
    final Color labelText = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);

    final modalContainer = Container(
      constraints: const BoxConstraints(maxWidth: 530),
          decoration: BoxDecoration(
            color: modalBg,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: modalBorder,
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: _isUnlockedSuccess
                    ? (isDark ? Colors.green.shade500.withValues(alpha: 0.2) : Colors.green.shade300.withValues(alpha: 0.3))
                    : (isDark ? Colors.amber.shade500.withValues(alpha: 0.15) : Colors.amber.shade300.withValues(alpha: 0.2)),
                blurRadius: 30,
                spreadRadius: 2,
              ),
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.5 : 0.1),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          padding: const EdgeInsets.all(24),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (_isSyncing) ...[
                  // Syncing with Backend Progress View
                  Container(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      children: [
                        const CircularProgressIndicator(color: Colors.amber),
                        const SizedBox(height: 20),
                        Text(
                          'Synchronizing Limit Boost...',
                          style: TextStyle(color: primaryText, fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Negotiating session limits with backend...',
                          style: TextStyle(color: isDark ? Colors.cyan.shade200 : const Color(0xFF0284C7), fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ] else if (_isUnlockedSuccess) ...[
                  // Success Confirmation Card with Detailed Boost Info
                  Container(
                    padding: const EdgeInsets.all(22),
                    decoration: BoxDecoration(
                      color: isDark
                          ? const Color(0xFF0F291E).withValues(alpha: 0.9)
                          : const Color(0xFFECFDF5),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isDark
                            ? Colors.greenAccent.withValues(alpha: 0.4)
                            : Colors.green.shade300,
                      ),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          Icons.check_circle_rounded,
                          size: 48,
                          color: isDark ? Colors.greenAccent : const Color(0xFF059669),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          '⚡ All Quotas Unlocked!',
                          style: TextStyle(
                            color: isDark ? Colors.white : const Color(0xFF064E3B),
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                          decoration: BoxDecoration(
                            color: isDark
                                ? Colors.greenAccent.withValues(alpha: 0.15)
                                : Colors.green.shade100,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isDark
                                  ? Colors.greenAccent.withValues(alpha: 0.3)
                                  : Colors.green.shade300,
                            ),
                          ),
                          child: Text(
                            'New Active Session Limit: Up to ${_newLimitMb.toInt()} MB per PDF',
                            style: TextStyle(
                              color: isDark ? Colors.greenAccent : const Color(0xFF047857),
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Explanatory Info Card
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: isDark
                                ? Colors.black.withValues(alpha: 0.35)
                                : Colors.white.withValues(alpha: 0.85),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isDark
                                  ? Colors.white.withValues(alpha: 0.08)
                                  : Colors.green.shade200,
                            ),
                          ),
                          child: Column(
                            children: [
                              _buildSuccessDetailRow(
                                isDark: isDark,
                                icon: Icons.timer_outlined,
                                title: '60-Minute Active Window',
                                subtitle:
                                    'Your boosted ${_newLimitMb.toInt()} MB limit is active for the next 60 minutes. Track your remaining boost time via the dropzone countdown.',
                              ),
                              Divider(color: isDark ? Colors.white12 : Colors.green.shade200, height: 16),
                              _buildSuccessDetailRow(
                                isDark: isDark,
                                icon: Icons.add_to_photos_outlined,
                                title: 'How to Request Higher Limits',
                                subtitle:
                                    'To request higher limits anytime, simply drop or select a PDF larger than your active limit (${_newLimitMb.toInt()} MB). The app will automatically prompt you to watch an ad for an instant boost.',
                              ),
                              Divider(color: isDark ? Colors.white12 : Colors.green.shade200, height: 16),
                              _buildSuccessDetailRow(
                                isDark: isDark,
                                icon: Icons.layers_outlined,
                                title: 'Stack Up to 1 GB (1,024 MB) + Session Renewal',
                                subtitle:
                                    'Each ad watch adds +50 MB per ad (up to 1,024 MB max) and resets your full 1-hour session window so you have plenty of time to process your files.',
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton.icon(
                          onPressed: () => widget.onWatchAd(_newLimitMb),
                          icon: const Icon(Icons.arrow_forward_rounded, size: 20),
                          label: const Text('Continue Processing File'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isDark ? Colors.greenAccent : const Color(0xFF059669),
                            foregroundColor: isDark ? Colors.black : Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                        ),
                      ],
                    ),
                  ),
                ] else if (_isIntermediateMilestone) ...[
                  // Intermediate Milestone Card: Ad X of Y Completed!
                  Container(
                    padding: const EdgeInsets.all(22),
                    decoration: BoxDecoration(
                      color: isDark
                          ? const Color(0xFF1E293B).withValues(alpha: 0.9)
                          : const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isDark ? Colors.amber.shade400.withValues(alpha: 0.4) : Colors.amber.shade600,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.playlist_add_check_circle_rounded,
                              size: 32,
                              color: isDark ? Colors.amber.shade400 : Colors.amber.shade700,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '⚡ Ad $_completedAds of $_totalAdsRequired Complete!',
                                    style: TextStyle(
                                      color: primaryText,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 17,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Limit boosted to ${_currentActiveLimitMb.toInt()} MB',
                                    style: TextStyle(
                                      color: isDark ? Colors.greenAccent : const Color(0xFF059669),
                                      fontWeight: FontWeight.w600,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        // Progress indicator
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: LinearProgressIndicator(
                            value: _completedAds / _totalAdsRequired,
                            minHeight: 8,
                            backgroundColor: isDark ? Colors.white12 : const Color(0xFFCBD5E1),
                            valueColor: const AlwaysStoppedAnimation<Color>(Colors.amber),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Progress: $_completedAds of $_totalAdsRequired Ads Completed (${((_completedAds / _totalAdsRequired) * 100).toInt()}%)',
                          style: TextStyle(color: secondaryText, fontSize: 12),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isDark ? Colors.black.withValues(alpha: 0.3) : const Color(0xFFFEF3C7),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isDark ? Colors.amber.withValues(alpha: 0.2) : Colors.amber.shade300,
                            ),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.info_outline_rounded, color: Colors.amber, size: 20),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  'Active limit boosted to ${_currentActiveLimitMb.toInt()} MB. Your file is ${fileSizeMb.toStringAsFixed(1)} MB, so ${_totalAdsRequired - _completedAds} more ad needed to unlock this file.',
                                  style: TextStyle(
                                    color: isDark ? Colors.white70 : const Color(0xFF78350F),
                                    fontSize: 12,
                                    height: 1.3,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton.icon(
                          onPressed: _startAdPlayback,
                          icon: const Icon(Icons.play_circle_fill_rounded, size: 20),
                          label: Text(
                            _totalAdsRequired - _completedAds == 1
                                ? 'Watch Final Ad (Ad ${_completedAds + 1} of $_totalAdsRequired) (+${widget.boostPerAdMb.toInt()} MB)'
                                : 'Watch Next Ad (Ad ${_completedAds + 1} of $_totalAdsRequired) (+${widget.boostPerAdMb.toInt()} MB)',
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isDark ? Colors.amber.shade500 : const Color(0xFFD97706),
                            foregroundColor: isDark ? Colors.black : Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                        ),
                        const SizedBox(height: 10),
                        TextButton(
                          onPressed: () => widget.onWatchAd(_currentActiveLimitMb),
                          style: TextButton.styleFrom(foregroundColor: secondaryText),
                          child: Text('Keep ${_currentActiveLimitMb.toInt()} MB Limit & Exit'),
                        ),
                      ],
                    ),
                  ),
                ] else if (_isPlayingAd) ...[
                  // Video Ad Simulation View with Dismiss Warning
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.black.withValues(alpha: 0.6)
                          : const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isDark
                            ? Colors.cyan.shade400.withValues(alpha: 0.5)
                            : Colors.cyan.shade700.withValues(alpha: 0.5),
                      ),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.play_circle_fill_rounded, color: Colors.amber, size: 22),
                                const SizedBox(width: 8),
                                Text(
                                  _totalAdsRequired > 1
                                      ? 'Sponsor Ad • Ad ${_completedAds + 1} of $_totalAdsRequired'
                                      : 'Sponsor Ad',
                                  style: TextStyle(
                                    color: isDark ? Colors.white70 : const Color(0xFF334155),
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                            IconButton(
                              onPressed: _confirmEarlyCancel,
                              icon: Icon(Icons.close_rounded, color: isDark ? Colors.white54 : const Color(0xFF64748B), size: 20),
                              tooltip: 'Close Ad (Forfeits Reward)',
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        const Icon(
                          Icons.ondemand_video_rounded,
                          size: 52,
                          color: Colors.amber,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          _totalAdsRequired > 1
                              ? 'Rewarded Video Sponsor Ad (Ad ${_completedAds + 1} of $_totalAdsRequired)'
                              : 'Rewarded Video Sponsor Ad',
                          style: TextStyle(
                            color: primaryText,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _totalAdsRequired > 1
                              ? 'Ad ${_completedAds + 1} of $_totalAdsRequired • Unlocking in $_secondsRemaining seconds...'
                              : 'Unlocking Limit Boost in $_secondsRemaining seconds...',
                          style: TextStyle(
                            color: isDark ? Colors.cyan.shade200 : const Color(0xFF0284C7),
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 16),
                        LinearProgressIndicator(
                          value: (widget.adDurationSeconds - _secondsRemaining) / widget.adDurationSeconds,
                          backgroundColor: isDark ? Colors.white12 : const Color(0xFFCBD5E1),
                          valueColor: const AlwaysStoppedAnimation<Color>(Colors.amber),
                        ),
                      ],
                    ),
                  ),
                ] else ...[
                  // Initial Invite Dialog
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.amber.shade500.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.warning_amber_rounded,
                          color: isDark ? Colors.amber.shade400 : Colors.amber.shade700,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'File Size Limit Exceeded',
                              style: TextStyle(
                                color: primaryText,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                letterSpacing: -0.5,
                              ),
                            ),
                            if (_totalAdsRequired > 1) ...[
                              const SizedBox(height: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.amber.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: Colors.amber.withValues(alpha: 0.3)),
                                ),
                                child: Text(
                                  '${fileSizeMb.toStringAsFixed(1)} MB File • $_totalAdsRequired Short Ads Required to Unlock (Ad 1 of $_totalAdsRequired)',
                                  style: TextStyle(
                                    color: isDark ? Colors.amber.shade300 : const Color(0xFFB45309),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 11,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // File vs Limit Details Card
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isDark
                          ? const Color(0xFF1E293B).withValues(alpha: 0.7)
                          : const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isDark ? Colors.white12 : const Color(0xFFE2E8F0),
                      ),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Uploaded File:',
                              style: TextStyle(color: labelText, fontSize: 13),
                            ),
                            Flexible(
                              child: Text(
                                '${widget.filename} (${fileSizeMb.toStringAsFixed(1)} MB)',
                                style: TextStyle(
                                  color: isDark ? Colors.amberAccent : const Color(0xFFD97706),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        Divider(color: isDark ? Colors.white10 : const Color(0xFFE2E8F0), height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Current Session Limit:',
                              style: TextStyle(color: labelText, fontSize: 13),
                            ),
                            Text(
                              '${widget.currentLimitMb.toStringAsFixed(1)} MB',
                              style: TextStyle(
                                color: isDark ? Colors.redAccent : const Color(0xFFDC2626),
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Stackable Boost Promo Card
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: isDark
                            ? [
                                Colors.amber.shade900.withValues(alpha: 0.4),
                                Colors.orange.shade900.withValues(alpha: 0.2),
                              ]
                            : [
                                const Color(0xFFFEF3C7),
                                const Color(0xFFFFEDD5),
                              ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isDark
                            ? Colors.amber.shade400.withValues(alpha: 0.3)
                            : Colors.amber.shade300,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.bolt_rounded,
                          color: isDark ? Colors.amber.shade300 : Colors.amber.shade700,
                          size: 32,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Unlock Stackable Limit Boost (+${widget.boostPerAdMb.toInt()} MB)',
                                style: TextStyle(
                                  color: isDark ? Colors.white : const Color(0xFF78350F),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Watch short sponsor ads to stack file limits up to ${widget.maxStackMb.toInt()} MB per session.',
                                style: TextStyle(
                                  color: isDark ? Colors.amber.shade100 : const Color(0xFF92400E),
                                  fontSize: 12,
                                  height: 1.3,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Action Buttons
                  ElevatedButton.icon(
                    onPressed: _startAdPlayback,
                    icon: const Icon(Icons.play_circle_fill_rounded, size: 20),
                    label: Text(
                      _totalAdsRequired > 1
                          ? 'Watch Ad 1 of $_totalAdsRequired (+${widget.boostPerAdMb.toInt()} MB Boost)'
                          : 'Watch ${widget.adDurationSeconds}s Ad to Stack Boost (+${widget.boostPerAdMb.toInt()} MB)',
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isDark ? Colors.amber.shade500 : const Color(0xFFD97706),
                      foregroundColor: isDark ? Colors.black : Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 4,
                      textStyle: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextButton(
                    onPressed: widget.onCancel,
                    style: TextButton.styleFrom(
                      foregroundColor: secondaryText,
                    ),
                    child: const Text('Cancel'),
                  ),
                ],
              ],
            ),
          ),
        );
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: kIsWeb
          ? modalContainer
          : BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
              child: modalContainer,
            ),
    );
  }

  Widget _buildSuccessDetailRow({
    required bool isDark,
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 18,
          color: isDark ? Colors.greenAccent : const Color(0xFF059669),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: isDark ? Colors.white : const Color(0xFF064E3B),
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: TextStyle(
                  color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF1F2937),
                  fontSize: 11,
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
