import 'dart:async';
import 'dart:developer' as developer;
import 'package:connectivity_plus/connectivity_plus.dart';
import '../../domain/services/network_connectivity.dart';

/// Implementation of [NetworkConnectivity] using connectivity_plus package
///
/// Monitors network state changes using the connectivity_plus plugin
/// and provides reactive streams for network status updates.
class ConnectivityPlusNetworkMonitor implements NetworkConnectivity {
  final Connectivity _connectivity;

  /// Stream controller for network status changes
  StreamController<NetworkStatus>? _statusController;

  /// Stream controller for online events
  StreamController<bool>? _onlineController;

  /// Stream controller for offline events
  StreamController<bool>? _offlineController;

  /// Subscription to connectivity changes
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;

  /// Current network status
  NetworkStatus _currentStatus = NetworkStatus.offline();

  /// Previous network status (for detecting transitions)
  NetworkStatus? _previousStatus;

  /// Whether monitoring is currently active
  bool _isMonitoring = false;

  /// Whether service has been initialized
  bool _isInitialized = false;

  /// Creates a new [ConnectivityPlusNetworkMonitor] instance
  ///
  /// If [connectivity] is not provided, creates a default instance.
  ConnectivityPlusNetworkMonitor({Connectivity? connectivity})
      : _connectivity = connectivity ?? Connectivity();

  @override
  NetworkStatus get currentStatus => _currentStatus;

  @override
  Stream<NetworkStatus> get statusStream {
    if (_statusController == null) {
      _statusController = StreamController<NetworkStatus>.broadcast();
    }
    return _statusController!.stream;
  }

  @override
  Stream<bool> get onOnline {
    if (_onlineController == null) {
      _onlineController = StreamController<bool>.broadcast();
    }
    return _onlineController!.stream;
  }

  @override
  Stream<bool> get onOffline {
    if (_offlineController == null) {
      _offlineController = StreamController<bool>.broadcast();
    }
    return _offlineController!.stream;
  }

  @override
  bool get isOnline => _currentStatus.isOnline;

  @override
  NetworkConnectionType get connectionType => _currentStatus.connectionType;

  @override
  Future<void> initialize() async {
    if (_isInitialized) {
      developer.log(
        'NetworkConnectivity: Already initialized',
        name: 'sync.network',
      );
      return;
    }

    try {
      // Get initial connectivity status
      final connectivityResults = await _connectivity.checkConnectivity();
      _updateStatus(connectivityResults);

      _isInitialized = true;

      developer.log(
        'NetworkConnectivity: Initialized with status: $_currentStatus',
        name: 'sync.network',
      );
    } catch (e, stackTrace) {
      developer.log(
        'NetworkConnectivity: Error during initialization',
        name: 'sync.network',
        error: e,
        stackTrace: stackTrace,
      );

      // Set offline status on error
      _currentStatus = NetworkStatus.offline();
      _isInitialized = true;
    }
  }

  @override
  Future<void> startMonitoring() async {
    if (_isMonitoring) {
      developer.log(
        'NetworkConnectivity: Already monitoring',
        name: 'sync.network',
      );
      return;
    }

    // Initialize if not already done
    if (!_isInitialized) {
      await initialize();
    }

    // Create stream controllers if not exists
    if (_statusController == null) {
      _statusController = StreamController<NetworkStatus>.broadcast();
    }
    if (_onlineController == null) {
      _onlineController = StreamController<bool>.broadcast();
    }
    if (_offlineController == null) {
      _offlineController = StreamController<bool>.broadcast();
    }

    try {
      // Listen to connectivity changes
      _connectivitySubscription = _connectivity.onConnectivityChanged.listen(
        (connectivityResults) {
          _updateStatus(connectivityResults);
        },
        onError: (error, stackTrace) {
          developer.log(
            'NetworkConnectivity: Error in connectivity stream',
            name: 'sync.network',
            error: error,
            stackTrace: stackTrace,
          );
        },
      );

      _isMonitoring = true;

      developer.log(
        'NetworkConnectivity: Started monitoring',
        name: 'sync.network',
      );
    } catch (e, stackTrace) {
      developer.log(
        'NetworkConnectivity: Error starting monitoring',
        name: 'sync.network',
        error: e,
        stackTrace: stackTrace,
      );

      rethrow;
    }
  }

  @override
  Future<void> stopMonitoring() async {
    if (!_isMonitoring) {
      return;
    }

    try {
      await _connectivitySubscription?.cancel();
      _connectivitySubscription = null;

      await _statusController?.close();
      _statusController = null;

      await _onlineController?.close();
      _onlineController = null;

      await _offlineController?.close();
      _offlineController = null;

      _isMonitoring = false;

      developer.log(
        'NetworkConnectivity: Stopped monitoring',
        name: 'sync.network',
      );
    } catch (e, stackTrace) {
      developer.log(
        'NetworkConnectivity: Error stopping monitoring',
        name: 'sync.network',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  @override
  void dispose() {
    stopMonitoring();
  }

  /// Update the current status based on connectivity results
  void _updateStatus(List<ConnectivityResult> connectivityResults) {
    _previousStatus = _currentStatus;

    // Determine if we're online and what type of connection
    if (connectivityResults.isEmpty ||
        connectivityResults.contains(ConnectivityResult.none)) {
      _currentStatus = NetworkStatus.offline();
    } else {
      // Get the primary connection type (prioritize wifi over mobile)
      final connectionType = _mapConnectivityResult(connectivityResults);
      _currentStatus = NetworkStatus.online(connectionType);
    }

    // Emit status change
    _statusController?.add(_currentStatus);

    // Detect transitions and emit appropriate events
    if (_previousStatus != null) {
      if (!_previousStatus!.isOnline && _currentStatus.isOnline) {
        // Transition from offline to online
        _onlineController?.add(true);
        developer.log(
          'NetworkConnectivity: Device came online (${_currentStatus.connectionType.name})',
          name: 'sync.network',
        );
      } else if (_previousStatus!.isOnline && !_currentStatus.isOnline) {
        // Transition from online to offline
        _offlineController?.add(true);
        developer.log(
          'NetworkConnectivity: Device went offline',
          name: 'sync.network',
        );
      }
    }

    // Log status changes
    if (_previousStatus != null && _previousStatus != _currentStatus) {
      developer.log(
        'NetworkConnectivity: Status changed from $_previousStatus to $_currentStatus',
        name: 'sync.network',
      );
    }
  }

  /// Map ConnectivityResult list to NetworkConnectionType
  ///
  /// Prioritizes WiFi over mobile connections
  NetworkConnectionType _mapConnectivityResult(
      List<ConnectivityResult> connectivityResults) {
    if (connectivityResults.contains(ConnectivityResult.wifi)) {
      return NetworkConnectionType.wifi;
    } else if (connectivityResults.contains(ConnectivityResult.ethernet)) {
      return NetworkConnectionType.ethernet;
    } else if (connectivityResults.contains(ConnectivityResult.mobile)) {
      return NetworkConnectionType.mobile;
    } else if (connectivityResults.contains(ConnectivityResult.bluetooth)) {
      return NetworkConnectionType.bluetooth;
    } else if (connectivityResults.contains(ConnectivityResult.vpn)) {
      return NetworkConnectionType.vpn;
    } else {
      return NetworkConnectionType.other;
    }
  }
}
