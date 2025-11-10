import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mood_tracker/core/constants/app_color.dart';
import 'package:mood_tracker/core/constants/app_text_styles.dart';
import 'package:mood_tracker/core/constants/gaps.dart';
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
          "앱 소개",
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
                    Gaps.v16,
                    Text(
                      AboutContent.appName,
                      style: AppTextStyles.settings(
                        context,
                      ).copyWith(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    Gaps.v8,
                    Text(
                      '버전 ${AboutContent.appVersion} (${AboutContent.buildNumber})',
                      style: AppTextStyles.settings(context).copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
              Gaps.v32,
              Text(
                AboutContent.description,
                style: AppTextStyles.settings(
                  context,
                ).copyWith(fontSize: 16, height: 1.5),
                textAlign: TextAlign.center,
              ),
              Gaps.v32,
              Text(
                '주요 기능',
                style: AppTextStyles.settings(
                  context,
                ).copyWith(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Gaps.v16,
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
                      Gaps.h12,
                      Text(feature, style: AppTextStyles.settings(context)),
                    ],
                  ),
                ),
              ),
              Gaps.v32,
              Text(
                '만든 사람',
                style: AppTextStyles.settings(
                  context,
                ).copyWith(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Gaps.v16,
              Text(
                AboutContent.developer,
                style: AppTextStyles.settings(context),
              ),
              Gaps.v32,
              Text(
                '오픈 소스 라이선스',
                style: AppTextStyles.settings(
                  context,
                ).copyWith(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Gaps.v16,
              ...AboutContent.licenses.map(
                (license) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
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
                          Gaps.v4,
                          Text(
                          '버전: ${license.version}',
                            style: AppTextStyles.settings(context).copyWith(
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                              fontSize: 14,
                            ),
                          ),
                          Text(
                          '라이선스: ${license.license}',
                            style: AppTextStyles.settings(context).copyWith(
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
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
