// lib/core/storage/secure_storage_service.dart

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {

  SecureStorageService._();

  static final SecureStorageService instance = SecureStorageService._();

  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  static const String _accessTokenKey = 'access_token';

  /// Save access token
  Future<void> saveAccessToken(String token) async {
    await _storage.write(
      key: _accessTokenKey,
      value: token,
    );
  }

  /// Get access token
  Future<String?> getAccessToken() async {
    return await _storage.read(key: _accessTokenKey);
  }

  /// Clear tokens
  Future<void> clearTokens() async {
    await _storage.delete(key: _accessTokenKey);
  }
}