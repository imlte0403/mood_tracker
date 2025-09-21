import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mood_tracker/features/auth/widget/auth_textfield.dart';

mixin AuthFormMixin<T extends ConsumerStatefulWidget> on ConsumerState<T> {
  late final GlobalKey<FormState> formKey;
  late final TextEditingController emailController;
  late final TextEditingController passwordController;
  late final FocusNode emailFocus;
  late final FocusNode passwordFocus;

  @override
  void initState() {
    super.initState();
    formKey = GlobalKey<FormState>();
    emailController = TextEditingController();
    passwordController = TextEditingController();
    emailFocus = FocusNode();
    passwordFocus = FocusNode();
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    emailFocus.dispose();
    passwordFocus.dispose();
    super.dispose();
  }

  AutovalidateMode _autovalidateMode(bool shouldAutovalidate) =>
      shouldAutovalidate
          ? AutovalidateMode.onUserInteraction
          : AutovalidateMode.disabled;

  Widget buildEmailField({required bool shouldAutovalidate}) {
    return AuthTextField.email(
      controller: emailController,
      focusNode: emailFocus,
      onSubmitted: (_) => passwordFocus.requestFocus(),
      autovalidateMode: _autovalidateMode(shouldAutovalidate),
    );
  }

  Widget buildNameField({
    required TextEditingController controller,
    required FocusNode focusNode,
    required VoidCallback onSubmitted,
    required bool shouldAutovalidate,
  }) {
    return AuthTextField.name(
      controller: controller,
      focusNode: focusNode,
      onSubmitted: (_) => onSubmitted(),
      autovalidateMode: _autovalidateMode(shouldAutovalidate),
    );
  }

  Widget buildPasswordField({
    required bool shouldAutovalidate,
    required VoidCallback onSubmit,
  }) {
    return AuthTextField.password(
      controller: passwordController,
      focusNode: passwordFocus,
      onSubmitted: (_) => onSubmit(),
      autovalidateMode: _autovalidateMode(shouldAutovalidate),
    );
  }
}
