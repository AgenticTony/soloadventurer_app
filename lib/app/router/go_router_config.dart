import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soloadventurer/features/auth/presentation/providers/auth_notifier_provider.dart';
import 'package:soloadventurer/features/auth/presentation/screens/auth_wrapper.dart';
import 'package:soloadventurer/features/auth/presentation/screens/login_screen.dart';
import 'package:soloadventurer/features/auth/presentation/screens/signup_screen.dart';
import 'package:soloadventurer/features/auth/presentation/screens/verify_email_screen.dart';
import 'package:soloadventurer/features/auth/presentation/screens/forgot_password_screen.dart';
import 'package:soloadventurer/features/auth/presentation/screens/confirm_password_reset_screen.dart';
import 'package:soloadventurer/features/performance/presentation/screens/performance_benchmark_screen.dart';
import 'package:soloadventurer/features/home/presentation/screens/home_screen.dart';
import 'package:soloadventurer/features/profile/presentation/screens/profile_screen.dart';
import 'package:soloadventurer/features/profile/presentation/screens/edit_profile_screen.dart';
import 'package:soloadventurer/features/profile/presentation/screens/profile_settings_screen.dart';
import 'package:soloadventurer/features/core/presentation/screens/operation_queue_screen.dart';
import 'package:soloadventurer/features/safety/presentation/screens/safety_hub_screen.dart';
import 'package:soloadventurer/features/safety/presentation/screens/trusted_contacts_screen.dart';
import 'package:soloadventurer/features/safety/presentation/screens/add_edit_trusted_contact_screen.dart';
import 'package:soloadventurer/features/safety/presentation/screens/check_in_home_screen.dart';
import 'package:soloadventurer/features/safety/presentation/screens/manual_check_in_screen.dart';
import 'package:soloadventurer/features/safety/presentation/screens/schedule_check_in_screen.dart';
import 'package:soloadventurer/features/safety/presentation/screens/check_in_history_screen.dart';
import 'package:soloadventurer/features/safety/presentation/screens/emergency_sos_screen.dart';
import 'package:soloadventurer/features/safety/presentation/screens/status_update_screen.dart';
import 'package:soloadventurer/features/safety/presentation/screens/location_sharing_screen.dart';
import 'package:soloadventurer/features/offline/presentation/screens/sync_settings_screen.dart';
import 'package:soloadventurer/features/notifications/presentation/screens/notification_settings_screen.dart';
import 'package:soloadventurer/features/notifications/presentation/screens/notification_history_screen.dart';
import 'package:soloadventurer/features/onboarding/presentation/screens/onboarding_screen.dart';
import 'package:soloadventurer/features/onboarding/presentation/screens/starter_itinerary_screen.dart';
import 'package:soloadventurer/features/travel/domain/models/itinerary.dart';
import 'package:soloadventurer/features/travel/presentation/screens/itinerary_screen.dart';
import 'package:soloadventurer/features/safety/domain/entities/check_in.dart';
import 'package:soloadventurer/features/safety/domain/entities/trusted_contact.dart';
import 'package:soloadventurer/features/destination_discovery/presentation/screens/destination_discovery_screen.dart';
import 'package:soloadventurer/features/destination_discovery/presentation/screens/destination_detail_screen.dart';
import 'package:soloadventurer/features/destination_discovery/presentation/screens/recommendations_screen.dart';
import 'package:soloadventurer/features/destination_discovery/presentation/screens/curated_lists_screen.dart';
import 'package:soloadventurer/features/destination_discovery/presentation/screens/curated_list_detail_screen.dart';
import 'package:soloadventurer/features/destination_discovery/presentation/screens/saved_destinations_screen.dart';
import 'package:soloadventurer/features/journal/presentation/screens/journal_list_screen.dart';
import 'package:soloadventurer/features/journal/presentation/screens/journal_entry_detail_screen.dart';
import 'package:soloadventurer/features/journal/presentation/screens/create_journal_entry_screen.dart';
import 'package:soloadventurer/features/journal/presentation/screens/journal_search_screen.dart';
import 'package:soloadventurer/features/journal/presentation/screens/trip_list_screen.dart';
import 'package:soloadventurer/features/journal/presentation/screens/trip_detail_screen.dart';
import 'package:soloadventurer/features/journal/presentation/screens/trip_overview_screen.dart';
import 'package:soloadventurer/features/journal/presentation/screens/create_trip_screen.dart';
import 'package:soloadventurer/features/journal/presentation/screens/journal_map_screen.dart';
import 'package:soloadventurer/features/journal/presentation/screens/memory_timeline_screen.dart';
import 'package:soloadventurer/features/journal/presentation/screens/tag_list_screen.dart';
import 'package:soloadventurer/app/router/go_router_service.dart';
import 'package:soloadventurer/core/widgets/main_navigation_bar.dart';

