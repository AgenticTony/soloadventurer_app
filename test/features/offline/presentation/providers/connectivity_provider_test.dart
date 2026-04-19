import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soloadventurer/core/services/connectivity_service.dart';
import 'package:soloadventurer/features/offline/presentation/providers/connectivity_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
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

  group('ConnectivityProvider', () {
    test('isConnectedProvider should return connection status', () {
      final container = ProviderContainer.test();

      expect(() => container.read(isConnectedProvider), returnsNormally);

      container.dispose();
    });

    test('connectionTypeProvider should return connection type', () {
      final container = ProviderContainer.test();

      expect(() => container.read(connectionTypeProvider), returnsNormally);

      container.dispose();
    });

    test('isOfflineProvider should return offline status', () {
      final container = ProviderContainer.test();

      expect(() => container.read(isOfflineProvider), returnsNormally);

      container.dispose();
    });
  });
}
