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

  /// Path to the captured front of the ID document, held between the document
  /// step and the selfie step. The provider needs both in one submission.
  final String? documentFrontPath;

  /// Path to the captured back of the ID document, when the document type has one.
  final String? documentBackPath;

  /// Creates a new [VerificationFlowState]
  const VerificationFlowState({
    this.currentTier = VerificationTier.unverified,
    this.isInProgress = false,
    this.activeType,
    this.activeRequest,
    this.error,
    this.history = const [],
    this.documentFrontPath,
    this.documentBackPath,
  });

  /// Whether a document has been captured and is waiting for a selfie.
  bool get hasStagedDocument => documentFrontPath != null;

  /// Whether the user can start a new verification
  bool get canStartVerification => !isInProgress && currentTier != VerificationTier.idVerified;

  /// Whether the user can do photo verification
  bool get canDoPhotoVerification => currentTier == VerificationTier.unverified;

  /// Whether the user can do ID verification
  bool get canDoIdVerification =>
      currentTier == VerificationTier.emailVerified ||
      currentTier == VerificationTier.unverified;

  /// Creates a copy with updated fields.
  ///
  /// [error] is intentionally not defaulted to the current value — omitting it
  /// clears the error. Pass [clearDocument] to drop staged document paths once
  /// a submission completes, so a later run cannot reuse a stale capture.
  VerificationFlowState copyWith({
    VerificationTier? currentTier,
    bool? isInProgress,
    VerificationType? activeType,
    VerificationRequest? activeRequest,
    String? error,
    List<VerificationRequest>? history,
    String? documentFrontPath,
    String? documentBackPath,
    bool clearDocument = false,
  }) {
    return VerificationFlowState(
      currentTier: currentTier ?? this.currentTier,
      isInProgress: isInProgress ?? this.isInProgress,
      activeType: activeType ?? this.activeType,
      activeRequest: activeRequest ?? this.activeRequest,
      error: error,
      history: history ?? this.history,
      documentFrontPath:
          clearDocument ? null : (documentFrontPath ?? this.documentFrontPath),
      documentBackPath:
          clearDocument ? null : (documentBackPath ?? this.documentBackPath),
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

  /// Hold the captured ID document until the selfie step supplies the face.
  ///
  /// Nothing is sent to the provider here — Shufti needs the document and the
  /// selfie in one submission, so the document step only stages its capture.
  void stageDocument({
    required String frontImagePath,
    String? backImagePath,
  }) {
    state = state.copyWith(
      activeType: VerificationType.governmentId,
      documentFrontPath: frontImagePath,
      documentBackPath: backImagePath,
      error: null,
    );
  }

  /// Submit the staged document together with [selfiePath].
  ///
  /// Sets an error if no document has been staged — the provider cannot match a
  /// face against nothing, and a selfie alone would prove nothing about identity.
  Future<void> submitWithSelfie(String selfiePath) async {
    final frontPath = state.documentFrontPath;
    if (frontPath == null) {
      state = state.copyWith(
        isInProgress: false,
        error: 'Capture your ID document before taking a selfie.',
      );
      return;
    }

    state = state.copyWith(
      isInProgress: true,
      activeType: state.activeType ?? VerificationType.governmentId,
      error: null,
    );

    try {
      final request = await _repository.submitIdentityVerification(
        type: state.activeType ?? VerificationType.governmentId,
        documentFrontPath: frontPath,
        documentBackPath: state.documentBackPath,
        selfiePath: selfiePath,
      );
      final updatedHistory = await _repository.getVerificationHistory();
      final newTier = await _repository.getVerificationTier();

      state = state.copyWith(
        isInProgress: false,
        activeRequest: request,
        currentTier: newTier,
        history: updatedHistory,
        clearDocument: true,
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
