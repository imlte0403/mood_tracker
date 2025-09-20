import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mood_tracker/core/constants/app_color.dart';
import 'package:mood_tracker/core/constants/app_text_styles.dart';
import 'package:mood_tracker/features/settings/about/about_content.dart';

class AboutScreen extends StatelessWidget {
  static const routeName = 'about';
  static const routeURL = '/settings/about';

  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "About",
          style: AppTextStyles.authAppBar(
            Theme.of(context).textTheme,
          )?.copyWith(fontSize: 20),
        ),
        centerTitle: true,
        backgroundColor: AppColors.bgWhite,
        leadingWidth: 100,
        leading: GestureDetector(
          onTap: () => context.pop(),
          child: Container(
            padding: const EdgeInsets.only(left: 16),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [Icon(Icons.arrow_back_ios, color: AppColors.text)],
            ),
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(color: AppColors.placeholder, height: 1.0),
        ),
      ),
      body: Container(
        color: AppColors.bgWhite,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Column(
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: AppColors.point,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(
                        Icons.mood,
                        size: 40,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      AboutContent.appName,
                      style: AppTextStyles.settings(
                        context,
                      ).copyWith(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Version ${AboutContent.appVersion} (${AboutContent.buildNumber})',
                      style: AppTextStyles.settings(
                        context,
                      ).copyWith(color: AppColors.placeholder, fontSize: 16),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              Text(
                AboutContent.description,
                style: AppTextStyles.settings(
                  context,
                ).copyWith(fontSize: 16, height: 1.5),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              Text(
                'Features',
                style: AppTextStyles.settings(
                  context,
                ).copyWith(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              ...AboutContent.features.map(
                (feature) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: Row(
                    children: [
                      Icon(
                        Icons.check_circle,
                        color: AppColors.point,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Text(feature, style: AppTextStyles.settings(context)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),
              Text(
                'Developer',
                style: AppTextStyles.settings(
                  context,
                ).copyWith(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Text(
                AboutContent.developer,
                style: AppTextStyles.settings(context),
              ),
              const SizedBox(height: 32),
              Text(
                'Open Source Licenses',
                style: AppTextStyles.settings(
                  context,
                ).copyWith(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              ...AboutContent.licenses.map(
                (license) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.bgBeige,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          license.name,
                          style: AppTextStyles.settings(
                            context,
                          ).copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Version: ${license.version}',
                          style: AppTextStyles.settings(context).copyWith(
                            color: AppColors.placeholder,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          'License: ${license.license}',
                          style: AppTextStyles.settings(context).copyWith(
                            color: AppColors.placeholder,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
