import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:soloadventurer/features/offline/domain/services/connectivity_service.dart';
import 'package:soloadventurer/features/offline/presentation/providers/connectivity_provider.dart';

@GenerateMocks([ConnectivityService])
import 'connectivity_provider_test.mocks.dart';

void main() {
  group('ConnectivityState', () {
    test('should create disconnected state', () {
      final state = ConnectivityState.disconnected();

      expect(state.isConnected, false);
      expect(state.connectionType, ConnectionType.none);
      expect(state.timestamp, isNotNull);
    });

    test('should create connected state with WiFi', () {
      final state = ConnectivityState.connected(ConnectionType.wifi);

      expect(state.isConnected, true);
      expect(state.connectionType, ConnectionType.wifi);
    });

    test('should create state from ConnectivityStatus', () {
      final status = ConnectivityStatus.connected(ConnectionType.cellular);
      final state = ConnectivityState.fromStatus(status);

      expect(state.isConnected, true);
      expect(state.connectionType, ConnectionType.cellular);
      expect(state.timestamp, status.timestamp);
    });

    test('should copy with new values', () {
      final state = ConnectivityState.disconnected();
      final copied = state.copyWith(isConnected: true);

      expect(copied.isConnected, true);
      expect(copied.connectionType, ConnectionType.none);
    });

    test('should implement equality correctly', () {
      final state1 = ConnectivityState.disconnected();
      final state2 = ConnectivityState.disconnected();
      final state3 = ConnectivityState.connected(ConnectionType.wifi);

      expect(state1, equals(state2));
      expect(state1, isNot(equals(state3)));
    });
  });

  group('ConnectivityNotifier', () {
    late MockConnectivityService mockService;

    setUp(() {
      mockService = MockConnectivityService();
    });

    test('should initialize with disconnected state', () {
      final notifier = ConnectivityNotifier(mockService);

      expect(notifier.state.isConnected, false);
      expect(notifier.state.connectionType, ConnectionType.none);

      notifier.dispose();
    });

    test('should update state when connectivity changes', () async {
      final controller = StreamController<ConnectivityStatus>();

      when(mockService.connectivityStream)
          .thenAnswer((_) => controller.stream);

      final notifier = ConnectivityNotifier(mockService);

      final newStatus = ConnectivityStatus.connected(ConnectionType.wifi);
      controller.add(newStatus);

      await Future.delayed(const Duration(milliseconds: 10));

      expect(notifier.state.isConnected, true);
      expect(notifier.state.connectionType, ConnectionType.wifi);

      await controller.close();
      notifier.dispose();
    });

    test('should check connectivity on demand', () async {
      when(mockService.checkConnectivity())
          .thenAnswer((_) async => ConnectivityStatus.connected(ConnectionType.cellular));

      final notifier = ConnectivityNotifier(mockService);
      await notifier.checkConnectivity();

      expect(notifier.state.isConnected, true);
      expect(notifier.state.connectionType, ConnectionType.cellular);

      verify(mockService.checkConnectivity()).called(1);
      notifier.dispose();
    });
  });

  group('ConnectivityProvider', () {
    test('isConnectedProvider should return connection status', () {
      final container = ProviderContainer();

      // The provider will use the real ConnectivityService via GetIt
      // For now, we just verify it doesn't throw
      expect(() => container.read(isConnectedProvider), returnsNormally);

      container.dispose();
    });

    test('connectionTypeProvider should return connection type', () {
      final container = ProviderContainer();

      expect(() => container.read(connectionTypeProvider), returnsNormally);

      container.dispose();
    });

    test('isOfflineProvider should return offline status', () {
      final container = ProviderContainer();

      expect(() => container.read(isOfflineProvider), returnsNormally);

      container.dispose();
    });
  });
}
