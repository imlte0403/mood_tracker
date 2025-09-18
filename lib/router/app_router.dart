import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mood_tracker/features/auth/screen/log_in_screen.dart';
import 'package:mood_tracker/features/auth/screen/sign_up_screen.dart';
import 'package:mood_tracker/features/home/home_screen.dart';
import 'package:mood_tracker/features/post/post_screen.dart';
//import 'package:mood_tracker/services/firebase_service.dart';

final goRouterProvider = Provider<GoRouter>((ref) {
  //final authState = ref.watch(authStateChangesProvider);

  return GoRouter(
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
    // redirect: (context, state) {
    //   final user = authState.asData?.value;
    //   final isAuthenticated = user != null;
    //   final loggingIn =
    //       state.uri.path == LogInScreen.routeURL ||
    //       state.uri.path == SignUpScreen.routeURL;

    //   if (authState.isLoading) {
    //     return null;
    //   }

    //   if (!isAuthenticated && !loggingIn) {
    //     return LogInScreen.routeURL;
    //   }

    //   if (isAuthenticated && loggingIn) {
    //     return HomeScreen.routeURL;
    //   }

    //   return null;
    // },
  );
});
