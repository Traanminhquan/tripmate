import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../presentation/providers/auth_provider.dart';
import '../../presentation/screens/auth/login_screen.dart';
import '../../presentation/screens/auth/register_screen.dart';
import '../../presentation/screens/explore/explore_screen.dart';
import '../../presentation/screens/home/home_screen.dart';
import '../../presentation/screens/main/main_screen.dart';
import '../../presentation/screens/profile/profile_screen.dart';
import '../../presentation/screens/splash/splash_screen.dart';
import '../../presentation/screens/trips/trips_screen.dart';
import '../../presentation/screens/trips/create_trip_screen.dart';
import '../../presentation/screens/trips/trip_detail_screen.dart';
import '../../presentation/screens/trips/edit_trip_screen.dart';
import '../../domain/entities/trip.dart';

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

      StatefulShellRoute.indexedStack(
        builder: (
          context,
          state,
          navigationShell,
        ) {
          return MainScreen(
            navigationShell: navigationShell,
          );
        },

        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/home',
                builder: (context, state) {
                  return const HomeScreen();
                },
              ),
            ],
          ),

          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/trips',
                builder: (context, state) {
                  return const TripsScreen();
                },
                routes: [
                  GoRoute(
                    path: 'create',
                    builder: (context, state) {
                      return const CreateTripScreen();
                    },
                  ),

                  GoRoute(
                    path: ':tripId',
                    builder: (context, state) {
                      final tripId =
                          state.pathParameters['tripId']!;

                      return TripDetailScreen(
                        tripId: tripId,
                      );
                    },
                    routes: [
                      GoRoute(
                        path: 'edit',
                        builder: (context, state) {
                          final trip =
                              state.extra as Trip;

                          return EditTripScreen(
                            trip: trip,
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),

          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/explore',
                builder: (context, state) {
                  return const ExploreScreen();
                },
              ),
            ],
          ),

          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/profile',
                builder: (context, state) {
                  return const ProfileScreen();
                },
              ),
            ],
          ),
        ],
      ),
    ],
  );
});