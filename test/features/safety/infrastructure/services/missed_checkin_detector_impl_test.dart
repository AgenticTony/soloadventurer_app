import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:soloadventurer/core/services/location_service.dart';
import 'package:soloadventurer/core/services/notification_service.dart';
import 'package:soloadventurer/features/safety/domain/entities/check_in.dart';
import 'package:soloadventurer/features/safety/domain/repositories/safety_repository.dart';
import 'package:soloadventurer/features/safety/infrastructure/services/missed_checkin_detector.dart';
import 'package:soloadventurer/features/safety/infrastructure/services/missed_checkin_detector_impl.dart';

class _MockSafetyRepository extends Mock implements SafetyRepository {}

class _MockLocationService extends Mock implements LocationService {}

class _MockNotificationService extends Mock implements NotificationService {}

CheckIn _checkIn({
  required CheckInStatus status,
  DateTime? deadline,
  bool alertSent = false,
}) {
  return CheckIn(
    id: 'c1',
    userId: 'u1',
    triggerType: CheckInTriggerType.scheduledTime,
    status: status,
    deadline: deadline,
    notifyContactIds: const [],
    alertSent: alertSent,
    createdAt: DateTime(2030, 1, 1),
  );
}

void main() {
  late MissedCheckInDetectorImpl detector;

  setUp(() {
    detector = MissedCheckInDetectorImpl(
      safetyRepository: _MockSafetyRepository(),
      locationService: _MockLocationService(),
      notificationService: _MockNotificationService(),
    );
  });

  tearDown(() => detector.dispose());

  group('MissedCheckInDetector.isCheckInMissed — safety-critical guard', () {
    final grace = const Duration(minutes: MissedCheckInConfig.gracePeriodMinutes);

    test('completed check-ins are never missed', () {
      expect(
        detector.isCheckInMissed(
          _checkIn(
            status: CheckInStatus.completed,
            deadline: DateTime.now().subtract(const Duration(hours: 1)),
          ),
        ),
        isFalse,
      );
    });

    test('cancelled check-ins are never missed', () {
      expect(
        detector.isCheckInMissed(
          _checkIn(
            status: CheckInStatus.cancelled,
            deadline: DateTime.now().subtract(const Duration(hours: 1)),
          ),
        ),
        isFalse,
      );
    });

    test('already-missed + alert-sent is not re-flagged (no double alert)', () {
      expect(
        detector.isCheckInMissed(
          _checkIn(
            status: CheckInStatus.missed,
            alertSent: true,
            deadline: DateTime.now().subtract(const Duration(hours: 1)),
          ),
        ),
        isFalse,
      );
    });

    test('no deadline → cannot be missed', () {
      expect(
        detector.isCheckInMissed(
          _checkIn(status: CheckInStatus.active, deadline: null),
        ),
        isFalse,
      );
    });

    test('deadline in the future → not missed', () {
      expect(
        detector.isCheckInMissed(
          _checkIn(
            status: CheckInStatus.active,
            deadline: DateTime.now().add(const Duration(minutes: 30)),
          ),
        ),
        isFalse,
      );
    });

    test('past deadline but WITHIN the grace period → not yet missed', () {
      // 1 minute past deadline, grace is 5 minutes.
      expect(
        detector.isCheckInMissed(
          _checkIn(
            status: CheckInStatus.active,
            deadline: DateTime.now().subtract(const Duration(minutes: 1)),
          ),
        ),
        isFalse,
      );
    });

    test('past deadline BEYOND the grace period → missed (escalate)', () {
      expect(
        detector.isCheckInMissed(
          _checkIn(
            status: CheckInStatus.active,
            deadline: DateTime.now().subtract(grace + const Duration(minutes: 1)),
          ),
        ),
        isTrue,
      );
    });
  });

  group('MissedCheckInDetector.checkForMissedCheckIns — lifecycle guard', () {
    test('fails when not initialized (must init before scanning)', () async {
      final result = await detector.checkForMissedCheckIns();
      expect(result.success, isFalse);
    });

    test('initialize() moves the detector to initialized', () async {
      await detector.initialize();
      expect(detector.status, MissedCheckInDetectorStatus.initialized);
    });
  });
}
