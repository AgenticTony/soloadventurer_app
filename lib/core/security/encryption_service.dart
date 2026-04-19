import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'dart:async';
import 'package:encrypt/encrypt.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:pointycastle/pointycastle.dart';
import 'package:pointycastle/key_derivators/pbkdf2.dart';
import 'package:pointycastle/digests/sha256.dart';
import 'package:pointycastle/macs/hmac.dart';
import 'package:pointycastle/random/fortuna_random.dart';

/// Service for handling encryption and decryption of sensitive data
abstract class EncryptionService {
  Future<String> encrypt(String data);
  Future<String> decrypt(String encryptedData);
}

class EncryptionServiceImpl implements EncryptionService {
  static const _keyTag = 'encryption_key';
  static const _ivTag = 'encryption_iv';
  static const _saltTag = 'encryption_salt';
  static const _versionTag = 'encryption_version';
  static const _backupKeyTag = 'backup_key';
  static const _operationsCounterTag = 'operations_counter';
  static const _lastOperationTimeTag = 'last_operation_time';
  static const _currentVersion = 1;
  static const _iterationCount = 100000;
  static const _maxOperationsPerMinute = 100;
  static const _keyRotationInterval = Duration(days: 30);
  static const _memoryLockTimeout = Duration(minutes: 5);

  final FlutterSecureStorage _secureStorage;
  Encrypter? _encrypter;
  IV? _iv;
  late Uint8List _salt;
  late int _version;
  late HMac _hmac;
  Timer? _memoryLockTimer;
  DateTime? _lastKeyRotation;
  int _operationsCounter = 0;
  DateTime _lastOperationTime = DateTime.now();
  bool _isLocked = false;

  /// Creates a new [EncryptionService]
  EncryptionServiceImpl({FlutterSecureStorage? secureStorage})
      : _secureStorage = secureStorage ??
            const FlutterSecureStorage(
              mOptions: MacOsOptions(usesDataProtectionKeychain: false),
            ) {
    // Start memory protection timer
    _startMemoryLockTimer();
  }

  /// Initialize the encryption service
  Future<void> initialize() async {
    await _loadOperationMetrics();

    // Try to retrieve existing key and IV
    final storedKey = await _secureStorage.read(key: _keyTag);
    final storedIV = await _secureStorage.read(key: _ivTag);
    final storedSalt = await _secureStorage.read(key: _saltTag);
    final storedVersion = await _secureStorage.read(key: _versionTag);

    _version =
        storedVersion != null ? int.parse(storedVersion) : _currentVersion;

    if (storedKey == null || storedIV == null || storedSalt == null) {
      await _generateNewKeyMaterial();
    } else {
      final keyBytes = base64Decode(storedKey);
      final ivBytes = base64Decode(storedIV);
      _salt = base64Decode(storedSalt);
      _setupEncryption(keyBytes, ivBytes);

      // Check if key rotation is needed
      await _checkKeyRotation();
    }
  }

  /// Encrypt sensitive data with integrity check
  @override
  Future<String> encrypt(String data) async {
    await _checkRateLimit();
    _checkMemoryLock();

    if (_encrypter == null || _iv == null) {
      await initialize();
    }

    try {
      final dataToEncrypt = '$_version:$data';
      final encrypted = _encrypter!.encrypt(dataToEncrypt, iv: _iv!);
      final mac = _generateMAC(encrypted.bytes);

      final combined = {
        'data': encrypted.base64,
        'mac': base64Encode(mac),
        'version': _version,
        'timestamp': DateTime.now().toIso8601String(),
      };

      await _incrementOperationCounter();
      return base64Encode(utf8.encode(jsonEncode(combined)));
    } finally {
      _resetMemoryLockTimer();
    }
  }

  /// Decrypt encrypted data with integrity verification
  @override
  Future<String> decrypt(String encryptedData) async {
    await _checkRateLimit();
    _checkMemoryLock();

    if (_encrypter == null || _iv == null) {
      await initialize();
    }

    try {
      final decoded = jsonDecode(utf8.decode(base64Decode(encryptedData)))
          as Map<String, dynamic>;
      final encryptedBytes = Encrypted.fromBase64(decoded['data'] as String);
      final storedMac = base64Decode(decoded['mac'] as String);
      final version = decoded['version'] as int;

      // Verify MAC
      final calculatedMac = _generateMAC(encryptedBytes.bytes);
      if (!_constantTimeEquals(calculatedMac, storedMac)) {
        throw Exception('Data integrity check failed');
      }

      if (version != _currentVersion) {
        await _migrateData(version, decoded);
      }

      final decrypted = _encrypter!.decrypt(encryptedBytes, iv: _iv!);
      final parts = decrypted.split(':');
      if (parts.length != 2) {
        throw Exception('Invalid data format');
      }

      await _incrementOperationCounter();
      return parts[1];
    } catch (e) {
      throw Exception('Failed to decrypt data: ${e.toString()}');
    } finally {
      _resetMemoryLockTimer();
    }
  }

