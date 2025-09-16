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
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FocusNode _emailFocus = FocusNode();
  final FocusNode _passwordFocus = FocusNode();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  void _submit() async {
    if (ref.read(loginProvider).isLoading) return;

    final form = _formKey.currentState;
    if (form == null || !form.validate()) return;

    await ref
        .read(loginProvider.notifier)
        .login(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );
  }

  void _onAuthStateChange(LoginState state) {
    state.status.when(
      data: (_) {
        final user = FirebaseAuth.instance.currentUser;
        if (user != null && context.mounted) context.go('/');
      },
      loading: () {},
      error: (err, _) {
        if (err is FirebaseAuthException && err.code == 'user-not-found') {
          if (context.mounted) context.push('/signup');
          return;
        }
        final message = err is Exception ? err.toString() : 'Sign-in failed.';
        if (!context.mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(message)));
      },
    );
  }

  Widget _buildHeader() {
    return const Text(
      'Welcome back!',
      textAlign: TextAlign.center,
      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
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
      _onAuthStateChange(next);
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
              _buildHeader(),
              Gaps.v20,
              Form(
                key: _formKey,
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
                onPressed: () => context.push('/signup'),
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
