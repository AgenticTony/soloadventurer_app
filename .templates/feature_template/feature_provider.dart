// Feature Provider Template - Riverpod 2 Compliant
// Copy this template when creating new features

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'feature_notifier.dart';
import 'feature_state.dart';

/// ONE CANONICAL PROVIDER PER FEATURE
///
/// RULES:
/// - One provider file per feature
/// - No re-exports
/// - No duplicate providers
/// - Use @riverpod annotation with code generation

part 'feature_provider.g.dart';

/// Main feature state provider
///
/// Usage in UI:
/// ```dart
/// // READ state (always use ref.watch)
/// final state = ref.watch(featureProvider);
///
/// // CALL methods (use ref.read for events)
/// ref.read(featureProvider.notifier).performAction();
/// ```
@riverpod
class Feature extends _$Feature {
  @override
  FeatureState build() => FeatureState.initial();

  void performAction() {
    // Implementation here
  }
}