  /// Create encrypted backup of key material
  Future<void> backupKeys() async {
    _checkMemoryLock();

    final keyMaterial = {
      'key': await _secureStorage.read(key: _keyTag),
      'iv': await _secureStorage.read(key: _ivTag),
      'salt': await _secureStorage.read(key: _saltTag),
      'version': _version,
      'timestamp': DateTime.now().toIso8601String(),
    };

    // Generate backup key
    final backupKey = _generateRandomBytes(32);
    final backupIV = IV.fromSecureRandom(16);
    final backupEncrypter = Encrypter(AES(Key(backupKey), mode: AESMode.gcm));

    // Encrypt key material
    final encryptedBackup = backupEncrypter.encrypt(
      jsonEncode(keyMaterial),
      iv: backupIV,
    );

    // Store backup
    await _secureStorage.write(
      key: _backupKeyTag,
      value: jsonEncode({
        'data': encryptedBackup.base64,
        'iv': base64Encode(backupIV.bytes),
        'key': base64Encode(backupKey),
      }),
    );
  }

  /// Restore keys from backup
  Future<void> restoreFromBackup() async {
    final backup = await _secureStorage.read(key: _backupKeyTag);
    if (backup == null) {
      throw Exception('No backup found');
    }

    final backupData = jsonDecode(backup) as Map<String, dynamic>;
    final backupKey = base64Decode(backupData['key'] as String);
    final backupIV = IV(base64Decode(backupData['iv'] as String));
    final encryptedData = Encrypted.fromBase64(backupData['data'] as String);

    final backupEncrypter = Encrypter(AES(Key(backupKey), mode: AESMode.gcm));
    final decrypted = backupEncrypter.decrypt(encryptedData, iv: backupIV);
    final keyMaterial = jsonDecode(decrypted) as Map<String, dynamic>;

    // Restore key material
    await _secureStorage.write(
        key: _keyTag, value: keyMaterial['key'] as String);
    await _secureStorage.write(key: _ivTag, value: keyMaterial['iv'] as String);
    await _secureStorage.write(
        key: _saltTag, value: keyMaterial['salt'] as String);
    _version = keyMaterial['version'] as int;
    await _secureStorage.write(key: _versionTag, value: _version.toString());

    await initialize();
  }

  /// Securely destroy all key material
  Future<void> secureDestroy() async {
    // Overwrite memory
    if (_encrypter != null) {
      final zeros = Uint8List(32);
      _setupEncryption(zeros, zeros);
      _salt = zeros;
    }

    // Clear secure storage
    await _secureStorage.deleteAll();

    // Reset state
    _encrypter = null;
    _iv = null;
    _isLocked = true;
    _operationsCounter = 0;
    _memoryLockTimer?.cancel();
  }

  /// Check if the service is locked
  bool get isLocked => _isLocked;

  /// Get the number of operations performed in the current minute
  int get operationsCount => _operationsCounter;

  void dispose() {
    _memoryLockTimer?.cancel();
    secureDestroy();
  }

  // Private methods

  Future<void> _checkRateLimit() async {
    final now = DateTime.now();
    if (now.difference(_lastOperationTime) >= const Duration(minutes: 1)) {
      _operationsCounter = 0;
      _lastOperationTime = now;
      await _saveOperationMetrics();
    } else if (_operationsCounter >= _maxOperationsPerMinute) {
      throw Exception('Rate limit exceeded. Please try again later.');
    }
  }

  Future<void> _incrementOperationCounter() async {
    _operationsCounter++;
    await _saveOperationMetrics();
  }

  Future<void> _loadOperationMetrics() async {
    final counter = await _secureStorage.read(key: _operationsCounterTag);
    final lastOp = await _secureStorage.read(key: _lastOperationTimeTag);

    if (counter != null) {
      _operationsCounter = int.parse(counter);
    }
    if (lastOp != null) {
      _lastOperationTime = DateTime.parse(lastOp);
    }
  }

  Future<void> _saveOperationMetrics() async {
    await _secureStorage.write(
      key: _operationsCounterTag,
      value: _operationsCounter.toString(),
    );
    await _secureStorage.write(
      key: _lastOperationTimeTag,
      value: _lastOperationTime.toIso8601String(),
    );
  }

  void _checkMemoryLock() {
    if (_isLocked) {
      throw Exception('Encryption service is locked. Please reinitialize.');
    }
  }

