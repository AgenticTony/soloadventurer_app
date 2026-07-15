import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:soloadventurer/core/api/client/api_client.dart';
import 'package:soloadventurer/features/safety/data/datasources/safety_remote_data_source_impl.dart';
import 'package:soloadventurer/features/safety/domain/entities/safety_alert.dart';
import 'package:soloadventurer/features/safety/domain/exceptions/safety_exceptions.dart';

// Story 0.4 (step 9a) — the Emergency SOS trigger must call the deployed
// `trigger-sos` Supabase Edge Function, NOT the dead GraphQL host that made the
// button always fail. These tests pin the client contract: the payload shape and
// the response mapping, plus the failure path.

class MockApiClient extends Mock implements ApiClient {}

class MockSupabaseClient extends Mock implements SupabaseClient {}

class MockFunctionsClient extends Mock implements FunctionsClient {}

void main() {
  late MockApiClient apiClient;
  late MockSupabaseClient supabase;
  late MockFunctionsClient functions;
  late SafetyRemoteDataSourceImpl dataSource;

  final location = SafetyAlertLocation(
    latitude: 55.6,
    longitude: 13.0,
    accuracy: 8.0,
    address: 'Malmö',
    timestamp: DateTime.parse('2026-07-15T12:00:00.000Z'),
  );

  setUp(() {
    apiClient = MockApiClient();
    supabase = MockSupabaseClient();
    functions = MockFunctionsClient();
    when(() => supabase.functions).thenReturn(functions);
    dataSource = SafetyRemoteDataSourceImpl(
      apiClient: apiClient,
      supabaseClient: supabase,
    );
  });

  group('triggerEmergencySOS -> trigger-sos edge function', () {
    test('invokes trigger-sos with the location payload and maps the response',
        () async {
      when(() => functions.invoke('trigger-sos', body: any(named: 'body')))
          .thenAnswer(
        (_) async => FunctionResponse(
          data: const {
            'success': true,
            'alert_id': 'alert-123',
            'status': 'active',
            'triggered_at': '2026-07-15T12:00:00.000Z',
            'notified_contacts_count': 2,
          },
          status: 200,
        ),
      );

      final alert = await dataSource.triggerEmergencySOS(
        userId: 'user-1',
        location: location,
        message: 'need help',
        notifyContactIds: const ['c1'],
        batteryLevel: 42,
      );

      expect(alert.id, 'alert-123');
      expect(alert.userId, 'user-1');
      expect(alert.type, SafetyAlertType.emergencySOS);
      expect(alert.status, SafetyAlertStatus.sent);
      expect(alert.message, 'need help');
      expect(alert.batteryLevel, 42);
      expect(alert.location?.latitude, 55.6);
      expect(alert.triggeredAt, DateTime.parse('2026-07-15T12:00:00.000Z'));

      final body = verify(
        () => functions.invoke('trigger-sos', body: captureAny(named: 'body')),
      ).captured.single as Map<String, dynamic>;
      expect(body['latitude'], 55.6);
      expect(body['longitude'], 13.0);
      expect(body['accuracy'], 8.0);
      expect(body['address'], 'Malmö');
      expect(body['message'], 'need help');
      expect(body['battery_level'], 42);
    });

    test('omits optional fields that are null', () async {
      when(() => functions.invoke('trigger-sos', body: any(named: 'body')))
          .thenAnswer(
        (_) async => FunctionResponse(
          data: const {'alert_id': 'a2', 'status': 'active'},
          status: 200,
        ),
      );

      await dataSource.triggerEmergencySOS(
        userId: 'user-1',
        location: SafetyAlertLocation(
          latitude: 1.0,
          longitude: 2.0,
          timestamp: DateTime.parse('2026-07-15T12:00:00.000Z'),
        ),
        notifyContactIds: const [],
      );

      final body = verify(
        () => functions.invoke('trigger-sos', body: captureAny(named: 'body')),
      ).captured.single as Map<String, dynamic>;
      expect(body.containsKey('message'), isFalse);
      expect(body.containsKey('battery_level'), isFalse);
      expect(body.containsKey('accuracy'), isFalse);
    });

    test('throws EmergencySOSTriggerFailedException on a non-200 response',
        () async {
      when(() => functions.invoke('trigger-sos', body: any(named: 'body')))
          .thenAnswer(
        (_) async =>
            FunctionResponse(data: const {'error': 'boom'}, status: 500),
      );

      expect(
        () => dataSource.triggerEmergencySOS(
          userId: 'user-1',
          location: location,
          notifyContactIds: const [],
        ),
        throwsA(isA<EmergencySOSTriggerFailedException>()),
      );
    });

    test('throws EmergencySOSTriggerFailedException when invoke throws',
        () async {
      when(() => functions.invoke('trigger-sos', body: any(named: 'body')))
          .thenThrow(Exception('network down'));

      expect(
        () => dataSource.triggerEmergencySOS(
          userId: 'user-1',
          location: location,
          notifyContactIds: const [],
        ),
        throwsA(isA<EmergencySOSTriggerFailedException>()),
      );
    });
  });
}
