import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mood_tracker/features/auth/screen/log_in_screen.dart';
import 'package:mood_tracker/features/auth/screen/sign_up_screen.dart';

final goRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    debugLogDiagnostics: true,
    initialLocation: LogInScreen.routeURL,
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const Scaffold(
          body: Center(
            child: Text('Mood Tracker App'),
          ),
        ),
      ),
      GoRoute(
        path: LogInScreen.routeURL,
        name: LogInScreen.routeName,
        builder: (context, state) => const LogInScreen(),
      ),
      GoRoute(
        path: SignUpScreen.routeURL,
        name: SignUpScreen.routeName,
        builder: (context, state) => const SignUpScreen(),
      ),
    ],
  );
});
