import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mood_tracker/constants/gaps.dart';
import 'package:mood_tracker/constants/sizes.dart';
import 'package:mood_tracker/features/auth/widget/auth_textfield.dart';
import 'package:mood_tracker/features/auth/widget/auth_btn.dart';
import 'package:mood_tracker/features/auth/view_model/login_view_model.dart';

class LogInScreen extends ConsumerStatefulWidget {
  static const String routeName = 'login';
  static const String routeURL = '/login';

  const LogInScreen({super.key});

  @override
  ConsumerState<LogInScreen> createState() => _LogInScreenState();
}

class _LogInScreenState extends ConsumerState<LogInScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FocusNode _emailFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();

  String? _emailError;
  String? _passwordError;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  void _submit() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    setState(() {
      _emailError = email.isEmpty || !email.contains('@')
          ? 'Please enter a valid email.'
          : null;
      _passwordError = password.length < 6
          ? 'Please enter at least 6 characters.'
          : null;
    });

    if (_emailError != null || _passwordError != null) return;

    await ref.read(loginViewModelProvider.notifier).signIn(
          email: email,
          password: password,
        );
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AsyncValue<void>>(loginViewModelProvider, (prev, next) {
      next.when(
        data: (_) {
          // 성공 시 홈으로 이동
          if (context.mounted) context.go('/');
        },
        loading: () {},
        error: (err, _) {
          if (err is FirebaseAuthException && err.code == 'user-not-found') {
            // 계정이 없으면 회원가입 화면으로 이동
            if (context.mounted) context.push('/signup');
            return;
          }
          final message =
              err is Exception ? err.toString() : 'Sign-in failed.';
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(message)),
          );
        },
      );
    });

    final isLoading = ref.watch(loginViewModelProvider).isLoading;

    return Scaffold(
      appBar: AppBar(title: const Text('Log In')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(Sizes.size20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Welcome back!',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              Gaps.v20,
              AuthTextField(
                label: 'Email',
                controller: _emailController,
                focusNode: _emailFocusNode,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                onSubmitted: (_) => _passwordFocusNode.requestFocus(),
                errorText: _emailError,
              ),
              Gaps.v16,
              AuthTextField(
                label: 'Password',
                controller: _passwordController,
                focusNode: _passwordFocusNode,
                obscureText: true,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => _submit(),
                errorText: _passwordError,
              ),
              Gaps.v24,
              AuthBtn(
                label: 'Log In',
                isLoading: isLoading,
                onPressed: _submit,
              ),
              Gaps.v12,
              TextButton(
                onPressed: () => context.push('/signup'),
                child: const Text("Don't have an account? Sign Up"),
              ),
              Gaps.v20,
              const Divider(),
              Gaps.v20,
              AuthBtn(
                label: 'Continue with Google',
                leading: const Icon(Icons.g_mobiledata),
                isLoading: isLoading,
                onPressed: () =>
                    ref.read(loginViewModelProvider.notifier).signInWithGoogle(),
              ),
              Gaps.v12,
              AuthBtn(
                label: 'Continue with Apple',
                leading: const Icon(Icons.apple),
                isLoading: isLoading,
                onPressed: () =>
                    ref.read(loginViewModelProvider.notifier).signInWithApple(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