/// Global navigator key for go_router
final goRouterNavigatorKey = GlobalKey<NavigatorState>();

/// Provider for the GoRouterService
///
/// This provides access to programmatic navigation from providers
/// and other non-UI code.
final goRouterServiceProvider = Provider<GoRouterService>((ref) {
  return GoRouterService(navigatorKey: goRouterNavigatorKey);
});

/// Provider for the go_router instance
///
/// This provider creates and configures the go_router with all app routes,
/// auth redirects, and error handling.
final goRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);

  return GoRouter(
    debugLogDiagnostics: true,
    navigatorKey: goRouterNavigatorKey,
    initialLocation: '/home',
    redirect: (context, state) {
      // Don't redirect while auth state is loading
      // This prevents navigation issues during initial app load
      if (authState.isLoading) {
        return null;
      }

      // Don't redirect if there's an error - let the error screen show
      if (authState.hasError) {
        return null;
      }

      // Extract values from the AsyncValue
      final isAuthenticated = authState.value?.isAuthenticated ?? false;
      final requiresVerification =
          authState.value?.requiresEmailVerification ?? false;
      final requiresPasswordReset =
          authState.value?.requiresPasswordReset ?? false;

      // Get the current location
      final currentLoc = state.matchedLocation;

      // Priority 1: Email verification
      if (requiresVerification && currentLoc != '/verify-email') {
        return '/verify-email';
      }

      // Priority 2: Password reset
      if (requiresPasswordReset && currentLoc != '/confirm-password-reset') {
        return '/confirm-password-reset';
      }

      // Check if this is an auth route
      final isAuthRoute = currentLoc == '/' ||
          currentLoc == '/login' ||
          currentLoc == '/signup' ||
          currentLoc == '/forgot-password' ||
          currentLoc == '/verify-email' ||
          currentLoc == '/confirm-password-reset' ||
          currentLoc == '/onboarding';

      // Redirect unauthenticated users to login
      if (!isAuthenticated && !isAuthRoute) {
        return '/login';
      }

      // Redirect authenticated users away from auth screens (except verification/reset)
      if (isAuthenticated &&
          isAuthRoute &&
          !requiresVerification &&
          !requiresPasswordReset) {
        return '/home';
      }

      // No redirect needed
      return null;
    },
    routes: [
      // ============================================================
      // AUTH ROUTES (no bottom nav)
      // ============================================================

      GoRoute(
        path: '/',
        pageBuilder: (context, state) =>
            const MaterialPage(child: AuthWrapper()),
      ),

      GoRoute(
        path: '/login',
        pageBuilder: (context, state) =>
            const MaterialPage(child: LoginScreen()),
      ),

      GoRoute(
        path: '/signup',
        pageBuilder: (context, state) =>
            const MaterialPage(child: SignUpScreen()),
      ),

      GoRoute(
        path: '/verify-email',
        pageBuilder: (context, state) =>
            const MaterialPage(child: VerifyEmailScreen()),
      ),

      GoRoute(
        path: '/forgot-password',
        pageBuilder: (context, state) =>
            const MaterialPage(child: ForgotPasswordScreen()),
      ),

      GoRoute(
        path: '/confirm-password-reset',
        pageBuilder: (context, state) =>
            const MaterialPage(child: ConfirmPasswordResetScreen()),
      ),

      // ============================================================
      // ONBOARDING ROUTES (no bottom nav)
      // ============================================================

      GoRoute(
        path: '/onboarding',
        pageBuilder: (context, state) =>
            const MaterialPage(child: OnboardingScreen()),
        routes: [
          GoRoute(
            path: 'starter-itinerary',
            pageBuilder: (context, state) {
              final itinerary = state.extra as Itinerary?;
              if (itinerary == null) {
                return const MaterialPage(child: _NotFoundScreen());
              }
              return MaterialPage(
                  child: StarterItineraryScreen(itinerary: itinerary));
            },
          ),
        ],
      ),

      // ============================================================
      // OTHER ROUTES WITHOUT BOTTOM NAV
      // ============================================================

      GoRoute(
        path: '/edit-profile',
        pageBuilder: (context, state) {
          final isInitialSetup =
              state.uri.queryParameters['isInitialSetup'] == 'true';
          return MaterialPage(
              child: EditProfileScreen(isInitialSetup: isInitialSetup));
        },
      ),

      GoRoute(
        path: '/operation-queue',
        pageBuilder: (context, state) =>
            const MaterialPage(child: OperationQueueScreen()),
      ),

      GoRoute(
        path: '/performance/benchmark',
        pageBuilder: (context, state) =>
            const MaterialPage(child: PerformanceBenchmarkScreen()),
      ),

      // ============================================================
      // MAIN SHELL ROUTE WITH BOTTOM NAVIGATION
      // ============================================================
      // Uses StatefulShellRoute to maintain state across tab switches

      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return MainNavigationBar(child: navigationShell);
        },
        branches: [
          // ============================================================
          // BRANCH 0: HOME
          // ============================================================

          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/home',
                pageBuilder: (context, state) =>
                    const MaterialPage(child: HomeScreen()),
                routes: [
                  // Travel itinerary details
                  GoRoute(
                    path: 'itinerary/:id',
                    pageBuilder: (context, state) {
                      final itineraryId = state.pathParameters['id'] ?? '';
                      return MaterialPage(
                        child: ItineraryScreen(
                            key: ValueKey(itineraryId), itineraryId: itineraryId),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),

          // ============================================================
          // BRANCH 1: JOURNAL
          // ============================================================

          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/journal',
                pageBuilder: (context, state) =>
                    const MaterialPage(child: JournalListScreen()),
                routes: [
                  // Journal search
                  GoRoute(
                    path: 'search',
                    pageBuilder: (context, state) =>
                        const MaterialPage(child: JournalSearchScreen()),
                  ),
                  // Create journal entry
                  GoRoute(
                    path: 'create',
                    pageBuilder: (context, state) =>
                        const MaterialPage(child: CreateJournalEntryScreen()),
                  ),
                  // Create trip
                  GoRoute(
                    path: 'trips/create',
                    pageBuilder: (context, state) =>
                        const MaterialPage(child: CreateTripScreen()),
                  ),
                  // Journal entry detail
                  GoRoute(
                    path: 'entry/:id',
                    pageBuilder: (context, state) {
                      final entryId = state.pathParameters['id'] ?? '';
                      return MaterialPage(
                        child: JournalEntryDetailScreen(
                            key: ValueKey(entryId), entryId: entryId),
                      );
                    },
                  ),
                  // Trip list
                  GoRoute(
                    path: 'trips',
                    pageBuilder: (context, state) =>
                        const MaterialPage(child: TripListScreen()),
                    routes: [
                      // Trip detail
                      GoRoute(
                        path: ':id',
                        pageBuilder: (context, state) {
                          final tripId = state.pathParameters['id'] ?? '';
                          return MaterialPage(
                            child: TripDetailScreen(
                                key: ValueKey(tripId), tripId: tripId),
                          );
                        },
                        routes: [
                          // Trip overview
                          GoRoute(
                            path: 'overview',
                            pageBuilder: (context, state) {
                              final tripId = state.pathParameters['id'] ?? '';
                              return MaterialPage(
                                child: TripOverviewScreen(
                                    key: ValueKey(tripId), tripId: tripId),
                              );
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                  // Journal map
                  GoRoute(
                    path: 'map',
                    pageBuilder: (context, state) =>
                        const MaterialPage(child: JournalMapScreen()),
                  ),
                  // Memory timeline
                  GoRoute(
                    path: 'memory-timeline',
                    pageBuilder: (context, state) =>
                        const MaterialPage(child: MemoryTimelineScreen()),
                  ),
                  // Tags
                  GoRoute(
                    path: 'tags',
                    pageBuilder: (context, state) =>
                        const MaterialPage(child: TagListScreen()),
                  ),
                ],
              ),
            ],
          ),

          // ============================================================
          // BRANCH 2: DESTINATIONS
          // ============================================================

          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/destinations',
                pageBuilder: (context, state) =>
                    const MaterialPage(child: DestinationDiscoveryScreen()),
                routes: [
                  // Destination detail
                  GoRoute(
                    path: 'detail/:id',
                    pageBuilder: (context, state) {
                      final destinationId = state.pathParameters['id'] ?? '';
                      return MaterialPage(
                        child: DestinationDetailScreen(
                            key: ValueKey(destinationId),
                            destinationId: destinationId),
                      );
                    },
                  ),
                  // Recommendations
                  GoRoute(
                    path: 'recommendations',
                    pageBuilder: (context, state) =>
                        const MaterialPage(child: RecommendationsScreen()),
                  ),
                  // Curated lists
                  GoRoute(
                    path: 'curated-lists',
                    pageBuilder: (context, state) =>
                        const MaterialPage(child: CuratedListsScreen()),
                    routes: [
                      GoRoute(
                        path: 'detail/:id',
                        pageBuilder: (context, state) {
                          final listId = state.pathParameters['id'] ?? '';
                          return MaterialPage(
                            child: CuratedListDetailScreen(
                                key: ValueKey(listId), listId: listId),
                          );
                        },
                      ),
                    ],
                  ),
                  // Saved destinations
                  GoRoute(
                    path: 'saved',
                    pageBuilder: (context, state) =>
                        const MaterialPage(child: SavedDestinationsScreen()),
                  ),
                ],
              ),
            ],
          ),

          // ============================================================
          // BRANCH 3: SAFETY
          // ============================================================

          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/safety',
                pageBuilder: (context, state) =>
                    const MaterialPage(child: SafetyHubScreen()),
                routes: [
                  // Trusted Contacts
                  GoRoute(
                    path: 'trusted-contacts',
                    pageBuilder: (context, state) =>
                        const MaterialPage(child: TrustedContactsScreen()),
                    routes: [
                      GoRoute(
                        path: 'add',
                        pageBuilder: (context, state) =>
                            const MaterialPage(child: AddEditTrustedContactScreen()),
                      ),
                      GoRoute(
                        path: 'edit',
                        pageBuilder: (context, state) {
                          final contact = state.extra as TrustedContact?;
                          return MaterialPage(
                              child: AddEditTrustedContactScreen(contact: contact));
                        },
                      ),
                    ],
                  ),

                  // Check-ins
                  GoRoute(
                    path: 'check-ins',
                    pageBuilder: (context, state) =>
                        const MaterialPage(child: CheckInHomeScreen()),
                    routes: [
                      GoRoute(
                        path: 'manual',
                        pageBuilder: (context, state) {
                          final existingCheckIn = state.extra as CheckIn?;
                          return MaterialPage(
                              child: ManualCheckInScreen(
                                  existingCheckIn: existingCheckIn));
                        },
                      ),
                      GoRoute(
                        path: 'schedule',
                        pageBuilder: (context, state) {
                          final tripId = state.uri.queryParameters['tripId'];
                          return MaterialPage(
                              child: ScheduleCheckInScreen(tripId: tripId));
                        },
                      ),
                      GoRoute(
                        path: 'history',
                        pageBuilder: (context, state) =>
                            const MaterialPage(child: CheckInHistoryScreen()),
                      ),
                    ],
                  ),

                  // Emergency & SOS
                  GoRoute(
                    path: 'emergency',
                    pageBuilder: (context, state) =>
                        const MaterialPage(child: EmergencySOSScreen()),
                  ),

                  GoRoute(
                    path: 'status-update',
                    pageBuilder: (context, state) =>
                        const MaterialPage(child: StatusUpdateScreen()),
                  ),

                  // Location Sharing
                  GoRoute(
                    path: 'location-sharing',
                    pageBuilder: (context, state) =>
                        const MaterialPage(child: LocationSharingScreen()),
                  ),
                ],
              ),
            ],
          ),

          // ============================================================
          // BRANCH 4: PROFILE
          // ============================================================

          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/profile',
                pageBuilder: (context, state) =>
                    const MaterialPage(child: ProfileScreen()),
                routes: [
                  // Profile settings
                  GoRoute(
                    path: 'settings',
                    pageBuilder: (context, state) =>
                        const MaterialPage(child: ProfileSettingsScreen()),
                  ),
                  // Sync settings
                  GoRoute(
                    path: 'sync-settings',
                    pageBuilder: (context, state) =>
                        const MaterialPage(child: SyncSettingsScreen()),
                  ),
                  // Notification settings
                  GoRoute(
                    path: 'notification-settings',
                    pageBuilder: (context, state) =>
                        const MaterialPage(child: NotificationSettingsScreen()),
                  ),
                  // Notification history
                  GoRoute(
                    path: 'notification-history',
                    pageBuilder: (context, state) =>
                        const MaterialPage(child: NotificationHistoryScreen()),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    ],

    // Error page for 404s
    errorPageBuilder: (context, state) =>
        const MaterialPage(child: _NotFoundScreen()),
  );
});

/// 404 Not Found Screen
class _NotFoundScreen extends StatelessWidget {
  const _NotFoundScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Not Found')),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 72, color: Colors.red),
            SizedBox(height: 16),
            Text(
              'Page not found',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text('The requested page could not be found.'),
          ],
        ),
      ),
    );
  }
}

/// Extension to provide easy access to go_router methods from BuildContext
extension GoRouterExtension on BuildContext {
  /// Navigate to a new location
  void go(String location, {Object? extra}) =>
      GoRouter.of(this).go(location, extra: extra);

  /// Push a new location onto the navigation stack
  void push(String location, {Object? extra}) =>
      GoRouter.of(this).push(location, extra: extra);

  /// Replace the current location
  void replace(String location, {Object? extra}) =>
      GoRouter.of(this).replace(location, extra: extra);

  /// Pop the current location
  void pop<T extends Object?>([T? result]) => GoRouter.of(this).pop(result);

  /// Get the current location
  String get location => GoRouter.of(this).state.matchedLocation;
}
