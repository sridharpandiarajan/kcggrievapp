// lib/core/storage/secure_storage_service.dart
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  SecureStorageService._();
  static final SecureStorageService instance = SecureStorageService._();

  // Define options as a constant to ensure read/write use the same Keystore alias
  static const _androidOptions = AndroidOptions(
    encryptedSharedPreferences: true,
  );

  final _storage = const FlutterSecureStorage(
    aOptions: _androidOptions,
  );

  static const String _tokenKey = 'auth_token';

  Future<void> saveAccessToken(String token) async {
    try {
      await _storage.write(key: _tokenKey, value: token);
      print("STORAGE: Token saved successfully");
    } catch (e) {
      print("STORAGE ERROR (SAVE): $e");
    }
  }

  Future<String?> getAccessToken() async {
    try {
      final token = await _storage.read(key: _tokenKey);
      print("STORAGE: Read - ${token != null ? 'TOKEN FOUND' : 'NULL'}");
      return token;
    } catch (e) {
      print("STORAGE ERROR (READ): $e");
      return null;
    }
  }

  Future<void> clearTokens() async {
    print("STORAGE: DELETE CALLED - CHECK STACK TRACE");
    await _storage.delete(key: _tokenKey);
  }

  Future<void> debugLogAll() async {
    final all = await _storage.readAll();
    print("DEBUG ALL STORAGE KEYS: ${all.keys}");
  }
}