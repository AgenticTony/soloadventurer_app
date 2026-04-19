import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soloadventurer/features/social/domain/enums/verification_tier.dart';
import '../../data/datasources/verification_remote_data_source.dart';
import '../../data/repositories/verification_repository_impl.dart';
import '../../domain/entities/verification_request.dart';
import '../../domain/enums/verification_type.dart';
import '../../domain/repositories/verification_repository.dart';

/// Provider for verification remote data source
final _verificationRemoteDataSourceProvider =
    Provider<VerificationRemoteDataSource>((ref) {
  return VerificationRemoteDataSource();
});

/// Provider for verification repository
final verificationRepositoryProvider = Provider<VerificationRepository>((ref) {
  return VerificationRepositoryImpl(
    ref.read(_verificationRemoteDataSourceProvider),
  );
});

/// State for the verification flow
class VerificationFlowState {
  /// Current verification tier of the user
  final VerificationTier currentTier;

  /// Whether a verification is currently in progress
  final bool isInProgress;

  /// The current verification type being processed
  final VerificationType? activeType;

  /// The current verification request
  final VerificationRequest? activeRequest;

  /// Error message if something went wrong
  final String? error;

  /// Verification history
  final List<VerificationRequest> history;

  /// Creates a new [VerificationFlowState]
  const VerificationFlowState({
    this.currentTier = VerificationTier.unverified,
    this.isInProgress = false,
    this.activeType,
    this.activeRequest,
    this.error,
    this.history = const [],
  });

  /// Whether the user can start a new verification
  bool get canStartVerification => !isInProgress && currentTier != VerificationTier.idVerified;

  /// Whether the user can do photo verification
  bool get canDoPhotoVerification => currentTier == VerificationTier.unverified;

  /// Whether the user can do ID verification
  bool get canDoIdVerification =>
      currentTier == VerificationTier.emailVerified ||
      currentTier == VerificationTier.unverified;

  /// Creates a copy with updated fields
  VerificationFlowState copyWith({
    VerificationTier? currentTier,
    bool? isInProgress,
    VerificationType? activeType,
    VerificationRequest? activeRequest,
    String? error,
    List<VerificationRequest>? history,
  }) {
    return VerificationFlowState(
      currentTier: currentTier ?? this.currentTier,
      isInProgress: isInProgress ?? this.isInProgress,
      activeType: activeType ?? this.activeType,
      activeRequest: activeRequest ?? this.activeRequest,
      error: error,
      history: history ?? this.history,
    );
  }
}

/// Notifier for managing verification flow state using Riverpod 3.x AsyncNotifier pattern
class VerificationFlowNotifier extends Notifier<VerificationFlowState> {
  @override
  VerificationFlowState build() {
    // Load initial state asynchronously
    _loadInitialState();
    return const VerificationFlowState();
  }

  VerificationRepository get _repository => ref.read(verificationRepositoryProvider);

  /// Load initial verification state
  Future<void> _loadInitialState() async {
    try {
      final tier = await _repository.getVerificationTier();
      final history = await _repository.getVerificationHistory();
      state = state.copyWith(
        currentTier: tier,
        history: history,
      );
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  /// Start photo verification with a selfie image
  Future<void> submitPhotoVerification(String imagePath) async {
    state = state.copyWith(
      isInProgress: true,
      activeType: VerificationType.photo,
      error: null,
    );

    try {
      final request = await _repository.submitPhotoVerification(imagePath);
      final updatedHistory = await _repository.getVerificationHistory();
      final newTier = await _repository.getVerificationTier();

      state = state.copyWith(
        isInProgress: false,
        activeRequest: request,
        currentTier: newTier,
        history: updatedHistory,
      );
    } catch (e) {
      state = state.copyWith(
        isInProgress: false,
        error: e.toString(),
      );
    }
  }

  /// Start ID verification with document images
  Future<void> submitIdVerification({
    required String frontImagePath,
    String? backImagePath,
  }) async {
    state = state.copyWith(
      isInProgress: true,
      activeType: VerificationType.governmentId,
      error: null,
    );

    try {
      final request = await _repository.submitIdVerification(
        frontImagePath: frontImagePath,
        backImagePath: backImagePath,
      );
      final updatedHistory = await _repository.getVerificationHistory();
      final newTier = await _repository.getVerificationTier();

      state = state.copyWith(
        isInProgress: false,
        activeRequest: request,
        currentTier: newTier,
        history: updatedHistory,
      );
    } catch (e) {
      state = state.copyWith(
        isInProgress: false,
        error: e.toString(),
      );
    }
  }

  /// Cancel an in-progress verification
  Future<void> cancelVerification(String requestId) async {
    try {
      await _repository.cancelVerification(requestId);
      await _loadInitialState();
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  /// Clear any error
  void clearError() {
    state = state.copyWith(error: null);
  }

  /// Refresh the verification state
  Future<void> refresh() async {
    await _loadInitialState();
  }
}

/// Provider for the verification flow state
final verificationFlowProvider =
    NotifierProvider<VerificationFlowNotifier, VerificationFlowState>(
  VerificationFlowNotifier.new,
);

/// Provider for the current verification tier (convenience)
final currentVerificationTierProvider = Provider<VerificationTier>((ref) {
  return ref.watch(verificationFlowProvider).currentTier;
});

/// Provider for checking if a user can start verification
final canStartVerificationProvider = Provider<bool>((ref) {
  return ref.watch(verificationFlowProvider).canStartVerification;
});
