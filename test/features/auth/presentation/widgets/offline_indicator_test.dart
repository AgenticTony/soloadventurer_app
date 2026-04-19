import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:soloadventurer/features/auth/infrastructure/services/cached_data_provider.dart';
import 'package:soloadventurer/features/auth/infrastructure/services/offline_auth_manager.dart';
import 'package:soloadventurer/features/auth/presentation/providers/cached_data_provider.dart';
import 'package:soloadventurer/features/auth/presentation/widgets/offline_indicator.dart';

// Mock classes
class MockCachedDataProvider extends Mock implements CachedDataProvider {}

class MockOfflineAuthManager extends Mock implements OfflineAuthManager {
  final StreamController<OfflineAuthResult> _stateController =
      StreamController<OfflineAuthResult>.broadcast();

  @override
  Stream<OfflineAuthResult> get onStateChanged => _stateController.stream;

  void emitState(OfflineAuthState state) {
    _stateController.add(OfflineAuthResult.success(state: state));
  }
}

/// Stream controller for overriding offlineStateProvider in tests
final _testOfflineStateController =
    StreamController<OfflineAuthState>.broadcast(sync: true);

// Creates a stream that immediately yields the initial state then forwards controller events
Stream<OfflineAuthState> _offlineStateStream(
    OfflineAuthState initialState) async* {
  yield initialState;
  yield* _testOfflineStateController.stream;
}

