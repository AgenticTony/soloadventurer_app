import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:soloadventurer/features/social/domain/enums/verification_tier.dart';
import 'package:soloadventurer/features/verification/domain/entities/verification_request.dart';
import 'package:soloadventurer/features/verification/domain/enums/verification_status.dart';
import 'package:soloadventurer/features/verification/domain/enums/verification_type.dart';
import 'package:soloadventurer/features/verification/domain/repositories/verification_repository.dart';
import 'package:soloadventurer/features/verification/presentation/providers/verification_providers.dart';

/// Records what the flow actually hands to the repository.
///
/// The bug this suite guards against was invisible to a mock that only checked
/// call counts: the UI called methods that threw `UnimplementedError`, so the
/// Shufti path was never reached. These tests assert on the arguments.
class _RecordingRepository implements VerificationRepository {
  final List<Map<String, dynamic>> submissions = [];
  final List<Map<String, dynamic>> polls = [];

  /// When set, [submitIdentityVerification] throws this instead of succeeding.
  Object? throwOnSubmit;

  /// Status returned by a successful submission.
  VerificationStatus resultStatus = VerificationStatus.verified;

  @override
  Future<VerificationRequest> submitIdentityVerification({
    required VerificationType type,
    required String documentFrontPath,
    String? documentBackPath,
    required String selfiePath,
    String country = 'GB',
  }) async {
    submissions.add({
      'type': type,
      'documentFrontPath': documentFrontPath,
      'documentBackPath': documentBackPath,
      'selfiePath': selfiePath,
      'country': country,
    });

    if (throwOnSubmit != null) throw throwOnSubmit!;

    return VerificationRequest(
      id: 'req-1',
      userId: 'user-1',
      type: type,
      status: resultStatus,
      providerRef: 'shufti-123',
      createdAt: DateTime(2026, 8, 12),
    );
  }

  @override
  Future<VerificationRequest> pollVerification({
    required VerificationType type,
    required String providerReference,
  }) async {
    polls.add({'type': type, 'providerReference': providerReference});
    return VerificationRequest(
      id: 'req-1',
      userId: 'user-1',
      type: type,
      status: resultStatus,
      providerRef: providerReference,
      createdAt: DateTime(2026, 8, 12),
    );
  }

  @override
  Future<VerificationTier> getVerificationTier() async =>
      VerificationTier.unverified;

  @override
  Future<List<VerificationRequest>> getVerificationHistory() async => [];

  @override
  Future<VerificationRequest> getVerificationStatus(String requestId) async =>
      throw UnimplementedError();

  @override
  Future<bool> hasPendingVerification(VerificationType type) async => false;

  @override
  Future<void> cancelVerification(String requestId) async {}
}

void main() {
  late _RecordingRepository repository;
  late ProviderContainer container;

  setUp(() {
    repository = _RecordingRepository();
    container = ProviderContainer(
      overrides: [
        verificationRepositoryProvider.overrideWithValue(repository),
      ],
    );
  });

  tearDown(() => container.dispose());

  VerificationFlowNotifier notifier() =>
      container.read(verificationFlowProvider.notifier);

  VerificationFlowState state() => container.read(verificationFlowProvider);

  group('staging the document', () {
    test('holds the capture without contacting the provider', () {
      notifier().stageDocument(frontImagePath: '/tmp/front.jpg');

      expect(
        repository.submissions,
        isEmpty,
        reason: 'the document step must not submit — Shufti needs the selfie too',
      );
      expect(state().hasStagedDocument, isTrue);
      expect(state().documentFrontPath, '/tmp/front.jpg');
      expect(state().activeType, VerificationType.governmentId);
    });

    test('keeps the optional document back when one is captured', () {
      notifier().stageDocument(
        frontImagePath: '/tmp/front.jpg',
        backImagePath: '/tmp/back.jpg',
      );

      expect(state().documentBackPath, '/tmp/back.jpg');
    });
  });

  group('submitting with a selfie', () {
    test('sends document and selfie together in one submission', () async {
      notifier().stageDocument(
        frontImagePath: '/tmp/front.jpg',
        backImagePath: '/tmp/back.jpg',
      );

      await notifier().submitWithSelfie('/tmp/selfie.jpg');

      expect(repository.submissions, hasLength(1));
      expect(repository.submissions.single, {
        'type': VerificationType.governmentId,
        'documentFrontPath': '/tmp/front.jpg',
        'documentBackPath': '/tmp/back.jpg',
        'selfiePath': '/tmp/selfie.jpg',
        'country': 'GB',
      });
    });

    test('reaches the repository at all — the regression this suite exists for',
        () async {
      notifier().stageDocument(frontImagePath: '/tmp/front.jpg');

      await notifier().submitWithSelfie('/tmp/selfie.jpg');

      expect(
        state().error,
        isNull,
        reason: 'UnimplementedError from the repository would surface here',
      );
      expect(state().activeRequest, isNotNull);
      expect(state().activeRequest!.providerRef, 'shufti-123');
    });

    test('clears the staged document so a later run cannot reuse it', () async {
      notifier().stageDocument(frontImagePath: '/tmp/front.jpg');
      await notifier().submitWithSelfie('/tmp/selfie.jpg');

      expect(state().hasStagedDocument, isFalse);
      expect(state().documentFrontPath, isNull);
      expect(state().documentBackPath, isNull);
    });

    test('refuses to submit a selfie with no document staged', () async {
      await notifier().submitWithSelfie('/tmp/selfie.jpg');

      expect(
        repository.submissions,
        isEmpty,
        reason: 'a face with no document proves nothing about identity',
      );
      expect(state().error, contains('ID document'));
      expect(state().isInProgress, isFalse);
    });

    test('surfaces a repository failure as an error and stops progress',
        () async {
      repository.throwOnSubmit = Exception('provider rejected the document');
      notifier().stageDocument(frontImagePath: '/tmp/front.jpg');

      await notifier().submitWithSelfie('/tmp/selfie.jpg');

      expect(state().isInProgress, isFalse);
      expect(state().error, contains('provider rejected the document'));
      expect(state().activeRequest, isNull);
    });

    test('keeps the document staged after a failure so the user can retry',
        () async {
      repository.throwOnSubmit = Exception('network unreachable');
      notifier().stageDocument(frontImagePath: '/tmp/front.jpg');

      await notifier().submitWithSelfie('/tmp/selfie.jpg');

      expect(
        state().hasStagedDocument,
        isTrue,
        reason: 'a failed submit should not force re-capturing the document',
      );
    });

    test('carries a declined result through rather than reporting success',
        () async {
      repository.resultStatus = VerificationStatus.failed;
      notifier().stageDocument(frontImagePath: '/tmp/front.jpg');

      await notifier().submitWithSelfie('/tmp/selfie.jpg');

      expect(state().activeRequest!.status, VerificationStatus.failed);
      expect(state().error, isNull);
    });
  });
}
