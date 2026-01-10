import 'package:mockito/mockito.dart';
import 'package:soloadventurer/core/storage/secure_storage.dart';

class MockSecureStorage extends Mock implements SecureStorage {
  @override
  Future<void> write(String key, String value) async {
    return super.noSuchMethod(
      Invocation.method(#write, [key, value]),
      returnValue: Future.value(),
    );
  }

  @override
  Future<String?> read(String key) async {
    return super.noSuchMethod(
      Invocation.method(#read, [key]),
      returnValue: Future<String?>.value(null),
    );
  }

  @override
  Future<void> delete(String key) async {
    return super.noSuchMethod(
      Invocation.method(#delete, [key]),
      returnValue: Future.value(),
    );
  }
}
