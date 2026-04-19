import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'connectivity_service.dart';

/// Implementation of [ConnectivityService]
///
/// This service provides a stream-based API for monitoring network connectivity
/// changes. It handles debouncing to prevent rapid status changes and provides
/// initial connectivity check on startup.
///
/// The implementation uses the connectivity_plus plugin to detect network
/// changes and wraps it in a more convenient API with debouncing and
/// detailed status information.
class ConnectivityServiceImpl implements ConnectivityService {
  /// Connectivity plugin instance
  final Connectivity _connectivity;

  /// Stream controller for detailed connectivity status updates
  StreamController<ConnectivityStatus>? _statusStreamController;

  /// Stream controller for simplified network status updates
  StreamController<NetworkStatus>? _networkStatusStreamController;

  /// Subscription to connectivity plugin's onConnectivityChanged stream
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;

  /// Timer for debouncing connectivity changes
  Timer? _debounceTimer;

  /// Debounce delay to prevent rapid status changes (milliseconds)
  final int debounceMs;

  /// Last emitted connectivity status
  ConnectivityStatus? _lastStatus;

  /// Last known network status (simplified)
  NetworkStatus _lastKnownNetworkStatus = NetworkStatus.disconnected;

  /// Creates a new [ConnectivityServiceImpl] instance
  ///
  /// [connectivity] - Connectivity plugin instance (defaults to Connectivity())
  /// [debounceMs] - Debounce delay in milliseconds (default: 300ms)
  ConnectivityServiceImpl({
    Connectivity? connectivity,
    this.debounceMs = 300,
  }) : _connectivity = connectivity ?? Connectivity() {
    // Initialize with current status
    _initializeStatus();
  }

  /// Initialize the service with current connectivity status
  void _initializeStatus() {
    checkConnectivity().then((status) {
      _lastStatus = status;
      _lastKnownNetworkStatus = status.toNetworkStatus();

      // Emit initial status if streams are active
      if (_statusStreamController != null &&
          !_statusStreamController!.isClosed) {
        _statusStreamController!.add(status);
      }
      if (_networkStatusStreamController != null &&
          !_networkStatusStreamController!.isClosed) {
        _networkStatusStreamController!.add(status.toNetworkStatus());
      }

    });
  }

  @override
  Stream<ConnectivityStatus> get connectivityStream {
    _statusStreamController ??= StreamController<ConnectivityStatus>.broadcast(
      onListen: _startMonitoring,
      onCancel: _stopMonitoring,
    );

    // If we already have a status, emit it immediately
    if (_lastStatus != null && !_statusStreamController!.isClosed) {
      // Use a delayed microtask to avoid emitting during synchronous construction
      Future.microtask(() {
        if (_statusStreamController != null &&
            !_statusStreamController!.isClosed) {
          _statusStreamController!.add(_lastStatus!);
        }
      });
    }

    return _statusStreamController!.stream;
  }

  @override
  Stream<NetworkStatus> get onConnectivityChanged {
    _networkStatusStreamController ??=
        StreamController<NetworkStatus>.broadcast(
      onListen: _startMonitoring,
      onCancel: _stopMonitoring,
    );

    // If we already have a status, emit it immediately
    if (_lastStatus != null && !_networkStatusStreamController!.isClosed) {
      // Use a delayed microtask to avoid emitting during synchronous construction
      Future.microtask(() {
        if (_networkStatusStreamController != null &&
            !_networkStatusStreamController!.isClosed) {
          _networkStatusStreamController!.add(_lastStatus!.toNetworkStatus());
        }
      });
    }

    return _networkStatusStreamController!.stream;
  }

  @override
  Future<ConnectivityStatus> checkConnectivity() async {
    try {
      final results = await _connectivity.checkConnectivity();
      final status = ConnectivityStatus.fromConnectivityResult(results);

      _lastStatus = status;
      _lastKnownNetworkStatus = status.toNetworkStatus();

      return status;
    } catch (e) {

      // Return disconnected status on error
      final status = ConnectivityStatus.disconnected();
      _lastStatus = status;
      _lastKnownNetworkStatus = NetworkStatus.disconnected;
      return status;
    }
  }

  @override
  Future<NetworkStatus> checkNetworkStatus() async {
    final status = await checkConnectivity();
    return status.toNetworkStatus();
  }

  @override
  Future<bool> get hasConnectivity async {
    final status = await checkConnectivity();
    return status.isConnected;
  }

  @override
  bool get hasConnectivitySync =>
      _lastKnownNetworkStatus == NetworkStatus.connected;

  /// Start monitoring connectivity changes
  void _startMonitoring() {
    if (_connectivitySubscription != null) {
      // Already monitoring
      return;
    }

    // Listen to connectivity changes
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen(
      (results) {
        _handleConnectivityChange(results);
      },
      onError: (error) {
        _emitDisconnectedStatus();
      },
    );
  }

  /// Stop monitoring connectivity changes
  void _stopMonitoring() {
    // Only stop if no streams are actively listening
    final hasActiveListeners = (_statusStreamController != null &&
            _statusStreamController!.hasListener) ||
        (_networkStatusStreamController != null &&
            _networkStatusStreamController!.hasListener);

    if (hasActiveListeners) {
      return; // Still have listeners, don't stop
    }

    _debounceTimer?.cancel();
    _debounceTimer = null;

    _connectivitySubscription?.cancel();
    _connectivitySubscription = null;
  }

  /// Handle connectivity change with debouncing
  void _handleConnectivityChange(List<ConnectivityResult> results) {
    // Cancel any pending debounce timer
    _debounceTimer?.cancel();

    final newStatus = ConnectivityStatus.fromConnectivityResult(results);

    // If status hasn't changed, skip emitting
    if (_lastStatus != null && _lastStatus == newStatus) {
      return;
    }

    // Set debounce timer
    _debounceTimer = Timer(Duration(milliseconds: debounceMs), () {
      _lastStatus = newStatus;
      _lastKnownNetworkStatus = newStatus.toNetworkStatus();

      // Emit to both streams
      if (_statusStreamController != null &&
          !_statusStreamController!.isClosed) {
        _statusStreamController!.add(newStatus);
      }
      if (_networkStatusStreamController != null &&
          !_networkStatusStreamController!.isClosed) {
        _networkStatusStreamController!.add(newStatus.toNetworkStatus());
      }

    });
  }

  /// Emit a disconnected status (used on errors)
  void _emitDisconnectedStatus() {
    final status = ConnectivityStatus.disconnected();

    _lastStatus = status;
    _lastKnownNetworkStatus = NetworkStatus.disconnected;

    if (_statusStreamController != null && !_statusStreamController!.isClosed) {
      _statusStreamController!.add(status);
    }
    if (_networkStatusStreamController != null &&
        !_networkStatusStreamController!.isClosed) {
      _networkStatusStreamController!.add(NetworkStatus.disconnected);
    }
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _debounceTimer = null;

    _connectivitySubscription?.cancel();
    _connectivitySubscription = null;

    _statusStreamController?.close();
    _statusStreamController = null;

    _networkStatusStreamController?.close();
    _networkStatusStreamController = null;

    _lastStatus = null;
  }
}
