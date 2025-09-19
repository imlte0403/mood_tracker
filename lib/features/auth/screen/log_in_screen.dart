import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:mood_tracker/core/constants/app_color.dart';
import 'package:mood_tracker/core/constants/gaps.dart';
import 'package:mood_tracker/core/constants/sizes.dart';
import 'package:mood_tracker/core/constants/app_text_styles.dart';

import 'package:mood_tracker/features/auth/mixins/auth_form_mixin.dart';
import 'package:mood_tracker/core/utils/auth_utils.dart';
import 'package:mood_tracker/features/auth/widget/auth_textfield.dart';
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
  void _submit() async {
    if (ref.read(loginProvider).isLoading) return;

    final form = formKey.currentState;
    if (form == null || !form.validate()) return;

    await ref
        .read(loginProvider.notifier)
        .login(
          email: emailController.text.trim(),
          password: passwordController.text,
        );
  }

  Widget _buildEmailField() {
    return AuthTextField.email(
      controller: emailController,
      focusNode: emailFocus,
      onSubmitted: (_) => passwordFocus.requestFocus(),
    );
  }

  Widget _buildPasswordField() {
    return AuthTextField.password(
      controller: passwordController,
      focusNode: passwordFocus,
      onSubmitted: (_) => _submit(),
      enableVisibilityToggle: false,
    );
  }

  Widget _buildSocialButtons(LoginState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AuthBtn.social(
          label: 'Continue with Google',
          icon: const Icon(Icons.g_mobiledata),
          isLoading: state.googleLoading,
          onPressed: state.isLoading
              ? null
              : () => ref.read(loginProvider.notifier).loginWithGoogle(),
        ),
        Gaps.v12,
        AuthBtn.social(
          label: 'Continue with Apple',
          icon: const Icon(Icons.apple),
          isLoading: state.appleLoading,
          onPressed: state.isLoading
              ? null
              : () => ref.read(loginProvider.notifier).loginWithApple(),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<LoginState>(loginProvider, (previous, next) {
      AuthUtils.handleAuthStateChange(
        context,
        next.status,
        onSuccess: () => context.go(HomeScreen.routeURL),
        onUserNotFound: () => context.go(SignUpScreen.routeURL),
        fallbackErrorMessage: 'Sign-in failed.',
      );
    });

    final loginState = ref.watch(loginProvider);
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return Scaffold(
      backgroundColor: AppColors.bgWhite,
      appBar: AppBar(
        backgroundColor: AppColors.bgWhite,
        surfaceTintColor: AppColors.bgWhite,
        elevation: 0,
        titleSpacing: 0,
        title: Text(
          'Log In',
          style: AppTextStyles.authAppBar(textTheme),
        ),
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
                      AuthHeader(
                        title: 'Welcome back',
                        subtitle: 'Log in to continue tracking your mood journey.',
                      ),
                      Gaps.v28,
                      DecoratedBox(
                        decoration: BoxDecoration(
                          color: AppColors.bgWhite,
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
                                _buildEmailField(),
                                Gaps.v16,
                                _buildPasswordField(),
                                Gaps.v24,
                                AuthBtn.primary(
                                  label: 'Log In',
                                  isLoading: loginState.emailLoading,
                                  onPressed:
                                      loginState.isLoading ? null : _submit,
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
                      _buildSocialButtons(loginState),
                      Gaps.v24,
                      Center(
                        child: TextButton(
                          onPressed: () => context.go(SignUpScreen.routeURL),
                          child: Text(
                            "Don't have an account? Sign Up",
                            style: AppTextStyles.authLink(textTheme),
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
