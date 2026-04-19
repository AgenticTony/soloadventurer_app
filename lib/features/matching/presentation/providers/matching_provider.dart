import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:soloadventurer/features/matching/domain/repositories/matching_repository.dart';

part 'matching_provider.g.dart';

/// Provider for the matching repository
///
/// This will be overridden in the app's provider scope
/// with the actual implementation.
@Riverpod(keepAlive: true)
MatchingRepository matchingRepository(Ref ref) {
  throw UnimplementedError(
    'MatchingRepository must be provided via override in app bootstrap',
  );
}
