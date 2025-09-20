import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mood_tracker/core/constants/gaps.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:mood_tracker/core/constants/app_color.dart';
import 'package:mood_tracker/core/constants/app_text_styles.dart';
import 'package:mood_tracker/features/settings/help/help_content.dart';

class HelpScreen extends StatelessWidget {
  static const routeName = 'help';
  static const routeURL = '/settings/help';

  const HelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Help",
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
              children: [
                Icon(
                  Icons.arrow_back_ios,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ],
            ),
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            height: 1.0,
          ),
        ),
      ),
      body: Container(
        color: Theme.of(context).colorScheme.surface,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Center(
                child: Column(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: AppColors.point,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.help_outline,
                        size: 30,
                        color: Colors.white,
                      ),
                    ),
                    Gaps.v16,
                    Text(
                      'How can we help you?',
                      style: AppTextStyles.settings(
                        context,
                      ).copyWith(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    Gaps.v8,
                    Text(
                      'Find answers to common questions below',
                      style: AppTextStyles.settings(context).copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
              Gaps.v32,

              // FAQ Sections
              ...HelpContent.sections.map(
                (section) => _buildHelpSection(context, section),
              ),

              Gaps.v32,

              // Contact Section
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Still need help?',
                      style: AppTextStyles.settings(
                        context,
                      ).copyWith(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    Gaps.v16,
                    Text(
                      'Contact our support team for additional assistance.',
                      style: AppTextStyles.settings(context),
                    ),
                    Gaps.v16,
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () =>
                                _launchEmail(HelpContent.contactInfo.email),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.point,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            icon: const Icon(Icons.email_outlined, size: 20),
                            label: const Text('Email Support'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHelpSection(BuildContext context, HelpSection section) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            section.title,
            style: AppTextStyles.settings(
              context,
            ).copyWith(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          Gaps.v16,
          ...section.items.map((item) => _buildHelpItem(context, item)),
        ],
      ),
    );
  }

  Widget _buildHelpItem(BuildContext context, HelpItem item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        border: Border.all(
          color: Theme.of(
            context,
          ).colorScheme.onSurfaceVariant.withOpacity(0.3),
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ExpansionTile(
        title: Text(
          item.question,
          style: AppTextStyles.settings(
            context,
          ).copyWith(fontWeight: FontWeight.w600),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Text(
              item.answer,
              style: AppTextStyles.settings(context).copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _launchEmail(String email) async {
    final Uri emailLaunchUri = Uri(
      scheme: 'mailto',
      path: email,
      query: 'subject=Mood Tracker Support',
    );

    if (await canLaunchUrl(emailLaunchUri)) {
      await launchUrl(emailLaunchUri);
    }
  }
}
