import 'package:flutter/material.dart';
import '../services/telemetry_service.dart';
import '../widgets/adsense_banner.dart';
import '../widgets/app_footer.dart';
import '../widgets/app_header.dart';
import '../main.dart' show themeNotifier;

/// GDPR & CCPA Compliant Privacy Policy Page (/privacy)
class PrivacyPage extends StatefulWidget {
  const PrivacyPage({super.key});

  @override
  State<PrivacyPage> createState() => _PrivacyPageState();
}

class _PrivacyPageState extends State<PrivacyPage> {
  @override
  void initState() {
    super.initState();
    TelemetryService.trackPageView('/privacy', pageTitle: 'freeOCR.me — Privacy Policy');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppHeader(
        currentRoute: '/privacy',
        onThemeToggle: () {
          if (isDark) {
            themeNotifier.value = ThemeMode.light;
          } else {
            themeNotifier.value = ThemeMode.dark;
          }
        },
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 900),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Privacy Policy (GDPR & CCPA Compliant)', style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text('Last Updated: August 30, 2026', style: theme.textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant)),
                    const SizedBox(height: 16),
                    const AdSenseBanner(),
                    const SizedBox(height: 20),

                    _buildSection(
                      context,
                      title: '1. Zero Persistent Document Storage Guarantee',
                      body: 'freeOCR.me processes all uploaded PDF and image files strictly in volatile Linux RAM disk (tmpfs). Uploaded documents are automatically unlinked and purged from memory immediately after conversion or within 24 hours. We never inspect, store, mine, or retain your documents on persistent hard drives.',
                    ),
                    _buildSection(
                      context,
                      title: '2. General Data Protection Regulation (GDPR) Compliance',
                      body: 'Under the EU GDPR, users have rights regarding personal data processing. freeOCR.me operates on a strict zero-registration, privacy-first model: we do not collect personal identification, user accounts, or stored file data. Anonymized telemetry dispatches can be controlled via browser-level privacy controls.',
                    ),
                    _buildSection(
                      context,
                      title: '3. California Consumer Privacy Act (CCPA) Disclosure',
                      body: 'Under the CCPA, California residents have the right to know what personal information is collected, request deletion, and opt out of the sale of personal information. freeOCR.me DOES NOT SELL your personal information or document content to third parties under any circumstances.',
                    ),
                    _buildSection(
                      context,
                      title: '4. Google AdSense & Third-Party Advertising Cookies',
                      body: 'We use Google AdSense to display non-intrusive advertisements. Google and its partners use cookies (such as the DoubleClick cookie) to serve ads based on user visits to this or other websites. You can manage or opt out of personalized advertising by visiting Google Ads Settings (https://adssettings.google.com).',
                    ),
                    _buildSection(
                      context,
                      title: '5. Anonymized Telemetry & Local Browser Storage',
                      body: 'We collect anonymized interaction events (such as page views and conversion success indicators) via Google Analytics 4 (GA4) to maintain infrastructure reliability. We use local browser storage exclusively for preserving your Light/Dark Mode theme preference and active session limit boost passes.',
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
            const AppFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(BuildContext context, {required String title, required String body}) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          Text(body, style: theme.textTheme.bodyMedium?.copyWith(height: 1.5, color: colorScheme.onSurface)),
        ],
      ),
    );
  }
}
