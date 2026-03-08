// lib/features/auth/data/auth_repository.dart

import '../../../storage/secure_storage_services.dart';
import '../../auth/data/auth_api_services.dart';

// lib/features/auth/data/auth_repository.dart

class AuthRepository {
  final AuthApiService _apiService;
  final SecureStorageService _secureStorage;

  AuthRepository(this._apiService, this._secureStorage);

  // lib/features/auth/data/auth_repository.dart

  Future<dynamic> login({
    required String registerNumber,
    required String password,
  }) async {
    final result = await _apiService.login(
      registerNumber: registerNumber,
      password: password,
    );

    final userData = result['user']; // This map now contains {'reg_no': '...'}
    final token = result['token'];

    await _secureStorage.saveAccessToken(token);

    return userData;
  }

  Future<dynamic> getCurrentUser() async {
    final token = await _secureStorage.getAccessToken();
    if (token == null) return null;

    try {
      // Fetch the profile. Ensure AuthApiService returns the 'user' portion of the JSON
      return await _apiService.getProfile(token);
    } catch (e) {
      return null;
    }
  }

  Future<void> logout() async {
    await _secureStorage.clearTokens();
  }
}