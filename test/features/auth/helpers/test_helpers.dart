import 'package:mocktail/mocktail.dart';
import 'package:soloadventurer/core/api/client/api_client.dart';
import 'package:soloadventurer/features/auth/data/datasources/auth_local_data_source.dart';
import 'package:soloadventurer/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:soloadventurer/features/auth/domain/repositories/auth_repository.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

// Mock classes
class MockAuthRepository extends Mock implements AuthRepository {}

class MockAuthRemoteDataSource extends Mock implements AuthRemoteDataSource {}

class MockAuthLocalDataSource extends Mock implements AuthLocalDataSource {}

class MockApiClient extends Mock implements ApiClient {}

class MockFlutterSecureStorage extends Mock implements FlutterSecureStorage {}

// Test data
const testEmail = 'test@example.com';
const testPassword = 'Test123!';
const testUsername = 'testuser';
const testUserId = 'user-123';
const testAccessToken = 'access-token-123';
const testRefreshToken = 'refresh-token-123';

// Helper functions
DateTime get testDateTime => DateTime(2024, 1, 1, 12, 0);

/// Creates a test user map for API responses
Map<String, dynamic> createTestUserMap({
  String id = testUserId,
  String email = testEmail,
  String username = testUsername,
  bool emailVerified = true,
}) {
  return {
    'id': id,
    'email': email,
    'username': username,
    'emailVerified': emailVerified,
    'createdAt': testDateTime.toIso8601String(),
    'updatedAt': testDateTime.toIso8601String(),
  };
}

/// Creates a test auth response map
Map<String, dynamic> createTestAuthResponseMap({
  String accessToken = testAccessToken,
  String refreshToken = testRefreshToken,
}) {
  return {
    'accessToken': accessToken,
    'refreshToken': refreshToken,
    'expiresIn': 3600,
    'user': createTestUserMap(),
  };
}
