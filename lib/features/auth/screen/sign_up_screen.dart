import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mood_tracker/constants/gaps.dart';
import 'package:mood_tracker/constants/sizes.dart';
import 'package:mood_tracker/features/auth/widget/auth_textfield.dart';
import 'package:mood_tracker/features/auth/widget/auth_btn.dart';
import 'package:mood_tracker/features/auth/view_model/sign_up_view_model.dart';

class SignUpScreen extends ConsumerStatefulWidget {
  static const String routeName = 'signup';
  static const String routeURL = '/signup';

  const SignUpScreen({super.key});

  @override
  ConsumerState<SignUpScreen> createState() => _SignUpScreenState();
}

//회원가입 화면
class _SignUpScreenState extends ConsumerState<SignUpScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  final _emailFocus = FocusNode();
  final _passwordFocus = FocusNode();
  final _nameFocus = FocusNode();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    _nameFocus.dispose();
    super.dispose();
  }

  void _submit() async {
    final form = _formKey.currentState;
    if (form == null || !form.validate()) return;

    await ref.read(signUpProvider.notifier).signUp(
          email: _emailController.text.trim(),
          password: _passwordController.text,
          displayName: _nameController.text.trim(),
        );
  }

  void _onAuthStateChange(AsyncValue<void> next) {
    next.when(
      data: (_) {
        final user = FirebaseAuth.instance.currentUser;
        if (user != null && context.mounted) context.go('/');
      },
      loading: () {},
      error: (err, _) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(err.toString())),
        );
      },
    );
  }

  Widget _buildHeader() {
    return const Text(
      'Create a new account',
      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
    );
  }

  Widget _buildNameField() {
    return AuthTextField.name(
      controller: _nameController,
      focusNode: _nameFocus,
      onSubmitted: (_) => _emailFocus.requestFocus(),
    );
  }

  Widget _buildEmailField() {
    return AuthTextField.email(
      controller: _emailController,
      focusNode: _emailFocus,
      onSubmitted: (_) => _passwordFocus.requestFocus(),
    );
  }

  Widget _buildPasswordField() {
    return AuthTextField.password(
      controller: _passwordController,
      focusNode: _passwordFocus,
      onSubmitted: (_) => _submit(),
    );
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AsyncValue<void>>(signUpProvider, (previous, next) {
      _onAuthStateChange(next);
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
              _buildHeader(),
              Gaps.v20,
              Form(
                key: _formKey,
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
                onPressed: () => context.go('/login'),
                child: const Text('Already have an account? Log In'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
