// Feature State Template - Riverpod 2 Compliant
// Copy this template when creating new features

import 'package:freezed_annotation/freezed_annotation.dart';

part 'feature_state.freezed.dart';

/// Immutable state for [FeatureName].
///
/// RULES:
/// - All fields must be final
/// - Use freezed for immutability
/// - isLoading and error are ALWAYS fields on state
/// - Never nullable
@freezed
class FeatureState with _$FeatureState {
  const factory FeatureState({
    /// Loading indicator - always a field on State
    @Default(false) bool isLoading,

    /// Error message - always a field on State
    String? error,

    /// Feature data
    FeatureData? data,

    /// Any other computed/derived values
    @Default(false) bool isValid,
    @Default(false) bool hasPermission,
  }) = _FeatureState;

  factory FeatureState.initial() => const FeatureState();
}

/// Example data model
@freezed
class FeatureData with _$FeatureData {
  const factory FeatureData({
    required String id,
    required String name,
  }) = _FeatureData;
}
