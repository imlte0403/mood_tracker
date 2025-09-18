import 'package:go_router/go_router.dart';
import 'package:mood_tracker/features/auth/screen/log_in_screen.dart';
import 'package:mood_tracker/features/auth/screen/sign_up_screen.dart';
import 'package:mood_tracker/features/home/home_screen.dart';
import 'package:mood_tracker/features/post/post_screen.dart';

final router = GoRouter(
  debugLogDiagnostics: true,
  initialLocation: LogInScreen.routeURL,
  routes: [
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
    GoRoute(
      path: HomeScreen.routeURL,
      name: HomeScreen.routeName,
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: PostScreen.routeURL,
      name: PostScreen.routeName,
      builder: (context, state) => const PostScreen(),
    ),
  ],
);