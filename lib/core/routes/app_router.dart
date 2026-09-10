import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../presentation/providers/auth_provider.dart';
import '../../presentation/screens/auth/login_screen.dart';
import '../../presentation/screens/auth/register_screen.dart';
import '../../presentation/screens/home/home_screen.dart';
import '../../presentation/screens/splash/splash_screen.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: '/splash',

    redirect: (context, state) {
      final currentLocation = state.matchedLocation;

      if (authState.isLoading) {
        if (currentLocation != '/splash') {
          return '/splash';
        }

        return null;
      }

      final user = authState.value;

      final isLoggedIn = user != null;

      final isAuthRoute =
          currentLocation == '/login' ||
          currentLocation == '/register';

      final isSplash =
          currentLocation == '/splash';

      if (!isLoggedIn) {
        if (isAuthRoute) {
          return null;
        }

        return '/login';
      }

      if (isLoggedIn) {
        if (isAuthRoute || isSplash) {
          return '/home';
        }
      }

      return null;
    },

    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) {
          return const SplashScreen();
        },
      ),

      GoRoute(
        path: '/login',
        builder: (context, state) {
          return const LoginScreen();
        },
      ),

      GoRoute(
        path: '/register',
        builder: (context, state) {
          return const RegisterScreen();
        },
      ),

      GoRoute(
        path: '/home',
        builder: (context, state) {
          return const HomeScreen();
        },
      ),
    ],
  );
});