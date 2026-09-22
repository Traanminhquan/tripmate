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
import '../../presentation/screens/itinerary/itinerary_screen.dart';
import '../../presentation/screens/itinerary/create_activity_screen.dart';
import '../../presentation/screens/itinerary/activity_detail_screen.dart';
import '../../presentation/screens/itinerary/edit_activity_screen.dart';
import '../../domain/entities/trip_activity.dart';
import '../../presentation/screens/expenses/expenses_screen.dart';
import '../../presentation/screens/expenses/create_expense_screen.dart';
import '../../presentation/screens/expenses/expense_detail_screen.dart';
import '../../presentation/screens/expenses/edit_expense_screen.dart';
import '../../domain/entities/expense.dart';
import '../../presentation/screens/members/members_screen.dart';
import '../../domain/entities/app_user.dart';
import '../../presentation/screens/profile/edit_profile_screen.dart';
import '../../presentation/screens/trips/trip_map_screen.dart';
import '../../presentation/screens/favorites/favorites_screen.dart';

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
                        path: 'members',
                        builder: (context, state) {
                          final tripId =
                              state.pathParameters['tripId']!;

                          return MembersScreen(
                            tripId: tripId,
                          );
                        },
                      ),
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
                      GoRoute(
                        path: 'map',
                        builder: (
                          context,
                          state,
                        ) {
                          final tripId =
                              state.pathParameters[
                                  'tripId']!;

                          return TripMapScreen(
                            tripId: tripId,
                          );
                        },
                      ),
                      GoRoute(
                        path: 'itinerary',
                        builder: (context, state) {
                          final tripId =
                              state.pathParameters['tripId']!;

                          return ItineraryScreen(
                            tripId: tripId,
                          );
                        },
                        routes: [
                          GoRoute(
                            path: 'create',
                            builder: (context, state) {
                              final tripId =
                                  state.pathParameters['tripId']!;

                              return CreateActivityScreen(
                                tripId: tripId,
                              );
                            },
                          ),

                          GoRoute(
                            path: ':activityId',
                            builder: (context, state) {
                              final tripId =
                                  state.pathParameters['tripId']!;

                              final activityId =
                                  state.pathParameters['activityId']!;

                              return ActivityDetailScreen(
                                tripId: tripId,
                                activityId: activityId,
                              );
                            },
                            routes: [
                              GoRoute(
                                path: 'edit',
                                builder: (context, state) {
                                  final activity =
                                      state.extra as TripActivity;

                                  return EditActivityScreen(
                                    activity: activity,
                                  );
                                },
                              ),
                            ],
                          ),
                        ],
                      ),

                      GoRoute(
                        path: 'expenses',
                        builder: (context, state) {
                          final tripId =
                              state.pathParameters['tripId']!;

                          return ExpensesScreen(
                            tripId: tripId,
                          );
                        },
                        routes: [
                          GoRoute(
                            path: 'create',
                            builder: (context, state) {
                              final tripId =
                                  state.pathParameters['tripId']!;

                              return CreateExpenseScreen(
                                tripId: tripId,
                              );
                            },
                          ),

                          GoRoute(
                            path: ':expenseId',
                            builder: (context, state) {
                              final tripId =
                                  state.pathParameters['tripId']!;

                              final expenseId =
                                  state.pathParameters['expenseId']!;

                              return ExpenseDetailScreen(
                                tripId: tripId,
                                expenseId: expenseId,
                              );
                            },
                            routes: [
                              GoRoute(
                                path: 'edit',
                                builder: (context, state) {
                                  final expense =
                                      state.extra as Expense;

                                  return EditExpenseScreen(
                                    expense: expense,
                                  );
                                },
                              ),
                            ],
                          ),
                        ],
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

              GoRoute(
                path: '/favorites',
                builder: (
                  context,
                  state,
                ) {
                  return const FavoritesScreen();
                },
              ),
            ],
          ),

          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/profile',
                builder: (
                  context,
                  state,
                ) {
                  return const ProfileScreen();
                },
                routes: [
                  GoRoute(
                    path: 'edit',
                    builder: (
                      context,
                      state,
                    ) {
                      final user =
                          state.extra
                              as AppUser;

                      return EditProfileScreen(
                        user: user,
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    ],
  );
});