import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:mood_tracker/core/constants/gaps.dart';
import 'package:mood_tracker/core/constants/sizes.dart';
import 'package:mood_tracker/core/constants/app_text_styles.dart';

import 'package:mood_tracker/features/auth/screen/log_in_screen.dart';
import 'package:mood_tracker/features/settings/settings_viewmodel.dart';

class _ThemeSection extends ConsumerWidget {
  const _ThemeSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final viewModel = ref.watch(settingsViewModelProvider);
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Appearance',
          style: AppTextStyles.settings(
            context,
          ).copyWith(fontWeight: FontWeight.w700, color: colorScheme.onSurface),
        ),
        Gaps.v12,
        SwitchListTile.adaptive(
          contentPadding: EdgeInsets.zero,
          secondary: Icon(
            Icons.mobile_friendly_outlined,
            color: colorScheme.onSurface,
          ),
          title: Text(
            'Match system theme',
            style: AppTextStyles.settings(context),
          ),
          value: viewModel.followSystem,
          onChanged: (value) {
            ref
                .read(settingsViewModelProvider)
                .setThemeMode(
                  followSystem: value,
                  darkMode: viewModel.darkMode,
                );
          },
        ),
        SwitchListTile.adaptive(
          contentPadding: EdgeInsets.zero,
          secondary: Icon(
            Icons.dark_mode_outlined,
            color: viewModel.followSystem
                ? colorScheme.onSurface.withValues(alpha: 0.4)
                : colorScheme.onSurface,
          ),
          title: Text('Dark mode', style: AppTextStyles.settings(context)),
          value: viewModel.darkMode,
          onChanged: viewModel.followSystem
              ? null
              : (value) {
                  ref
                      .read(settingsViewModelProvider)
                      .setThemeMode(followSystem: false, darkMode: value);
                },
        ),
      ],
    );
  }
}

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
        backgroundColor: Theme.of(context).colorScheme.surface,
        leadingWidth: 100,
        leading: GestureDetector(
          onTap: () => context.go('/'),
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
      ),
      body: ListView(
        children: [
          Gaps.v12,
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: Sizes.size16),
            child: _ThemeSection(),
          ),
          const Divider(height: Sizes.size40, thickness: 0.5),
          ListTile(
            leading: Icon(
              Icons.account_circle_outlined,
              color: Theme.of(context).colorScheme.onSurface,
            ),
            title: Text("Account", style: AppTextStyles.settings(context)),
            onTap: () {
              context.go('/settings/account');
            },
          ),
          ListTile(
            leading: Icon(
              Icons.notifications_none_rounded,
              color: Theme.of(context).colorScheme.onSurface,
            ),
            title: Text("Updates", style: AppTextStyles.settings(context)),
            onTap: () {
              context.go('/settings/updates');
            },
          ),
          ListTile(
            leading: Icon(
              Icons.lock_outline,
              color: Theme.of(context).colorScheme.onSurface,
            ),
            title: Text("Privacy", style: AppTextStyles.settings(context)),
            onTap: () {
              context.go('/settings/privacy');
            },
          ),

          ListTile(
            leading: Icon(
              Icons.help_outline,
              color: Theme.of(context).colorScheme.onSurface,
            ),
            title: Text("Help", style: AppTextStyles.settings(context)),
            onTap: () {
              context.go('/settings/help');
            },
          ),
          ListTile(
            leading: Icon(
              Icons.info_outline,
              color: Theme.of(context).colorScheme.onSurface,
            ),
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
                color: Theme.of(context).colorScheme.primary,
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
    );
  }
}
