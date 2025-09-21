import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:mood_tracker/core/constants/gaps.dart';
import 'package:mood_tracker/core/constants/sizes.dart';
import 'package:mood_tracker/core/constants/app_text_styles.dart';

import 'package:mood_tracker/features/auth/mixins/auth_form_mixin.dart';
import 'package:mood_tracker/core/utils/auth_utils.dart';
import 'package:mood_tracker/features/auth/widget/auth_btn.dart';
import 'package:mood_tracker/features/auth/widget/auth_header.dart';
import 'package:mood_tracker/features/auth/view_model/login_view_model.dart';
import 'package:mood_tracker/features/home/home_screen.dart';
import 'package:mood_tracker/features/auth/screen/sign_up_screen.dart';

class LogInScreen extends ConsumerStatefulWidget {
  static const routeName = 'login';
  static const routeURL = '/login';

  const LogInScreen({super.key});

  @override
  ConsumerState<LogInScreen> createState() => _LogInScreenState();
}

class _LogInScreenState extends ConsumerState<LogInScreen>
    with AuthFormMixin<LogInScreen> {
  bool _shouldAutovalidate = false;

  void _submit() async {
    if (ref.read(loginProvider).isLoading) return;

    setState(() => _shouldAutovalidate = true);

    final form = formKey.currentState;
    if (form == null || !form.validate()) return;

    await ref
        .read(loginProvider.notifier)
        .login(
          email: emailController.text.trim(),
          password: passwordController.text,
        );
  }

  @override
  Widget build(BuildContext context) {

    final loginState = ref.watch(loginProvider);
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;

    // 로그인 버튼 상태에 따른 화면 전환
    ref.listen<LoginState>(loginProvider, (previous, next) {
      AuthUtils.handleAuthStateChange(
        context,
        next.status,
        onSuccess: () => context.go(HomeScreen.routeURL),
        onUserNotFound: () => context.go(SignUpScreen.routeURL),
        fallbackErrorMessage: 'Sign-in failed.',
      );
    });

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: Text('Log In', style: AppTextStyles.authAppBar(textTheme)),
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final horizontalPadding = constraints.maxWidth > 520
                ? Sizes.size40
                : Sizes.size20;
            return SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: horizontalPadding,
                vertical: Sizes.size28,
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 420),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Gaps.v24,
                      Padding(
                        padding: const EdgeInsets.only(left: 16),
                        child: AuthHeader(
                          title: 'Welcome back!',
                          subtitle:
                              'Log in to continue tracking your mood journey.',
                        ),
                      ),
                      Gaps.v10,
                      DecoratedBox(
                        decoration: BoxDecoration(
                          color: colorScheme.surface,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: Sizes.size20,
                            vertical: Sizes.size24,
                          ),
                          child: Form(
                            key: formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                buildEmailField(
                                  shouldAutovalidate: _shouldAutovalidate,
                                ),
                                Gaps.v20,
                                buildPasswordField(
                                  shouldAutovalidate: _shouldAutovalidate,
                                  onSubmit: _submit,
                                ),
                                Gaps.v24,
                                AuthBtn.primary(
                                  label: 'Log In',
                                  isLoading: loginState.emailLoading,
                                  onPressed: loginState.isLoading
                                      ? null
                                      : _submit,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Gaps.v20,
                      Row(
                        children: [
                          const Expanded(child: Divider()),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: Sizes.size12,
                            ),
                            child: Text(
                              'or continue with',
                              style: AppTextStyles.authSubtitle(textTheme),
                            ),
                          ),
                          const Expanded(child: Divider()),
                        ],
                      ),
                      Gaps.v16,
                      AuthSocialButtons(
                        googleLoading: loginState.googleLoading,
                        appleLoading: loginState.appleLoading,
                        onGooglePressed: loginState.isLoading
                            ? null
                            : () => ref
                                .read(loginProvider.notifier)
                                .loginWithGoogle(),
                        onApplePressed: loginState.isLoading
                            ? null
                            : () => ref
                                .read(loginProvider.notifier)
                                .loginWithApple(),
                      ),
                      Gaps.v24,
                      Center(
                        child: TextButton(
                          onPressed: () => context.go(SignUpScreen.routeURL),
                          child: RichText(
                            text: TextSpan(
                              text: "Don't have an account? ",
                              style: AppTextStyles.authBody(textTheme),
                              children: [
                                TextSpan(
                                  text: 'Sign Up',
                                  style: AppTextStyles.authLink(
                                    textTheme,
                                  )?.copyWith(fontWeight: FontWeight.w800),
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
          },
        ),
      ),
    );
  }
}
