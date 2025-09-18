import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mood_tracker/core/constants/gaps.dart';
import 'package:mood_tracker/core/constants/sizes.dart';
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

    return Scaffold(
      appBar: AppBar(title: const Text('Log In')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(Sizes.size20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const AuthHeader(title: 'Welcome back!'),
              Gaps.v20,
              Form(
                key: formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildEmailField(),
                    Gaps.v16,
                    _buildPasswordField(),
                  ],
                ),
              ),
              Gaps.v24,
              AuthBtn.primary(
                label: 'Log In',
                isLoading: loginState.emailLoading,
                onPressed: loginState.isLoading ? null : _submit,
              ),
              Gaps.v12,
              TextButton(
                onPressed: () => context.go(SignUpScreen.routeURL),
                child: const Text("Don't have an account? Sign Up"),
              ),
              Gaps.v20,
              const Divider(),
              Gaps.v20,
              _buildSocialButtons(loginState),
            ],
          ),
        ),
      ),
    );
  }
}
