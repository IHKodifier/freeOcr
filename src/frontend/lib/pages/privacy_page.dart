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
    const brandTitle = 'freeOCR.me';
    TelemetryService.trackPageView('/privacy', pageTitle: '$brandTitle — Privacy Policy');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    const brandTitle = 'freeOCR.me';

    return SelectionArea(
      child: Scaffold(
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
                      Text('Last Updated: October 2026', style: theme.textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant)),
                      const SizedBox(height: 16),
                      const AdSenseBanner(),
                      const SizedBox(height: 20),

                      _buildSection(
                        context,
                        title: '1. Zero Persistent Document Storage Guarantee & Ephemeral RAM Execution',
                        body: '$brandTitle processes all uploaded PDF and image files strictly in volatile Linux RAM disk (tmpfs). Uploaded documents are automatically unlinked and purged from memory immediately after conversion or within 24 hours. We never inspect, store, mine, or retain your documents on persistent hard drives.',
                      ),
                      _buildSection(
                        context,
                        title: '2. Zero Retention Policy for Email Addresses & Zero Marketing Promise',
                        body: 'Although you may share your email with us to receive download links in email, we never store, retain, or even cache your email addresses, making us in no position to bother you with unwanted marketing emails. Just like we have a zero retention policy for input and output files, we have a zero retention policy for your email addresses as well. That is why you do not need to sign up—our service is 100% free and privacy-focused.',
                      ),
                      _buildSection(
                        context,
                        title: '3. General Data Protection Regulation (GDPR) Compliance',
                        body: 'Under the EU GDPR, users have rights regarding personal data processing. $brandTitle operates on a strict zero-registration, privacy-first model: we do not collect personal identification, user accounts, or stored file data. Anonymized telemetry dispatches can be controlled via browser-level privacy controls.',
                      ),
                      _buildSection(
                        context,
                        title: '4. California Consumer Privacy Act (CCPA) Disclosure',
                        body: 'Under the CCPA, California residents have the right to know what personal information is collected, request deletion, and opt out of the sale of personal information. $brandTitle DOES NOT SELL your personal information, email addresses, or document content to third parties under any circumstances.',
                      ),
                      _buildSection(
                        context,
                        title: '5. Third-Party Advertising Networks & Programmatic Partners',
                        body: 'To keep $brandTitle 100% free and universally accessible without account barriers, we partner with verified digital advertising networks including Google AdSense, Monetag (PropellerAds), Adsterra, and Infolinks to serve non-intrusive display banners, native cards, and sponsored limit-boost units. These networks may use transient cookies or web beacons to prevent ad fraud, evaluate viewability, and enforce frequency capping. You may opt out of personalized ad cookies via Google Ads Settings (https://adssettings.google.com), the Digital Advertising Alliance (https://optout.aboutads.info), or the Network Advertising Initiative (https://optout.networkadvertising.org).',
                      ),
                      _buildSection(
                        context,
                        title: '6. Anonymized Telemetry, Local Browser Storage & Session Boosts',
                        body: 'We collect minimal, anonymized interaction events via Google Analytics 4 (GA4) to ensure uptime and conversion reliability. We use local browser storage (localStorage) strictly for client-side state: preserving your Light/Dark Mode preference (freeocr_theme) and temporarily recording active sponsored quota boost passes (freeocr_boost_*). These entries contain zero personal identification and clear automatically upon expiration.',
                      ),
                      _buildSection(
                        context,
                        title: '7. Affiliate Partner Recommendations & Commercial Transparency (FTC Disclosure)',
                        body: 'In accordance with FTC guidelines, we transparently disclose that certain educational guides and post-conversion screens may feature partner recommendations for specialized desktop utilities (e.g. EaseUS PDF Editor or CloudConvert) with rel="sponsored nofollow" attribution. If you choose to purchase commercial desktop software through these links, $brandTitle may receive a referral commission at zero additional cost to you, directly subsidizing our cloud OCR infrastructure.',
                      ),
                      _buildSection(
                        context,
                        title: '8. Complete Data Isolation: Zero Third-Party Document Access Guarantee',
                        body: 'We enforce absolute technical separation between client dropzones, document processing pipelines, and third-party advertising scripts. Ad tags and partner scripts operate exclusively in sandboxed browser DOM or iframe contexts and have zero access to uploaded PDF files, images, OCR output text, or volatile RAM-disk (tmpfs) conversion memory.',
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
