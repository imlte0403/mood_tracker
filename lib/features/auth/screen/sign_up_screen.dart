import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mood_tracker/constants/gaps.dart';
import 'package:mood_tracker/constants/sizes.dart';
import 'package:mood_tracker/features/auth/widget/auth_textfield.dart';
import 'package:mood_tracker/features/auth/view_model/sign_up_view_model.dart';

class SignUpScreen extends ConsumerStatefulWidget {
  static const String routeName = 'signup';
  static const String routeURL = '/signup';

  const SignUpScreen({super.key});

  @override
  ConsumerState<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends ConsumerState<SignUpScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  final _emailFocus = FocusNode();
  final _passwordFocus = FocusNode();
  final _nameFocus = FocusNode();

  String? _emailError;
  String? _passwordError;
  String? _nameError;

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
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final name = _nameController.text.trim();

    setState(() {
      _emailError = email.isEmpty || !email.contains('@')
          ? 'Please enter a valid email.'
          : null;
      _passwordError = password.length < 6
          ? 'Please enter at least 6 characters.'
          : null;
      _nameError = name.isEmpty ? 'Please enter your name.' : null;
    });

    if (_emailError != null || _passwordError != null || _nameError != null) return;

    await ref.read(signUpViewModelProvider.notifier).signUp(
          email: email,
          password: password,
          displayName: name,
        );
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AsyncValue<void>>(signUpViewModelProvider, (prev, next) {
      next.when(
        data: (_) {
          if (context.mounted) context.go('/');
        },
        loading: () {},
        error: (err, _) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(err.toString())),
          );
        },
      );
    });

    final isLoading = ref.watch(signUpViewModelProvider).isLoading;

    return Scaffold(
      appBar: AppBar(title: const Text('Sign Up')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(Sizes.size20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Create a new account',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              Gaps.v20,
              AuthTextField(
                label: 'Name',
                controller: _nameController,
                focusNode: _nameFocus,
                textInputAction: TextInputAction.next,
                onSubmitted: (_) => _emailFocus.requestFocus(),
                errorText: _nameError,
              ),
              Gaps.v16,
              AuthTextField(
                label: 'Email',
                controller: _emailController,
                focusNode: _emailFocus,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                onSubmitted: (_) => _passwordFocus.requestFocus(),
                errorText: _emailError,
              ),
              Gaps.v16,
              AuthTextField(
                label: 'Password',
                controller: _passwordController,
                focusNode: _passwordFocus,
                obscureText: true,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => _submit(),
                errorText: _passwordError,
              ),
              Gaps.v24,
              ElevatedButton(
                onPressed: isLoading ? null : _submit,
                child: isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Sign Up'),
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
