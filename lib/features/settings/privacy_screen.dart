import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mood_tracker/core/constants/app_text_styles.dart';
import 'package:mood_tracker/core/constants/sizes.dart';

class PrivacyScreen extends StatelessWidget {
  static const routeName = 'privacy';
  static const routeURL = '/settings/privacy';

  const PrivacyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Privacy",
          style: AppTextStyles.authAppBar(
            Theme.of(context).textTheme,
          )?.copyWith(fontSize: 20),
        ),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.surface,
        leadingWidth: 100,
        leading: GestureDetector(
          onTap: () => context.pop(),
          child: Container(
            padding: const EdgeInsets.only(left: 16),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [Icon(Icons.arrow_back_ios, color: Theme.of(context).colorScheme.onSurface)],
            ),
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(color: Theme.of(context).colorScheme.onSurfaceVariant, height: 1.0),
        ),
      ),
      body: Container(
        color: Theme.of(context).colorScheme.surface,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(Sizes.size20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Privacy Policy",
                style: AppTextStyles.authAppBar(
                  Theme.of(context).textTheme,
                )?.copyWith(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: Sizes.size20),
              Text(
                "Last updated: ${DateTime.now().year}-${DateTime.now().month.toString().padLeft(2, '0')}-${DateTime.now().day.toString().padLeft(2, '0')}",
                style: AppTextStyles.settings(
                  context,
                ).copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 14),
              ),
              const SizedBox(height: Sizes.size32),

              _buildSection(
                context,
                "Information We Collect",
                "We collect information you provide directly to us, such as when you create an account, log your mood entries, and use our app features. This includes your mood data, journal entries, and account information.",
              ),

              _buildSection(
                context,
                "How We Use Your Information",
                "We use the information we collect to provide, maintain, and improve our services. Your mood data is used to generate insights and help you track your emotional wellbeing over time.",
              ),

              _buildSection(
                context,
                "Data Security",
                "We implement appropriate security measures to protect your personal information against unauthorized access, alteration, disclosure, or destruction. Your data is encrypted and stored securely.",
              ),

              _buildSection(
                context,
                "Data Sharing",
                "We do not sell, trade, or otherwise transfer your personal information to third parties. Your mood data and journal entries remain private and are only accessible to you.",
              ),

              _buildSection(
                context,
                "Your Rights",
                "You have the right to access, update, or delete your personal information. You can export your data or delete your account at any time through the app settings.",
              ),

              _buildSection(
                context,
                "Contact Us",
                "If you have any questions about this Privacy Policy, please contact us through the app's help section or at support@moodtracker.app",
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection(BuildContext context, String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTextStyles.authAppBar(
            Theme.of(context).textTheme,
          )?.copyWith(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: Sizes.size12),
        Text(
          content,
          style: AppTextStyles.settings(
            context,
          ).copyWith(fontSize: 16, height: 1.5),
        ),
        const SizedBox(height: Sizes.size24),
      ],
    );
  }
}
