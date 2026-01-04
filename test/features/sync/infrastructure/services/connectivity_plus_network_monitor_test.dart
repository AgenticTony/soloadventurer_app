import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:soloadventurer/features/sync/domain/services/network_connectivity.dart';
import 'package:soloadventurer/features/sync/infrastructure/services/connectivity_plus_network_monitor.dart';

@GenerateMocks([Connectivity])
import 'connectivity_plus_network_monitor_test.mocks.dart';

void main() {
  late MockConnectivity mockConnectivity;
  late ConnectivityPlusNetworkMonitor networkMonitor;

  setUp(() {
    mockConnectivity = MockConnectivity();
    networkMonitor = ConnectivityPlusNetworkMonitor(
      connectivity: mockConnectivity,
    );
  });

  tearDown(() async {
    await networkMonitor.dispose();
  });

  group('ConnectivityPlusNetworkMonitor - Initialization', () {
    test('should initialize with offline status by default', () async {
      // Arrange
      when(mockConnectivity.checkConnectivity())
          .thenAnswer((_) async => [ConnectivityResult.none]);

      // Act
      await networkMonitor.initialize();

      // Assert
      expect(networkMonitor.isOnline, false);
      expect(networkMonitor.connectionType, NetworkConnectionType.none);
      verify(mockConnectivity.checkConnectivity()).called(1);
    });

    test('should initialize with online status when WiFi is connected', () async {
      // Arrange
      when(mockConnectivity.checkConnectivity())
          .thenAnswer((_) async => [ConnectivityResult.wifi]);

      // Act
      await networkMonitor.initialize();

      // Assert
      expect(networkMonitor.isOnline, true);
      expect(networkMonitor.connectionType, NetworkConnectionType.wifi);
    });

    test('should initialize with mobile connection type', () async {
      // Arrange
      when(mockConnectivity.checkConnectivity())
          .thenAnswer((_) async => [ConnectivityResult.mobile]);

      // Act
      await networkMonitor.initialize();

      // Assert
      expect(networkMonitor.isOnline, true);
      expect(networkMonitor.connectionType, NetworkConnectionType.mobile);
    });

    test('should handle multiple connectivity results', () async {
      // Arrange
      when(mockConnectivity.checkConnectivity()).thenAnswer(
          (_) async => [ConnectivityResult.wifi, ConnectivityResult.vpn]);

      // Act
      await networkMonitor.initialize();

      // Assert
      expect(networkMonitor.isOnline, true);
      // WiFi should be prioritized over VPN
      expect(networkMonitor.connectionType, NetworkConnectionType.wifi);
    });

    test('should set offline status on initialization error', () async {
      // Arrange
      when(mockConnectivity.checkConnectivity())
          .thenThrow(Exception('Network error'));

      // Act
      await networkMonitor.initialize();

      // Assert
      expect(networkMonitor.isOnline, false);
      expect(networkMonitor.connectionType, NetworkConnectionType.none);
    });

    test('should not initialize twice', () async {
      // Arrange
      when(mockConnectivity.checkConnectivity())
          .thenAnswer((_) async => [ConnectivityResult.wifi]);

      // Act
      await networkMonitor.initialize();
      await networkMonitor.initialize();

      // Assert
      verify(mockConnectivity.checkConnectivity()).called(1);
    });
  });

  group('ConnectivityPlusNetworkMonitor - Monitoring', () {
    test('should start monitoring successfully', () async {
      // Arrange
      when(mockConnectivity.checkConnectivity())
          .thenAnswer((_) async => [ConnectivityResult.wifi]);
      final connectivityStream = Stream<List<ConnectivityResult>>.value([
        [ConnectivityResult.wifi]
      ]);
      when(mockConnectivity.onConnectivityChanged)
          .thenAnswer((_) => connectivityStream);

      // Act
      await networkMonitor.initialize();
      await networkMonitor.startMonitoring();

      // Assert
      verify(mockConnectivity.onConnectivityChanged).called(1);
    });

    test('should not start monitoring twice', () async {
      // Arrange
      when(mockConnectivity.checkConnectivity())
          .thenAnswer((_) async => [ConnectivityResult.wifi]);
      final connectivityStream = Stream<List<ConnectivityResult>>.value([
        [ConnectivityResult.wifi]
      ]);
      when(mockConnectivity.onConnectivityChanged)
          .thenAnswer((_) => connectivityStream);

      // Act
      await networkMonitor.initialize();
      await networkMonitor.startMonitoring();
      await networkMonitor.startMonitoring();

      // Assert
      verify(mockConnectivity.onConnectivityChanged).called(1);
    });

    test('should stop monitoring and cancel subscription', () async {
      // Arrange
      when(mockConnectivity.checkConnectivity())
          .thenAnswer((_) async => [ConnectivityResult.wifi]);
      final connectivityStream = Stream<List<ConnectivityResult>>.value([
        [ConnectivityResult.wifi]
      ]);
      when(mockConnectivity.onConnectivityChanged)
          .thenAnswer((_) => connectivityStream);

      await networkMonitor.initialize();
      await networkMonitor.startMonitoring();

      // Act
      await networkMonitor.stopMonitoring();

      // Assert - Should complete without throwing
      expect(() => networkMonitor.stopMonitoring(), returnsNormally);
    });
  });

  group('ConnectivityPlusNetworkMonitor - Status Updates', () {
    test('should emit status changes on statusStream', () async {
      // Arrange
      when(mockConnectivity.checkConnectivity())
          .thenAnswer((_) async => [ConnectivityResult.none]);

      final connectivityController = StreamController<List<ConnectivityResult>>();
      when(mockConnectivity.onConnectivityChanged)
          .thenAnswer((_) => connectivityController.stream);

      await networkMonitor.initialize();
      await networkMonitor.startMonitoring();

      final statuses = <NetworkStatus>[];
      final subscription = networkMonitor.statusStream.listen(statuses.add);

      // Act
      connectivityController.add([ConnectivityResult.wifi]);

      // Wait for stream to emit
      await Future.delayed(const Duration(milliseconds: 100));

      // Assert
      expect(statuses.length, greaterThan(0));
      expect(statuses.last.isOnline, true);
      expect(statuses.last.connectionType, NetworkConnectionType.wifi);

      await subscription.cancel();
      await connectivityController.close();
    });

    test('should emit onOnline event when transitioning from offline to online',
        () async {
      // Arrange
      when(mockConnectivity.checkConnectivity())
          .thenAnswer((_) async => [ConnectivityResult.none]);

      final connectivityController = StreamController<List<ConnectivityResult>>();
      when(mockConnectivity.onConnectivityChanged)
          .thenAnswer((_) => connectivityController.stream);

      await networkMonitor.initialize();
      await networkMonitor.startMonitoring();

      final onlineEvents = <bool>[];
      final subscription = networkMonitor.onOnline.listen((_) {
        onlineEvents.add(true);
      });

      // Act
      connectivityController.add([ConnectivityResult.wifi]);

      // Wait for stream to emit
      await Future.delayed(const Duration(milliseconds: 100));

      // Assert
      expect(onlineEvents, [true]);

      await subscription.cancel();
      await connectivityController.close();
    });

    test('should emit onOffline event when transitioning from online to offline',
        () async {
      // Arrange
      when(mockConnectivity.checkConnectivity())
          .thenAnswer((_) async => [ConnectivityResult.wifi]);

      final connectivityController = StreamController<List<ConnectivityResult>>();
      when(mockConnectivity.onConnectivityChanged)
          .thenAnswer((_) => connectivityController.stream);

      await networkMonitor.initialize();
      await networkMonitor.startMonitoring();

      final offlineEvents = <bool>[];
      final subscription = networkMonitor.onOffline.listen((_) {
        offlineEvents.add(true);
      });

      // Act
      connectivityController.add([ConnectivityResult.none]);

      // Wait for stream to emit
      await Future.delayed(const Duration(milliseconds: 100));

      // Assert
      expect(offlineEvents, [true]);

      await subscription.cancel();
      await connectivityController.close();
    });

    test('should handle multiple connection type changes', () async {
      // Arrange
      when(mockConnectivity.checkConnectivity())
          .thenAnswer((_) async => [ConnectivityResult.none]);

      final connectivityController = StreamController<List<ConnectivityResult>>();
      when(mockConnectivity.onConnectivityChanged)
          .thenAnswer((_) => connectivityController.stream);

      await networkMonitor.initialize();
      await networkMonitor.startMonitoring();

      final statuses = <NetworkStatus>[];
      final subscription = networkMonitor.statusStream.listen(statuses.add);

      // Act - Simulate connection changes
      connectivityController.add([ConnectivityResult.wifi]);
      await Future.delayed(const Duration(milliseconds: 50));

      connectivityController.add([ConnectivityResult.mobile]);
      await Future.delayed(const Duration(milliseconds: 50));

      connectivityController.add([ConnectivityResult.none]);
      await Future.delayed(const Duration(milliseconds: 50));

      // Assert
      expect(statuses.length, greaterThan(2));

      // Find the WiFi status
      final wifiStatus =
          statuses.firstWhere((s) => s.connectionType == NetworkConnectionType.wifi,
              orElse: () => NetworkStatus.offline());
      expect(wifiStatus.isOnline, true);

      // Find the mobile status
      final mobileStatus = statuses.firstWhere(
          (s) => s.connectionType == NetworkConnectionType.mobile,
          orElse: () => NetworkStatus.offline());
      expect(mobileStatus.isOnline, true);

      // Find the offline status
      final offlineStatus =
          statuses.lastWhere((s) => !s.isOnline, orElse: () => NetworkStatus.online(NetworkConnectionType.wifi));
      expect(offlineStatus.isOnline, false);

      await subscription.cancel();
      await connectivityController.close();
    });
  });

  group('ConnectivityPlusNetworkMonitor - Connection Type Mapping', () {
    test('should map WiFi connection type correctly', () async {
      // Arrange
      when(mockConnectivity.checkConnectivity())
          .thenAnswer((_) async => [ConnectivityResult.wifi]);

      // Act
      await networkMonitor.initialize();

      // Assert
      expect(networkMonitor.connectionType, NetworkConnectionType.wifi);
    });

    test('should map mobile connection type correctly', () async {
      // Arrange
      when(mockConnectivity.checkConnectivity())
          .thenAnswer((_) async => [ConnectivityResult.mobile]);

      // Act
      await networkMonitor.initialize();

      // Assert
      expect(networkMonitor.connectionType, NetworkConnectionType.mobile);
    });

    test('should map ethernet connection type correctly', () async {
      // Arrange
      when(mockConnectivity.checkConnectivity())
          .thenAnswer((_) async => [ConnectivityResult.ethernet]);

      // Act
      await networkMonitor.initialize();

      // Assert
      expect(networkMonitor.connectionType, NetworkConnectionType.ethernet);
    });

    test('should map bluetooth connection type correctly', () async {
      // Arrange
      when(mockConnectivity.checkConnectivity())
          .thenAnswer((_) async => [ConnectivityResult.bluetooth]);

      // Act
      await networkMonitor.initialize();

      // Assert
      expect(networkMonitor.connectionType, NetworkConnectionType.bluetooth);
    });

    test('should map VPN connection type correctly', () async {
      // Arrange
      when(mockConnectivity.checkConnectivity())
          .thenAnswer((_) async => [ConnectivityResult.vpn]);

      // Act
      await networkMonitor.initialize();

      // Assert
      expect(networkMonitor.connectionType, NetworkConnectionType.vpn);
    });

    test('should prioritize WiFi over mobile in multiple connections', () async {
      // Arrange
      when(mockConnectivity.checkConnectivity()).thenAnswer(
          (_) async => [ConnectivityResult.mobile, ConnectivityResult.wifi]);

      // Act
      await networkMonitor.initialize();

      // Assert
      expect(networkMonitor.connectionType, NetworkConnectionType.wifi);
    });

    test('should handle unknown connection types', () async {
      // Arrange
      when(mockConnectivity.checkConnectivity())
          .thenAnswer((_) async => [ConnectivityResult.none]);

      // Act
      await networkMonitor.initialize();

      // Assert
      expect(networkMonitor.connectionType, NetworkConnectionType.none);
    });
  });

  group('ConnectivityPlusNetworkMonitor - Resource Cleanup', () {
    test('should dispose resources correctly', () async {
      // Arrange
      when(mockConnectivity.checkConnectivity())
          .thenAnswer((_) async => [ConnectivityResult.wifi]);
      final connectivityStream = Stream<List<ConnectivityResult>>.value([
        [ConnectivityResult.wifi]
      ]);
      when(mockConnectivity.onConnectivityChanged)
          .thenAnswer((_) => connectivityStream);

      await networkMonitor.initialize();
      await networkMonitor.startMonitoring();

      // Act
      await networkMonitor.dispose();

      // Assert - Should complete without throwing
      expect(() => networkMonitor.dispose(), returnsNormally);
    });

    test('should handle stop monitoring when not monitoring', () async {
      // Act & Assert - Should not throw
      expect(() => networkMonitor.stopMonitoring(), returnsNormally);
    });
  });
}
