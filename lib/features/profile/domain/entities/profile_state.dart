import 'package:freezed_annotation/freezed_annotation.dart';
import '../models/profile_model.dart';

part 'profile_state.freezed.dart';

@freezed
class ProfileState with _$ProfileState {
  const factory ProfileState({
    @Default(false) bool isLoading,
    String? error,
    ProfileModel? profile,
  }) = _ProfileState;
}
