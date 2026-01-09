// Feature Notifier Template - Riverpod 2 Compliant
// Copy this template when creating new features

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'feature_state.dart';

part 'feature_notifier.g.dart';

/// Notifier for [FeatureName].
///
/// RULES:
/// - Use AutoDisposeNotifier for sync state
/// - Use AutoDisposeAsyncNotifier for async state
/// - NO getters - derived values must be in State
/// - UI reads STATE only
/// - build() returns initial state
@riverpod
class FeatureNotifier extends _$FeatureNotifier {
  @override
  FeatureState build() => FeatureState.initial();

  /// Perform an action
  ///
  /// UI calls this via: ref.read(featureProvider.notifier).doSomething()
  Future<void> performAction() async {
    // Update loading state
    state = state.copyWith(isLoading: true);

    try {
      // Perform logic
      final result = await _repository.doSomething();

      // Update state with result
      state = state.copyWith(
        isLoading: false,
        data: result,
        error: null,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Reset state to initial
  void reset() {
    state = FeatureState.initial();
  }
}

// ASYNC VARIANT - Use for features with async data loading
@riverpod
class AsyncFeatureNotifier extends _$AsyncFeatureNotifier {
  @override
  Future<FeatureData> build() async {
    // Initial data fetch
    return await _fetchData();
  }

  Future<FeatureData> _fetchData() async {
    // Fetch logic here
    return const FeatureData(id: '1', name: 'Test');
  }

  /// Refresh the data
  Future<void> refresh() async {
    // Set loading state
    state = const AsyncValue.loading();

    // Fetch new data
    state = await AsyncValue.guard(() => _fetchData());
  }
}
