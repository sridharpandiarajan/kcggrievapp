// lib/features/auth/data/auth_repository.dart

import '../../../storage/secure_storage_services.dart';
import '../../auth/data/auth_api_services.dart';

// lib/features/auth/data/auth_repository.dart

class AuthRepository {
  final AuthApiService _apiService;
  final SecureStorageService _secureStorage;

  AuthRepository(this._apiService, this._secureStorage);

  // lib/features/auth/data/auth_repository.dart

  // lib/features/auth/data/auth_repository.dart

  Future<dynamic> login({required String registerNumber, required String password}) async {
    final result = await _apiService.login(
      registerNumber: registerNumber,
      password: password,
    );

    final userData = result['user'];
    final token = result['token'];

    // CRITICAL: Await this!
    await _secureStorage.saveAccessToken(token);

    return userData;
  }

  // lib/features/auth/data/auth_repository.dart

  Future<dynamic> getCurrentUser() async {
    final token = await _secureStorage.getAccessToken();
    if (token == null) return null;

    try {
      // Call the API to get user info using the token
      final userData = await _apiService.getProfile();
      return userData; // Returns the user map if valid, null if 401
    } catch (e) {
      // If there's a network error, you might want to still allow
      // offline access or rethrow. For now, we return null to force login.
      return null;
    }
  }

  Future<void> logout() async {
    await _secureStorage.clearTokens();
  }
}