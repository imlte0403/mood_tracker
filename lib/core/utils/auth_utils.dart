import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mood_tracker/features/auth/screen/sign_up_screen.dart';
import 'package:mood_tracker/features/home/home_screen.dart';

class AuthUtils {
  const AuthUtils._();

  static void handleAuthStateChange(
    BuildContext context,
    AsyncValue<void> state, {
    VoidCallback? onSuccess,
    VoidCallback? onUserNotFound,
    String fallbackErrorMessage = 'Sign-in failed.',
  }) {
    state.when(
      data: (_) {
        final user = FirebaseAuth.instance.currentUser;
        if (user != null && context.mounted) {
          if (onSuccess != null) {
            onSuccess();
          } else {
            context.go(HomeScreen.routeURL);
          }
        }
      },
      loading: () {},
      error: (err, _) {
        if (!context.mounted) return;
        if (err is FirebaseAuthException && err.code == 'user-not-found') {
          if (onUserNotFound != null) {
            onUserNotFound();
          } else {
            context.go(SignUpScreen.routeURL);
          }
          return;
        }
        final message = err is Exception
            ? err.toString()
            : fallbackErrorMessage;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(message)));
      },
    );
  }
}
