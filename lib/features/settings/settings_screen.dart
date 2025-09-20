import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:mood_tracker/core/constants/sizes.dart';
import 'package:mood_tracker/core/constants/app_text_styles.dart';
import 'package:mood_tracker/core/constants/app_color.dart';

import 'package:mood_tracker/features/auth/screen/log_in_screen.dart';
import 'package:mood_tracker/features/settings/settings_viewmodel.dart';

class SettingsScreen extends ConsumerWidget {
  static const routeName = 'settings';
  static const routeURL = '/settings';
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Settings",
          style: AppTextStyles.authAppBar(
            Theme.of(context).textTheme,
          )?.copyWith(fontSize: 20),
        ),
        centerTitle: true,
        backgroundColor: AppColors.bgWhite,
        leadingWidth: 100,
        leading: GestureDetector(
          onTap: () => context.go('/'),
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
        child: ListView(
          children: [
            ListTile(
              leading: Icon(Icons.dark_mode_outlined, color: AppColors.text),
              title: Text("Dark mode", style: AppTextStyles.settings(context)),
              trailing: CupertinoSwitch(
                value: ref.watch(settingsViewModelProvider).darkMode,
                onChanged: (value) {
                  ref.read(settingsViewModelProvider).setDarkMode(value);
                },
              ),
            ),
            ListTile(
              leading: Icon(
                Icons.account_circle_outlined,
                color: AppColors.text,
              ),
              title: Text("Account", style: AppTextStyles.settings(context)),
              onTap: () {},
            ),
            ListTile(
              leading: Icon(Icons.new_releases_outlined, color: AppColors.text),
              title: Text("Updates", style: AppTextStyles.settings(context)),
              onTap: () {
                context.go('/settings/updates');
              },
            ),
            ListTile(
              leading: Icon(Icons.lock_outline, color: AppColors.text),
              title: Text("Privacy", style: AppTextStyles.settings(context)),
              onTap: () {
                context.go('/settings/privacy');
              },
            ),

            ListTile(
              leading: Icon(Icons.help_outline, color: AppColors.text),
              title: Text("Help", style: AppTextStyles.settings(context)),
              onTap: () {
                context.go('/settings/help');
              },
            ),
            ListTile(
              leading: Icon(Icons.info_outline, color: AppColors.text),
              title: Text("About", style: AppTextStyles.settings(context)),
              onTap: () {
                context.go('/settings/about');
              },
            ),
            const Divider(height: Sizes.size2, thickness: 0.5),
            ListTile(
              title: Text(
                "Log out",
                style: AppTextStyles.settings(context).copyWith(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.point,
                ),
              ),
              onTap: () async {
                try {
                  await FirebaseAuth.instance.signOut();
                  await GoogleSignIn().signOut();
                } catch (error) {
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Log out failed. Try again.')),
                  );
                  return;
                }
                if (!context.mounted) return;
                context.go(LogInScreen.routeURL);
              },
            ),
          ],
        ),
      ),
    );
  }
}
