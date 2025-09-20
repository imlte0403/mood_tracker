import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mood_tracker/core/constants/app_color.dart';
import 'package:mood_tracker/core/constants/app_text_styles.dart';
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
  bool _shouldAutovalidate = false;

  @override
  void dispose() {
    _nameController.dispose();
    _nameFocus.dispose();
    super.dispose();
  }

  void _submit() async {
    if (ref.read(signUpProvider).isLoading) return;

    setState(() => _shouldAutovalidate = true);

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
      autovalidateMode: _shouldAutovalidate
          ? AutovalidateMode.onUserInteraction
          : AutovalidateMode.disabled,
    );
  }

  Widget _buildEmailField() {
    return AuthTextField.email(
      controller: emailController,
      focusNode: emailFocus,
      onSubmitted: (_) => passwordFocus.requestFocus(),
      autovalidateMode: _shouldAutovalidate
          ? AutovalidateMode.onUserInteraction
          : AutovalidateMode.disabled,
    );
  }

  Widget _buildPasswordField() {
    return AuthTextField.password(
      controller: passwordController,
      focusNode: passwordFocus,
      onSubmitted: (_) => _submit(),
      autovalidateMode: _shouldAutovalidate
          ? AutovalidateMode.onUserInteraction
          : AutovalidateMode.disabled,
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
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return Scaffold(
      backgroundColor: AppColors.bgWhite,
      appBar: AppBar(
        backgroundColor: AppColors.bgWhite,
        surfaceTintColor: AppColors.bgWhite,
        elevation: 0,
        titleSpacing: 0,
        title: Text('Sign Up', style: AppTextStyles.authAppBar(textTheme)),
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
                      Gaps.v20,
                      Padding(
                        padding: const EdgeInsets.only(left: 16),
                        child: const AuthHeader(
                          title: 'Create a new account',
                          subtitle:
                              'Sign up to start logging your emotional patterns.',
                        ),
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
                                _buildNameField(),
                                Gaps.v20,
                                _buildEmailField(),
                                Gaps.v20,
                                _buildPasswordField(),
                                Gaps.v24,
                                AuthBtn.primary(
                                  label: 'Sign Up',
                                  isLoading: isLoading,
                                  onPressed: _submit,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Gaps.v24,
                      Center(
                        child: TextButton(
                          onPressed: () => context.go(LogInScreen.routeURL),
                          child: RichText(
                            text: TextSpan(
                              text: 'Already have an account? ',
                              style: AppTextStyles.authBody(textTheme),
                              children: [
                                TextSpan(
                                  text: 'Log In',
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
