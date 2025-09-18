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
import 'package:mood_tracker/features/auth/view_model/sign_up_view_model.dart';
import 'package:mood_tracker/features/home/home_screen.dart';
import 'package:mood_tracker/features/auth/screen/log_in_screen.dart';

class SignUpScreen extends ConsumerStatefulWidget {
  static const String routeName = 'signup';
  static const String routeURL = '/signup';

  const SignUpScreen({super.key});

  @override
  ConsumerState<SignUpScreen> createState() => _SignUpScreenState();
}

//회원가입 화면
class _SignUpScreenState extends ConsumerState<SignUpScreen>
    with AuthFormMixin<SignUpScreen> {
  final _nameController = TextEditingController();
  final _nameFocus = FocusNode();

  @override
  void dispose() {
    _nameController.dispose();
    _nameFocus.dispose();
    super.dispose();
  }

  void _submit() async {
    final form = formKey.currentState;
    if (form == null || !form.validate()) return;

    await ref
        .read(signUpProvider.notifier)
        .signUp(
          email: emailController.text.trim(),
          password: passwordController.text,
          displayName: _nameController.text.trim(),
        );
  }

  Widget _buildNameField() {
    return AuthTextField.name(
      controller: _nameController,
      focusNode: _nameFocus,
      onSubmitted: (_) => emailFocus.requestFocus(),
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
    );
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AsyncValue<void>>(signUpProvider, (previous, next) {
      AuthUtils.handleAuthStateChange(
        context,
        next,
        onSuccess: () => context.go(HomeScreen.routeURL),
        fallbackErrorMessage: 'Sign-up failed.',
      );
    });

    final isLoading = ref.watch(signUpProvider).isLoading;

    return Scaffold(
      appBar: AppBar(title: const Text('Sign Up')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(Sizes.size20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const AuthHeader(title: 'Create a new account'),
              Gaps.v20,
              Form(
                key: formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildNameField(),
                    Gaps.v16,
                    _buildEmailField(),
                    Gaps.v16,
                    _buildPasswordField(),
                  ],
                ),
              ),
              Gaps.v24,
              AuthBtn.primary(
                label: 'Sign Up',
                isLoading: isLoading,
                onPressed: _submit,
              ),
              Gaps.v12,
              TextButton(
                onPressed: () => context.go(LogInScreen.routeURL),
                child: const Text('Already have an account? Log In'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
