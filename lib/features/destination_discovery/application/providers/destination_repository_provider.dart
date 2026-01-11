import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/repositories/destination_repository.dart';

part 'destination_repository_provider.g.dart';

/// Provider for the destination repository
///
/// This provider must be overridden in the main application to provide
/// the actual implementation of [DestinationRepository].
///
/// Riverpod 3.0: Uses @riverpod annotation with code generation.
/// The provider is defined here for shared use across all destination discovery providers.
@riverpod
DestinationRepository destinationRepository(Ref ref) {
  throw UnimplementedError(
    'destinationRepositoryProvider must be overridden with actual implementation',
  );
}