  void _startMemoryLockTimer() {
    _memoryLockTimer?.cancel();
    _memoryLockTimer = Timer(_memoryLockTimeout, () {
      _isLocked = true;
      _encrypter = null;
      _iv = null;
    });
  }

  void _resetMemoryLockTimer() {
    _startMemoryLockTimer();
  }

  Future<void> _checkKeyRotation() async {
    if (_lastKeyRotation == null) {
      _lastKeyRotation = DateTime.now();
      return;
    }

    if (DateTime.now().difference(_lastKeyRotation!) >= _keyRotationInterval) {
      await backupKeys();
      await rotateKeys();
      _lastKeyRotation = DateTime.now();
    }
  }

  Future<void> _migrateData(int oldVersion, Map<String, dynamic> data) async {
    // Implement version-specific migration logic here
    // For now, we'll just throw an exception
    throw UnimplementedError(
        'Data migration not implemented for version $oldVersion');
  }

  /// Hash sensitive data (one-way) with salt
  String hash(String data) {
    final bytes = utf8.encode(data);
    final saltedBytes = Uint8List.fromList([..._salt, ...bytes]);
    return sha256.convert(saltedBytes).toString();
  }

  /// Generate a new encryption key and IV using PBKDF2
  Future<void> _generateNewKeyMaterial() async {
    // Generate random salt
    _salt = _generateRandomBytes(32);

    // Generate master key
    final masterKey = _generateRandomBytes(32);

    // Derive encryption key using PBKDF2
    final derivedKey = _deriveKey(masterKey, _salt);
    final iv = IV.fromSecureRandom(16);

    // Store key material
    await _secureStorage.write(key: _keyTag, value: base64Encode(derivedKey));
    await _secureStorage.write(key: _ivTag, value: base64Encode(iv.bytes));
    await _secureStorage.write(key: _saltTag, value: base64Encode(_salt));
    await _secureStorage.write(
        key: _versionTag, value: _currentVersion.toString());

    _setupEncryption(derivedKey, iv.bytes);
  }

  /// Set up the encrypter with the given key and IV
  void _setupEncryption(Uint8List keyBytes, Uint8List ivBytes) {
    final key = Key(keyBytes);
    _iv = IV(ivBytes);
    _encrypter = Encrypter(AES(key, mode: AESMode.gcm, padding: null));
    _hmac = HMac(SHA256Digest(), 64)..init(KeyParameter(keyBytes));
  }

  /// Rotate encryption keys with data migration
  Future<void> rotateKeys() async {
    // Generate new key material
    await _generateNewKeyMaterial();

    // Re-encrypt data with new keys if needed
    // This would be implemented based on your specific storage needs
    _version++;
    await _secureStorage.write(key: _versionTag, value: _version.toString());
  }

  /// Generate MAC for data integrity
  Uint8List _generateMAC(Uint8List data) {
    _hmac.reset();
    _hmac.update(data, 0, data.length);
    final mac = Uint8List(_hmac.macSize);
    _hmac.doFinal(mac, 0);
    return mac;
  }

  /// Derive key using PBKDF2
  Uint8List _deriveKey(Uint8List masterKey, Uint8List salt) {
    final pbkdf2 = PBKDF2KeyDerivator(HMac(SHA256Digest(), 64));
    pbkdf2.init(Pbkdf2Parameters(salt, _iterationCount, 32)); // 256-bit key
    return pbkdf2.process(masterKey);
  }

  /// Generate cryptographically secure random bytes
  Uint8List _generateRandomBytes(int length) {
    final secureRandom = FortunaRandom();
    // Seed with cryptographically secure random bytes from Random.secure()
    final random = Random.secure();
    final seed = Uint8List.fromList(
      List.generate(32, (_) => random.nextInt(256)),
    );
    secureRandom.seed(KeyParameter(seed));
    return secureRandom.nextBytes(length);
  }

  /// Constant-time comparison of two Uint8Lists
  bool _constantTimeEquals(Uint8List a, Uint8List b) {
    if (a.length != b.length) return false;
    var result = 0;
    for (var i = 0; i < a.length; i++) {
      result |= a[i] ^ b[i];
    }
    return result == 0;
  }

  /// Securely compare two strings (constant-time comparison)
  bool secureCompare(String a, String b) {
    final aBytes = utf8.encode(a);
    final bBytes = utf8.encode(b);
    return _constantTimeEquals(
        Uint8List.fromList(aBytes), Uint8List.fromList(bBytes));
  }

  /// Get the current encryption version
  int get currentVersion => _version;

  /// Check if encryption needs upgrade
  bool needsUpgrade() => _version < _currentVersion;
}