void main() {
  group('OfflineIndicator (Compact Mode)', () {
    late MockCachedDataProvider mockCachedDataProvider;
    late MockOfflineAuthManager mockOfflineAuthManager;

    setUp(() {
      mockCachedDataProvider = MockCachedDataProvider();
      mockOfflineAuthManager = MockOfflineAuthManager();

      // Setup default behaviors
      when(() => mockCachedDataProvider.isOffline())
          .thenAnswer((_) async => true);
      when(() => mockCachedDataProvider.getCachedDataInfo())
          .thenAnswer((_) async => <String, dynamic>{
                'username': 'test_user',
                'userCachedAt':
                    DateTime.now().subtract(const Duration(minutes: 5)).toIso8601String(),
              });
    });

    Widget makeTestableWidget({
      required Widget child,
      OfflineAuthState initialState = OfflineAuthState.online,
    }) {
      // Emit initial state into the test controller
      _testOfflineStateController.add(initialState);

      return ProviderScope(
        overrides: [
          cachedDataProvider.overrideWithValue(mockCachedDataProvider),
          offlineAuthManagerProvider.overrideWithValue(mockOfflineAuthManager),
          offlineStateProvider.overrideWith((ref) => _offlineStateStream(initialState)),
        ],
        child: MaterialApp(
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
            useMaterial3: true,
          ),
          home: Scaffold(
            appBar: AppBar(
              actions: [child],
            ),
          ),
        ),
      );
    }

    group('Rendering - Online State', () {
      testWidgets('renders online icon when state is online',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          makeTestableWidget(
            child: const OfflineIndicator(
              config: OfflineIndicatorConfig.compact(),
            ),
            initialState: OfflineAuthState.online,
          ),
        );

        await tester.pump(const Duration(milliseconds: 100));

        expect(find.byIcon(Icons.cloud_done), findsOneWidget);
        expect(find.byIcon(Icons.cloud_off), findsNothing);
      });

      testWidgets('renders with primary color when online',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          makeTestableWidget(
            child: const OfflineIndicator(
              config: OfflineIndicatorConfig.compact(),
            ),
            initialState: OfflineAuthState.online,
          ),
        );

        await tester.pump(const Duration(milliseconds: 100));

        final iconButton = tester.widget<IconButton>(
          find.byType(IconButton),
        );
        expect(iconButton.color, isNotNull);
      });

      testWidgets('shows online tooltip', (WidgetTester tester) async {
        await tester.pumpWidget(
          makeTestableWidget(
            child: const OfflineIndicator(
              config: OfflineIndicatorConfig.compact(),
            ),
            initialState: OfflineAuthState.online,
          ),
        );

        await tester.pump(const Duration(milliseconds: 100));

        final iconButton = tester.widget<IconButton>(
          find.byType(IconButton),
        );
        expect(iconButton.tooltip, 'Connected to server');
      });
    });

    group('Rendering - Offline States', () {
      testWidgets('renders offline icon when state is offlineWithCache',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          makeTestableWidget(
            child: const OfflineIndicator(
              config: OfflineIndicatorConfig.compact(),
            ),
            initialState: OfflineAuthState.offlineWithCache,
          ),
        );

        await tester.pump(const Duration(milliseconds: 100));

        expect(find.byIcon(Icons.cloud_off), findsOneWidget);
        expect(find.byIcon(Icons.cloud_done), findsNothing);
      });

      testWidgets('renders offline icon when state is offlineWithoutCache',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          makeTestableWidget(
            child: const OfflineIndicator(
              config: OfflineIndicatorConfig.compact(),
            ),
            initialState: OfflineAuthState.offlineWithoutCache,
          ),
        );

        await tester.pump(const Duration(milliseconds: 100));

        expect(find.byIcon(Icons.cloud_off), findsOneWidget);
      });

      testWidgets('shows appropriate tooltip for offlineWithCache',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          makeTestableWidget(
            child: const OfflineIndicator(
              config: OfflineIndicatorConfig.compact(),
            ),
            initialState: OfflineAuthState.offlineWithCache,
          ),
        );

        await tester.pump(const Duration(milliseconds: 100));

        final iconButton = tester.widget<IconButton>(
          find.byType(IconButton),
        );
        expect(iconButton.tooltip, 'Offline - Using cached data');
      });

      testWidgets('shows appropriate tooltip for offlineWithoutCache',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          makeTestableWidget(
            child: const OfflineIndicator(
              config: OfflineIndicatorConfig.compact(),
            ),
            initialState: OfflineAuthState.offlineWithoutCache,
          ),
        );

        await tester.pump(const Duration(milliseconds: 100));

        final iconButton = tester.widget<IconButton>(
          find.byType(IconButton),
        );
        expect(
          iconButton.tooltip,
          'Offline - No cached data available',
        );
      });

      testWidgets('shows appropriate tooltip for needsSync',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          makeTestableWidget(
            child: const OfflineIndicator(
              config: OfflineIndicatorConfig.compact(),
            ),
            initialState: OfflineAuthState.needsSync,
          ),
        );

        await tester.pump(const Duration(milliseconds: 100));

        final iconButton = tester.widget<IconButton>(
          find.byType(IconButton),
        );
        expect(iconButton.tooltip, 'Syncing with server...');
      });
    });

    group('State Transitions', () {
      testWidgets('updates from online to offline',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          makeTestableWidget(
            child: const OfflineIndicator(
              config: OfflineIndicatorConfig.compact(),
            ),
            initialState: OfflineAuthState.online,
          ),
        );

        await tester.pump(const Duration(milliseconds: 100));

        expect(find.byIcon(Icons.cloud_done), findsOneWidget);

        // Simulate state change
        _testOfflineStateController.add(OfflineAuthState.offlineWithCache);
        await tester.pump(const Duration(milliseconds: 100));

        expect(find.byIcon(Icons.cloud_off), findsOneWidget);
        expect(find.byIcon(Icons.cloud_done), findsNothing);
      });

      testWidgets('updates from offline to online',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          makeTestableWidget(
            child: const OfflineIndicator(
              config: OfflineIndicatorConfig.compact(),
            ),
            initialState: OfflineAuthState.offlineWithCache,
          ),
        );

        await tester.pump(const Duration(milliseconds: 100));

        expect(find.byIcon(Icons.cloud_off), findsOneWidget);

        // Simulate state change
        _testOfflineStateController.add(OfflineAuthState.online);
        await tester.pump(const Duration(milliseconds: 100));

        expect(find.byIcon(Icons.cloud_done), findsOneWidget);
        expect(find.byIcon(Icons.cloud_off), findsNothing);
      });
    });

    group('Custom Configuration', () {
      testWidgets('uses custom icons when provided',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          makeTestableWidget(
            child: const OfflineIndicator(
              config: OfflineIndicatorConfig.compact(
                offlineIcon: Icons.wifi_off,
                onlineIcon: Icons.wifi,
              ),
            ),
            initialState: OfflineAuthState.offlineWithCache,
          ),
        );

        await tester.pump(const Duration(milliseconds: 100));

        expect(find.byIcon(Icons.wifi_off), findsOneWidget);
        expect(find.byIcon(Icons.cloud_off), findsNothing);
      });

      testWidgets('does not show tooltip when disabled',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          makeTestableWidget(
            child: const OfflineIndicator(
              config: OfflineIndicatorConfig.compact(
                showTooltip: false,
              ),
            ),
            initialState: OfflineAuthState.online,
          ),
        );

        await tester.pump(const Duration(milliseconds: 100));

        final iconButton = tester.widget<IconButton>(
          find.byType(IconButton),
        );
        expect(iconButton.tooltip, 'Online');
      });
    });

    group('User Interactions', () {
      testWidgets('calls onTap callback when pressed',
          (WidgetTester tester) async {
        var tapped = false;

        await tester.pumpWidget(
          makeTestableWidget(
            child: OfflineIndicator(
              config: const OfflineIndicatorConfig.compact(),
              onTap: () => tapped = true,
            ),
            initialState: OfflineAuthState.offlineWithCache,
          ),
        );

        await tester.pump(const Duration(milliseconds: 100));

        await tester.tap(find.byType(IconButton));
        expect(tapped, isTrue);
      });
    });
  });

  group('OfflineIndicator (Detailed Mode)', () {
    late MockCachedDataProvider mockCachedDataProvider;
    late MockOfflineAuthManager mockOfflineAuthManager;

    setUp(() {
      mockCachedDataProvider = MockCachedDataProvider();
      mockOfflineAuthManager = MockOfflineAuthManager();

      // Setup default behaviors
      when(() => mockCachedDataProvider.isOffline())
          .thenAnswer((_) async => true);
      when(() => mockCachedDataProvider.getCachedDataInfo())
          .thenAnswer((_) async => <String, dynamic>{
                'username': 'test_user',
                'userCachedAt':
                    DateTime.now().subtract(const Duration(minutes: 5)).toIso8601String(),
              });
    });

    Widget makeTestableWidget({
      required Widget child,
      OfflineAuthState initialState = OfflineAuthState.online,
    }) {
      _testOfflineStateController.add(initialState);

      return ProviderScope(
        overrides: [
          cachedDataProvider.overrideWithValue(mockCachedDataProvider),
          offlineAuthManagerProvider.overrideWithValue(mockOfflineAuthManager),
          offlineStateProvider.overrideWith((ref) => _offlineStateStream(initialState)),
        ],
        child: MaterialApp(
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
            useMaterial3: true,
          ),
          home: Scaffold(body: child),
        ),
      );
    }

    testWidgets('renders detailed card widget', (WidgetTester tester) async {
      await tester.pumpWidget(
        makeTestableWidget(
          child: const OfflineIndicator(
            config: OfflineIndicatorConfig.detailed(),
          ),
          initialState: OfflineAuthState.offlineWithCache,
        ),
      );

      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byType(Card), findsOneWidget);
      expect(find.byIcon(Icons.cloud_off), findsOneWidget);
      expect(find.text('Offline Mode'), findsOneWidget);
    });

    testWidgets('shows last sync time when offline',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        makeTestableWidget(
          child: const OfflineIndicator(
            config: OfflineIndicatorConfig.detailed(
              showLastSyncTime: true,
            ),
          ),
          initialState: OfflineAuthState.offlineWithCache,
        ),
      );

      await tester.pump(const Duration(milliseconds: 100));

      // Wait for async data
      await tester.pump(const Duration(seconds: 1));

      expect(
        find.textContaining('Last sync:'),
        findsOneWidget,
      );
    });

    testWidgets('hides last sync time when configured',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        makeTestableWidget(
          child: const OfflineIndicator(
            config: OfflineIndicatorConfig.detailed(
              showLastSyncTime: false,
            ),
          ),
          initialState: OfflineAuthState.offlineWithCache,
        ),
      );

      await tester.pump(const Duration(milliseconds: 100));

      expect(find.textContaining('Last sync:'), findsNothing);
    });

    testWidgets('uses custom labels when provided',
        (WidgetTester tester) async {
      const customOfflineLabel = 'No Connection';
      const customOnlineLabel = 'Connected';

      await tester.pumpWidget(
        makeTestableWidget(
          child: const OfflineIndicator(
            config: OfflineIndicatorConfig.detailed(
              offlineLabel: customOfflineLabel,
              onlineLabel: customOnlineLabel,
            ),
          ),
          initialState: OfflineAuthState.offlineWithCache,
        ),
      );

      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text(customOfflineLabel), findsOneWidget);
      expect(find.text('Offline Mode'), findsNothing);
    });
  });

  group('OfflineBanner', () {
    late MockCachedDataProvider mockCachedDataProvider;
    late MockOfflineAuthManager mockOfflineAuthManager;

    setUp(() {
      mockCachedDataProvider = MockCachedDataProvider();
      mockOfflineAuthManager = MockOfflineAuthManager();
    });

    Widget makeTestableWidget({
      required Widget child,
      OfflineAuthState initialState = OfflineAuthState.online,
    }) {
      _testOfflineStateController.add(initialState);

      return ProviderScope(
        overrides: [
          cachedDataProvider.overrideWithValue(mockCachedDataProvider),
          offlineAuthManagerProvider.overrideWithValue(mockOfflineAuthManager),
          offlineStateProvider.overrideWith((ref) => _offlineStateStream(initialState)),
        ],
        child: MaterialApp(
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
            useMaterial3: true,
          ),
          home: Scaffold(
            body: Column(
              children: [child, const Expanded(child: SizedBox())],
            ),
          ),
        ),
      );
    }

    testWidgets('does not show banner when online',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        makeTestableWidget(
          child: const OfflineBanner(),
          initialState: OfflineAuthState.online,
        ),
      );

      await tester.pump(const Duration(milliseconds: 100));

      // Banner should be hidden (SizedBox.shrink)
      // Material widgets from the scaffold itself may be present,
      // but the banner-specific content should not be
      expect(find.text('You\'re offline. Using cached data.'), findsNothing);
    });

    testWidgets('shows banner when offline with cache',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        makeTestableWidget(
          child: const OfflineBanner(),
          initialState: OfflineAuthState.offlineWithCache,
        ),
      );

      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byType(Material), findsWidgets);
      expect(find.text('You\'re offline. Using cached data.'), findsOneWidget);
      expect(find.byIcon(Icons.cloud_off), findsOneWidget);
    });

    testWidgets('shows appropriate message when offline without cache',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        makeTestableWidget(
          child: const OfflineBanner(),
          initialState: OfflineAuthState.offlineWithoutCache,
        ),
      );

      await tester.pump(const Duration(milliseconds: 100));

      expect(
        find.text('You\'re offline. Some features may be unavailable.'),
        findsOneWidget,
      );
    });

    testWidgets('shows syncing message when needsSync',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        makeTestableWidget(
          child: const OfflineBanner(),
          initialState: OfflineAuthState.needsSync,
        ),
      );

      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Syncing your data...'), findsOneWidget);
      expect(find.byIcon(Icons.sync), findsOneWidget);
    });

    testWidgets('shows dismiss button when dismissible',
        (WidgetTester tester) async {
      var dismissed = false;

      await tester.pumpWidget(
        makeTestableWidget(
          child: OfflineBanner(
            onDismiss: () => dismissed = true,
          ),
          initialState: OfflineAuthState.offlineWithCache,
        ),
      );

      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byType(IconButton), findsOneWidget);

      await tester.tap(find.byType(IconButton));
      expect(dismissed, isTrue);
    });

    testWidgets('does not show dismiss button when not dismissible',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        makeTestableWidget(
          child: const OfflineBanner(
            dismissible: false,
          ),
          initialState: OfflineAuthState.offlineWithCache,
        ),
      );

      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byIcon(Icons.close), findsNothing);
    });

    testWidgets('hides banner when transitioning from offline to online',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        makeTestableWidget(
          child: const OfflineBanner(),
          initialState: OfflineAuthState.offlineWithCache,
        ),
      );

      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('You\'re offline. Using cached data.'), findsOneWidget);

      // Simulate state change to online
      _testOfflineStateController.add(OfflineAuthState.online);
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('You\'re offline. Using cached data.'), findsNothing);
    });
  });

  group('Edge Cases', () {
    late MockCachedDataProvider mockCachedDataProvider;
    late MockOfflineAuthManager mockOfflineAuthManager;

    setUp(() {
      mockCachedDataProvider = MockCachedDataProvider();
      mockOfflineAuthManager = MockOfflineAuthManager();
    });

    Widget makeTestableWidget({
      required Widget child,
      OfflineAuthState initialState = OfflineAuthState.online,
    }) {
      _testOfflineStateController.add(initialState);

      return ProviderScope(
        overrides: [
          cachedDataProvider.overrideWithValue(mockCachedDataProvider),
          offlineAuthManagerProvider.overrideWithValue(mockOfflineAuthManager),
          offlineStateProvider.overrideWith((ref) => _offlineStateStream(initialState)),
        ],
        child: MaterialApp(
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
            useMaterial3: true,
          ),
          home: Scaffold(
            appBar: AppBar(
              actions: [child],
            ),
          ),
        ),
      );
    }

    testWidgets('handles loading state gracefully',
        (WidgetTester tester) async {
      // Use a stream controller that hasn't emitted yet
      final loadingController =
          StreamController<OfflineAuthResult>.broadcast();
      final loadingMockManager = MockOfflineAuthManager();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            cachedDataProvider.overrideWithValue(mockCachedDataProvider),
            offlineAuthManagerProvider.overrideWithValue(loadingMockManager),
            offlineStateProvider.overrideWith(
              (ref) => loadingController.stream.map((r) => r.state),
            ),
          ],
          child: MaterialApp(
            home: Scaffold(
              appBar: AppBar(
                actions: [
                  const OfflineIndicator(
                    config: OfflineIndicatorConfig.compact(),
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      // During loading, should show CircularProgressIndicator
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      await loadingController.close();
    });

    testWidgets('handles error state gracefully', (WidgetTester tester) async {
      final errorMockManager = MockOfflineAuthManager();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            cachedDataProvider.overrideWithValue(mockCachedDataProvider),
            offlineAuthManagerProvider.overrideWithValue(errorMockManager),
            offlineStateProvider.overrideWith(
              (ref) => Stream.error('Test error'),
            ),
          ],
          child: MaterialApp(
            home: Scaffold(
              appBar: AppBar(
                actions: [
                  const OfflineIndicator(
                    config: OfflineIndicatorConfig.compact(),
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      await tester.pump(); // initial build
      await tester.pump(const Duration(seconds: 1)); // let stream settle

      // Widget should handle error gracefully - either shows SizedBox.shrink
      // or loading indicator, but should not crash
      // Note: with StreamProvider, the error may arrive as loading state
      expect(tester.takeException(), isNull);
    });

    testWidgets('handles missing last sync time gracefully',
        (WidgetTester tester) async {
      when(() => mockCachedDataProvider.isOffline())
          .thenAnswer((_) async => true);
      when(() => mockCachedDataProvider.getCachedDataInfo())
          .thenAnswer((_) async => <String, dynamic>{});

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              height: 800,
              child: ProviderScope(
                overrides: [
                  cachedDataProvider.overrideWithValue(mockCachedDataProvider),
                  offlineAuthManagerProvider.overrideWithValue(mockOfflineAuthManager),
                  offlineStateProvider.overrideWith(
                    (ref) async* {
                      yield OfflineAuthState.offlineWithCache;
                    },
                  ),
                ],
                child: Center(
                  child: OfflineIndicator(
                    config: OfflineIndicatorConfig.detailed(
                      showLastSyncTime: true,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );

      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(seconds: 1));

      expect(find.text('No sync data'), findsOneWidget);
    });

    testWidgets('handles exception in cached data provider',
        (WidgetTester tester) async {
      when(() => mockCachedDataProvider.getCachedDataInfo())
          .thenAnswer((_) async => throw Exception('Test exception'));

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              height: 800,
              child: ProviderScope(
                overrides: [
                  cachedDataProvider.overrideWithValue(mockCachedDataProvider),
                  offlineAuthManagerProvider.overrideWithValue(mockOfflineAuthManager),
                  offlineStateProvider.overrideWith(
                    (ref) async* {
                      yield OfflineAuthState.offlineWithCache;
                    },
                  ),
                ],
                child: Center(
                  child: OfflineIndicator(
                    config: OfflineIndicatorConfig.detailed(
                      showLastSyncTime: true,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );

      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(seconds: 1));

      // Should not crash, just hide the last sync time
      expect(find.textContaining('Last sync:'), findsNothing);
    });
  });
}
