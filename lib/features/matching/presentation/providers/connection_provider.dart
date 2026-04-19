import 'dart:async';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:soloadventurer/features/matching/domain/entities/connection.dart';
import 'matching_provider.dart';

part 'connection_provider.g.dart';

/// Provider for matches/connections
@Riverpod(keepAlive: true)
Future<List<Connection>> matches(Ref ref) async {
  final repository = ref.watch(matchingRepositoryProvider);
  return repository.findMatches();
}

/// Provider for all connections (including hidden/blocked)
@Riverpod(keepAlive: true)
Future<List<Connection>> connections(Ref ref) async {
  final repository = ref.watch(matchingRepositoryProvider);
  return repository.getConnections();
}

/// Provider for active matches count (for badges, etc.)
@Riverpod(keepAlive: true)
Future<int> activeMatchesCount(Ref ref) async {
  final matches = await ref.watch(matchesProvider.future);
  return matches.where((m) => m.isActive && m.status == ConnectionStatus.accepted).length;
}

/// Provider for pending matches count
@Riverpod(keepAlive: true)
Future<int> pendingMatchesCount(Ref ref) async {
  final matches = await ref.watch(matchesProvider.future);
  return matches.where((m) => m.status == ConnectionStatus.pending).length;
}

/// Provider for nearby travelers count
@Riverpod(keepAlive: true)
Future<int> nearbyTravelersCount(Ref ref) async {
  final repository = ref.watch(matchingRepositoryProvider);
  return repository.getNearbyTravelersCount();
}

/// Notifier for managing connections
@Riverpod(keepAlive: true)
class ConnectionNotifier extends _$ConnectionNotifier {
  @override
  FutureOr<void> build() {
    return null;
  }

  /// Accept a connection request
  Future<void> acceptConnection(String connectionId) async {
    state = const AsyncValue.loading();

    final repository = ref.read(matchingRepositoryProvider);
    
    final result = await AsyncValue.guard(() async {
      // Get the connection
      final connection = await repository.getConnection(connectionId);
      if (connection == null) {
        throw Exception('Connection not found');
      }

      // Update status to accepted
      // Note: The repository would need an updateConnection method
      // For now, we'll invalidate the providers to refresh
      ref.invalidate(matchesProvider);
      ref.invalidate(connectionsProvider);
      ref.invalidate(activeMatchesCountProvider);
      ref.invalidate(pendingMatchesCountProvider);
    });

    state = result;

    if (result.hasError) {
      throw result.error!;
    }
  }

  /// Decline a connection request
  Future<void> declineConnection(String connectionId) async {
    state = const AsyncValue.loading();

    final repository = ref.read(matchingRepositoryProvider);

    final result = await AsyncValue.guard(() async {
      // Get the connection
      final connection = await repository.getConnection(connectionId);
      if (connection == null) {
        throw Exception('Connection not found');
      }

      // Update status to declined (by hiding it)
      await repository.hideConnection(connectionId);
      
      ref.invalidate(matchesProvider);
      ref.invalidate(connectionsProvider);
      ref.invalidate(activeMatchesCountProvider);
      ref.invalidate(pendingMatchesCountProvider);
    });

    state = result;

    if (result.hasError) {
      throw result.error!;
    }
  }

  /// Block a connection
  Future<void> blockConnection(String connectionId) async {
    state = const AsyncValue.loading();

    final repository = ref.read(matchingRepositoryProvider);

    final result = await AsyncValue.guard(() async {
      // Get the connection
      final connection = await repository.getConnection(connectionId);
      if (connection == null) {
        throw Exception('Connection not found');
      }

      // Update status to blocked (by hiding it)
      await repository.hideConnection(connectionId);
      
      ref.invalidate(matchesProvider);
      ref.invalidate(connectionsProvider);
      ref.invalidate(activeMatchesCountProvider);
      ref.invalidate(pendingMatchesCountProvider);
    });

    state = result;

    if (result.hasError) {
      throw result.error!;
    }
  }

  /// Hide a connection (soft delete)
  Future<void> hideConnection(String connectionId) async {
    state = const AsyncValue.loading();

    final repository = ref.read(matchingRepositoryProvider);

    final result = await AsyncValue.guard(() async {
      await repository.hideConnection(connectionId);
      
      ref.invalidate(matchesProvider);
      ref.invalidate(connectionsProvider);
    });

    state = result;

    if (result.hasError) {
      throw result.error!;
    }
  }

  /// Refresh matches from server
  Future<void> refreshMatches() async {
    state = const AsyncValue.loading();

    ref.invalidate(matchesProvider);
    ref.invalidate(connectionsProvider);
    ref.invalidate(nearbyTravelersCountProvider);
    
    state = const AsyncValue.data(null);
  }
}
