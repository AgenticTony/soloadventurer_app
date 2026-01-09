import 'package:flutter_test/flutter_test.dart';
import 'package:dio/dio.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:soloadventurer/core/network/network_reachability.dart';

// Generate mocks with: flutter pub run build_runner build --delete-conflicting-outputs
@GenerateMocks([Dio])
import 'network_reachability_test.mocks.dart';

void main() {
  late MockDio mockDio;
  late NetworkReachabilityService service;

  setUpAll(() async {
    // Initialize dotenv for tests
    await dotenv.load(fileName: '.env.example');
  });

  setUp(() {
    mockDio = MockDio();
    service = NetworkReachabilityService(
      dio: mockDio,
      testEndpointPath: '/health',
      timeoutMs: 5000,
      cacheTtlMs: 30000,
    );
  });

  tearDown(() {
    service.dispose();
  });

  group('NetworkReachabilityService', () {
    test('should return reachable result when HEAD request succeeds', () async {
      // Arrange
      final response = Response(
        requestOptions: RequestOptions(path: '/health'),
        statusCode: 200,
      );

      when(mockDio.head(
        any,
        options: anyNamed('options'),
      )).thenAnswer((_) async => response);

      // Act
      final result = await service.checkReachability();

      // Assert
      expect(result.isReachable, isTrue);
      expect(result.statusCode, equals(200));
      expect(result.responseTimeMs, greaterThanOrEqualTo(0));
      expect(result.errorMessage, isNull);
      verify(mockDio.head(any, options: anyNamed('options'))).called(1);
    });

    test('should use cached result when cache is valid', () async {
      // Arrange
      final response = Response(
        requestOptions: RequestOptions(path: '/health'),
        statusCode: 200,
      );

      when(mockDio.head(
        any,
        options: anyNamed('options'),
      )).thenAnswer((_) async => response);

      // Act - First call
      final result1 = await service.checkReachability();
      // Second call should use cache
      final result2 = await service.checkReachability();

      // Assert
      expect(result1.isReachable, isTrue);
      expect(result2.isReachable, isTrue);
      // Dio should only be called once (second call uses cache)
      verify(mockDio.head(any, options: anyNamed('options'))).called(1);
    });

    test('should clear cache and make new request when clearCache is called',
        () async {
      // Arrange
      final response = Response(
        requestOptions: RequestOptions(path: '/health'),
        statusCode: 200,
      );

      when(mockDio.head(
        any,
        options: anyNamed('options'),
      )).thenAnswer((_) async => response);

      // Act
      await service.checkReachability();
      service.clearCache();
      await service.checkReachability();

      // Assert
      // Dio should be called twice (once before cache clear, once after)
      verify(mockDio.head(any, options: anyNamed('options'))).called(2);
    });

    test('should return unreachable result on timeout', () async {
      // Arrange
      final error = DioException(
        type: DioExceptionType.connectionTimeout,
        requestOptions: RequestOptions(path: '/health'),
        message: 'Connection timeout',
      );

      when(mockDio.head(
        any,
        options: anyNamed('options'),
      )).thenThrow(error);

      // Act
      final result = await service.checkReachability();

      // Assert
      expect(result.isReachable, isFalse);
      expect(result.errorMessage, contains('timeout'));
      expect(result.statusCode, isNull);
    });

    test('should return unreachable result on connection error', () async {
      // Arrange
      final error = DioException(
        type: DioExceptionType.connectionError,
        requestOptions: RequestOptions(path: '/health'),
        message: 'Connection refused',
      );

      when(mockDio.head(
        any,
        options: anyNamed('options'),
      )).thenThrow(error);

      // Act
      final result = await service.checkReachability();

      // Assert
      expect(result.isReachable, isFalse);
      expect(result.errorMessage, contains('Connection error'));
    });

    test('should return unreachable result on server error (5xx)', () async {
      // Arrange
      final response = Response(
        requestOptions: RequestOptions(path: '/health'),
        statusCode: 500,
      );

      when(mockDio.head(
        any,
        options: anyNamed('options'),
      )).thenAnswer((_) async => response);

      // Act
      final result = await service.checkReachability();

      // Assert
      expect(result.isReachable, isFalse);
      expect(result.errorMessage, contains('500'));
    });

    test('should fall back to GET when HEAD returns 405', () async {
      // Arrange
      final headError = DioException(
        type: DioExceptionType.badResponse,
        requestOptions: RequestOptions(path: '/health'),
        response: Response(
          requestOptions: RequestOptions(path: '/health'),
          statusCode: 405,
        ),
      );

      final getResponse = Response(
        requestOptions: RequestOptions(path: '/health'),
        statusCode: 200,
      );

      when(mockDio.head(
        any,
        options: anyNamed('options'),
      )).thenThrow(headError);

      when(mockDio.get(
        any,
        options: anyNamed('options'),
      )).thenAnswer((_) async => getResponse);

      // Act
      final result = await service.checkReachability();

      // Assert
      expect(result.isReachable, isTrue);
      expect(result.statusCode, equals(200));
      verify(mockDio.head(any, options: anyNamed('options'))).called(1);
      verify(mockDio.get(any, options: anyNamed('options'))).called(1);
    });

    test('should return cached result when available', () {
      // Arrange
      final cachedResult = NetworkReachabilityResult.reachable(
        endpoint: 'https://api.example.com/health',
        statusCode: 200,
        responseTimeMs: 100,
      );

      // Act
      // First, check that cache is empty
      expect(service.hasValidCache, isFalse);
      expect(service.cachedResult, isNull);

      // Note: We can't directly set _cachedResult, so we verify through public API
      // by making a real request (which would require mocking differently)
    });

    test('should handle unexpected errors gracefully', () async {
      // Arrange
      when(mockDio.head(
        any,
        options: anyNamed('options'),
      )).thenThrow(Exception('Unexpected error'));

      // Act
      final result = await service.checkReachability();

      // Assert
      expect(result.isReachable, isFalse);
      expect(result.errorMessage, contains('Unexpected error'));
    });

    test('should respect hasValidCache flag', () async {
      // Arrange
      final response = Response(
        requestOptions: RequestOptions(path: '/health'),
        statusCode: 200,
      );

      when(mockDio.head(
        any,
        options: anyNamed('options'),
      )).thenAnswer((_) async => response);

      // Act & Assert
      expect(service.hasValidCache, isFalse);

      await service.checkReachability();
      expect(service.hasValidCache, isTrue);

      service.clearCache();
      expect(service.hasValidCache, isFalse);
    });
  });

  group('NetworkReachabilityResult', () {
    test('should create reachable result correctly', () {
      // Act
      final result = NetworkReachabilityResult.reachable(
        endpoint: 'https://api.example.com/health',
        statusCode: 200,
        responseTimeMs: 150,
      );

      // Assert
      expect(result.isReachable, isTrue);
      expect(result.endpoint, equals('https://api.example.com/health'));
      expect(result.statusCode, equals(200));
      expect(result.responseTimeMs, equals(150));
      expect(result.errorMessage, isNull);
    });

    test('should create unreachable result correctly', () {
      // Act
      final result = NetworkReachabilityResult.unreachable(
        endpoint: 'https://api.example.com/health',
        errorMessage: 'Connection refused',
      );

      // Assert
      expect(result.isReachable, isFalse);
      expect(result.endpoint, equals('https://api.example.com/health'));
      expect(result.errorMessage, equals('Connection refused'));
      expect(result.statusCode, isNull);
      expect(result.responseTimeMs, isNull);
    });

    test('should create cached result correctly', () {
      // Arrange
      final original = NetworkReachabilityResult.reachable(
        endpoint: 'https://api.example.com/health',
        statusCode: 200,
        responseTimeMs: 100,
      );

      // Act
      final cached = NetworkReachabilityResult.cached(original);

      // Assert
      expect(cached.isReachable, equals(original.isReachable));
      expect(cached.endpoint, equals(original.endpoint));
      expect(cached.statusCode, equals(original.statusCode));
      expect(cached.responseTimeMs, equals(original.responseTimeMs));
      expect(cached.timestamp, equals(original.timestamp));
    });

    test('should implement equality correctly', () {
      // Arrange
      final result1 = NetworkReachabilityResult.reachable(
        endpoint: 'https://api.example.com/health',
        statusCode: 200,
        responseTimeMs: 100,
      );

      final result2 = NetworkReachabilityResult.reachable(
        endpoint: 'https://api.example.com/health',
        statusCode: 200,
        responseTimeMs: 150, // Different response time
      );

      final result3 = NetworkReachabilityResult.unreachable(
        endpoint: 'https://api.example.com/health',
        errorMessage: 'Error',
      );

      // Assert
      expect(result1, equals(result2)); // Same endpoint and status
      expect(result1, isNot(equals(result3))); // Different status
    });
  });
}
