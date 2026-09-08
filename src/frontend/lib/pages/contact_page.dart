import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../services/telemetry_service.dart';
import '../utils/url_helper.dart';
import '../constants/social_links.dart';
import '../widgets/adsense_banner.dart';
import '../widgets/app_footer.dart';
import '../widgets/app_header.dart';
import '../main.dart' show themeNotifier;

/// Dedicated Contact Page (/contact)
/// Complies with Google AdSense publisher accountability, user support, and contactability policies.
class ContactPage extends StatefulWidget {
  const ContactPage({super.key});

  @override
  State<ContactPage> createState() => _ContactPageState();
}

class _ContactPageState extends State<ContactPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _subjectController = TextEditingController();
  final _messageController = TextEditingController();

  bool _isSubmitting = false;
  bool _isSubmitted = false;
  String _selectedCategory = 'General Inquiry';

  final List<String> _categories = [
    'General Inquiry',
    'Bug Report / OCR Conversion Issue',
    'Feature Suggestion',
    'Privacy & GDPR / Data Protection',
    'Advertising & Partnerships',
  ];

  @override
  void initState() {
    super.initState();
    TelemetryService.trackPageView('/contact', pageTitle: 'freeOCR.me — Contact Us');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _subjectController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (_isSubmitting) return;
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _isSubmitting = true;
      });

      await ApiService.submitContactForm(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        category: _selectedCategory,
        subject: _subjectController.text.trim(),
        message: _messageController.text.trim(),
      );

      if (!mounted) return;

      setState(() {
        _isSubmitting = false;
        _isSubmitted = true;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: const [
              Icon(Icons.check_circle_outline_rounded, color: Colors.white),
              SizedBox(width: 10),
              Expanded(
                child: Text('Message sent! Our support team will reply within 24–48 hours.'),
              ),
            ],
          ),
          backgroundColor: const Color(0xFF10B981),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppHeader(
        currentRoute: '/contact',
        onThemeToggle: () {
          themeNotifier.value = isDark ? ThemeMode.light : ThemeMode.dark;
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
                    // Header Badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFF6366F1).withOpacity(0.12),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0xFF6366F1).withOpacity(0.3)),
                      ),
                      child: const Text(
                        'CONTACT & SUPPORT',
                        style: TextStyle(
                          color: Color(0xFF6366F1),
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Get in Touch with freeOCR.me',
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'We are dedicated to providing responsive assistance. Reach out to our engineering and support team using the form below or direct email channels.',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Direct Contact Channel Cards
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final isWide = constraints.maxWidth > 600;
                        return isWide
                            ? Row(
                                children: [
                                  Expanded(child: _buildDirectCard(
                                    context,
                                    title: 'General Support',
                                    email: SocialLinks.supportEmail,
                                    icon: Icons.headset_mic_outlined,
                                    subtitle: 'Turnaround: 24–48 hours',
                                  )),
                                  const SizedBox(width: 16),
                                  Expanded(child: _buildDirectCard(
                                    context,
                                    title: 'Privacy & Legal',
                                    email: SocialLinks.privacyEmail,
                                    icon: Icons.gavel_rounded,
                                    subtitle: 'GDPR / CCPA / Compliance',
                                  )),
                                ],
                              )
                            : Column(
                                children: [
                                  _buildDirectCard(
                                    context,
                                    title: 'General Support',
                                    email: SocialLinks.supportEmail,
                                    icon: Icons.headset_mic_outlined,
                                    subtitle: 'Turnaround: 24–48 hours',
                                  ),
                                  const SizedBox(height: 12),
                                  _buildDirectCard(
                                    context,
                                    title: 'Privacy & Legal',
                                    email: SocialLinks.privacyEmail,
                                    icon: Icons.gavel_rounded,
                                    subtitle: 'GDPR / CCPA / Compliance',
                                  ),
                                ],
                              );
                      },
                    ),

                    const SizedBox(height: 28),
                    const AdSenseBanner(),
                    const SizedBox(height: 28),

                    // Interactive Contact Form Container
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(28),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF111827) : const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isDark ? Colors.white.withOpacity(0.08) : const Color(0xFFE2E8F0),
                        ),
                      ),
                      child: _isSubmitted
                          ? _buildSuccessView(context)
                          : Form(
                              key: _formKey,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Send Us a Direct Message',
                                    style: theme.textTheme.titleLarge?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: colorScheme.onSurface,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    'Fill out the fields below and our team will get back to you promptly.',
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color: colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                  const SizedBox(height: 20),

                                  // Name Field
                                  TextFormField(
                                    key: const Key('contact_name_field'),
                                    controller: _nameController,
                                    decoration: const InputDecoration(
                                      labelText: 'Your Name',
                                      prefixIcon: Icon(Icons.person_outline_rounded),
                                      border: OutlineInputBorder(),
                                    ),
                                    validator: (val) =>
                                        (val == null || val.trim().isEmpty) ? 'Please enter your name' : null,
                                  ),
                                  const SizedBox(height: 16),

                                  // Email Field
                                  TextFormField(
                                    key: const Key('contact_email_field'),
                                    controller: _emailController,
                                    keyboardType: TextInputType.emailAddress,
                                    decoration: const InputDecoration(
                                      labelText: 'Email Address',
                                      prefixIcon: Icon(Icons.email_outlined),
                                      border: OutlineInputBorder(),
                                    ),
                                    validator: (val) {
                                      if (val == null || val.trim().isEmpty) {
                                        return 'Please enter your email address';
                                      }
                                      if (!val.contains('@') || !val.contains('.')) {
                                        return 'Please enter a valid email';
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 16),

                                  // Category Dropdown
                                  DropdownButtonFormField<String>(
                                    key: const Key('contact_category_field'),
                                    value: _selectedCategory,
                                    decoration: const InputDecoration(
                                      labelText: 'Inquiry Category',
                                      prefixIcon: Icon(Icons.category_outlined),
                                      border: OutlineInputBorder(),
                                    ),
                                    items: _categories.map((cat) {
                                      return DropdownMenuItem(value: cat, child: Text(cat));
                                    }).toList(),
                                    onChanged: (val) {
                                      if (val != null) setState(() => _selectedCategory = val);
                                    },
                                  ),
                                  const SizedBox(height: 16),

                                  // Subject Field
                                  TextFormField(
                                    key: const Key('contact_subject_field'),
                                    controller: _subjectController,
                                    decoration: const InputDecoration(
                                      labelText: 'Subject',
                                      prefixIcon: Icon(Icons.subject_rounded),
                                      border: OutlineInputBorder(),
                                    ),
                                    validator: (val) =>
                                        (val == null || val.trim().isEmpty) ? 'Please enter a subject' : null,
                                  ),
                                  const SizedBox(height: 16),

                                  // Message Field
                                  TextFormField(
                                    key: const Key('contact_message_field'),
                                    controller: _messageController,
                                    maxLines: 5,
                                    decoration: const InputDecoration(
                                      labelText: 'Your Message',
                                      alignLabelWithHint: true,
                                      border: OutlineInputBorder(),
                                    ),
                                    validator: (val) =>
                                        (val == null || val.trim().length < 10)
                                            ? 'Please enter at least 10 characters'
                                            : null,
                                  ),
                                  const SizedBox(height: 24),

                                  // Submit Button
                                  SizedBox(
                                    width: double.infinity,
                                    height: 48,
                                    child: FilledButton.icon(
                                      key: const Key('contact_submit_btn'),
                                      onPressed: _isSubmitting ? null : _handleSubmit,
                                      icon: _isSubmitting
                                          ? const SizedBox(
                                              width: 18,
                                              height: 18,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                              ),
                                            )
                                          : const Icon(Icons.send_rounded),
                                      label: Text(
                                        _isSubmitting ? 'Sending...' : 'Submit Inquiry',
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                      ),
                                      style: FilledButton.styleFrom(
                                        backgroundColor: const Color(0xFF6366F1),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                      ),
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
            const SizedBox(height: 40),
            const AppFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildDirectCard(
    BuildContext context, {
    required String title,
    required String email,
    required IconData icon,
    required String subtitle,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return InkWell(
      onTap: () => UrlHelper.openUrl('mailto:$email'),
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF111827) : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isDark ? Colors.white.withOpacity(0.08) : const Color(0xFFE2E8F0),
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFF6366F1).withOpacity(0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: const Color(0xFF6366F1), size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    email,
                    style: const TextStyle(
                      color: Color(0xFF6366F1),
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 11,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSuccessView(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 32.0),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF10B981).withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check_rounded, color: Color(0xFF10B981), size: 40),
            ),
            const SizedBox(height: 16),
            const Text(
              'Thank You for Contacting Us!',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Your inquiry has been successfully transmitted. Our support team will review your message and reply within 24–48 hours.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey, height: 1.5),
            ),
            const SizedBox(height: 20),
            OutlinedButton(
              onPressed: () {
                setState(() {
                  _isSubmitted = false;
                  _nameController.clear();
                  _emailController.clear();
                  _subjectController.clear();
                  _messageController.clear();
                });
              },
              child: const Text('Send Another Message'),
            ),
          ],
        ),
      ),
    );
  }
}
