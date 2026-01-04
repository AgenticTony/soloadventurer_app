import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:soloadventurer/core/storage/secure_storage_service.dart';

/// A mock implementation of [SharedPreferences] for testing.
class MockSharedPreferences extends Mock implements SharedPreferences {
  final Map<String, dynamic> _data = {};

  /// Sets up the mock for a successful getString operation.
  void setupGetString(String key, String? value) {
    when(() => getString(key)).thenReturn(value);
  }

  /// Sets up the mock for a successful setString operation.
  void setupSetString(String key) {
    when(() => setString(key, any())).thenAnswer((invocation) {
      final value = invocation.positionalArguments[1] as String;
      _data[key] = value;
      return Future.value(true);
    });
  }

  /// Sets up the mock for a successful getBool operation.
  void setupGetBool(String key, bool? value) {
    when(() => getBool(key)).thenReturn(value);
  }

  /// Sets up the mock for a successful setBool operation.
  void setupSetBool(String key) {
    when(() => setBool(key, any())).thenAnswer((invocation) {
      final value = invocation.positionalArguments[1] as bool;
      _data[key] = value;
      return Future.value(true);
    });
  }

  /// Sets up the mock for a successful getInt operation.
  void setupGetInt(String key, int? value) {
    when(() => getInt(key)).thenReturn(value);
  }

  /// Sets up the mock for a successful setInt operation.
  void setupSetInt(String key) {
    when(() => setInt(key, any())).thenAnswer((invocation) {
      final value = invocation.positionalArguments[1] as int;
      _data[key] = value;
      return Future.value(true);
    });
  }

  /// Sets up the mock for a successful getDouble operation.
  void setupGetDouble(String key, double? value) {
    when(() => getDouble(key)).thenReturn(value);
  }

  /// Sets up the mock for a successful setDouble operation.
  void setupSetDouble(String key) {
    when(() => setDouble(key, any())).thenAnswer((invocation) {
      final value = invocation.positionalArguments[1] as double;
      _data[key] = value;
      return Future.value(true);
    });
  }

  /// Sets up the mock for a successful getStringList operation.
  void setupGetStringList(String key, List<String>? value) {
    when(() => getStringList(key)).thenReturn(value);
  }

  /// Sets up the mock for a successful setStringList operation.
  void setupSetStringList(String key) {
    when(() => setStringList(key, any())).thenAnswer((invocation) {
      final value = invocation.positionalArguments[1] as List<String>;
      _data[key] = value;
      return Future.value(true);
    });
  }

  /// Sets up the mock for a successful remove operation.
  void setupRemove(String key) {
    when(() => remove(key)).thenAnswer((_) {
      _data.remove(key);
      return Future.value(true);
    });
  }

  /// Sets up the mock for a successful clear operation.
  void setupClear() {
    when(() => clear()).thenAnswer((_) {
      _data.clear();
      return Future.value(true);
    });
  }
}

/// A mock implementation of [FlutterSecureStorage] for testing.
class MockFlutterSecureStorage extends Mock implements FlutterSecureStorage {
  final Map<String, String> _data = {};

  /// Sets up the mock for a successful read operation.
  void setupRead(String key, String? value) {
    when(() => read(key: key)).thenAnswer((_) async => value);
  }

  /// Sets up the mock for a successful write operation.
  void setupWrite(String key) {
    when(() => write(key: key, value: any(named: 'value')))
        .thenAnswer((invocation) async {
      final value = invocation.namedArguments[const Symbol('value')] as String;
      _data[key] = value;
    });
  }

  /// Sets up the mock for a successful delete operation.
  void setupDelete(String key) {
    when(() => delete(key: key)).thenAnswer((_) async {
      _data.remove(key);
    });
  }

  /// Sets up the mock for a successful deleteAll operation.
  void setupDeleteAll() {
    when(() => deleteAll()).thenAnswer((_) async {
      _data.clear();
    });
  }

  /// Sets up the mock for a successful readAll operation.
  void setupReadAll(Map<String, String> values) {
    when(() => readAll()).thenAnswer((_) async => values);
  }
}

/// A mock implementation of [SecureStorageService] for testing.
class MockSecureStorageService extends Mock implements SecureStorageService {
  String? _username;
  String? _authToken;
  String? _refreshToken;
  String? _userId;

  /// Sets up the mock for a successful getUsername operation.
  void setupGetUsername(String? username) {
    _username = username;
    when(() => getUsername()).thenAnswer((_) async => username);
  }

  /// Sets up the mock for a successful storeUsername operation.
  void setupStoreUsername() {
    when(() => storeUsername(any())).thenAnswer((invocation) async {
      _username = invocation.positionalArguments[0] as String;
      return null;
    });
  }

  /// Sets up the mock for a successful getAuthToken operation.
  void setupGetAuthToken(String? authToken) {
    _authToken = authToken;
    when(() => getAuthToken()).thenAnswer((_) async => authToken);
  }

  /// Sets up the mock for a successful storeAuthToken operation.
  void setupStoreAuthToken() {
    when(() => storeAuthToken(any())).thenAnswer((invocation) async {
      _authToken = invocation.positionalArguments[0] as String;
      return null;
    });
  }

  /// Sets up the mock for a successful getRefreshToken operation.
  void setupGetRefreshToken(String? refreshToken) {
    _refreshToken = refreshToken;
    when(() => getRefreshToken()).thenAnswer((_) async => refreshToken);
  }

  /// Sets up the mock for a successful storeRefreshToken operation.
  void setupStoreRefreshToken() {
    when(() => storeRefreshToken(any())).thenAnswer((invocation) async {
      _refreshToken = invocation.positionalArguments[0] as String;
      return null;
    });
  }

  /// Sets up the mock for a successful getUserId operation.
  void setupGetUserId(String? userId) {
    _userId = userId;
    when(() => getUserId()).thenAnswer((_) async => userId);
  }

  /// Sets up the mock for a successful storeUserId operation.
  void setupStoreUserId() {
    when(() => storeUserId(any())).thenAnswer((invocation) async {
      _userId = invocation.positionalArguments[0] as String;
      return null;
    });
  }

  /// Sets up the mock for a successful clearAuthData operation.
  void setupClearAuthData() {
    when(() => clearAuthData()).thenAnswer((_) async {
      _username = null;
      _authToken = null;
      _refreshToken = null;
      _userId = null;
      return null;
    });
  }
}
