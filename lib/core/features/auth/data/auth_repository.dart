// lib/features/auth/data/auth_repository.dart

import '../../../storage/secure_storage_services.dart';
import '../../auth/data/auth_api_services.dart';

class AuthRepository {
  final AuthApiService _apiService;
  final SecureStorageService _secureStorage;

  AuthRepository(
    this._apiService,
    this._secureStorage,
  );

Future<void> login({
  required String registerNumber ,
  required String password,
}) async {
  final result = await _apiService.login(
    registerNumber: registerNumber,
    password: password,
  );

  final token = result['token'];
  print(token);

  await _secureStorage.saveAccessToken(token);
}

  /// Check if user already logged in
  Future<bool> isLoggedIn() async {
    final token = await _secureStorage.getAccessToken();
    return token != null;
    
  }

  /// Logout
  Future<void> logout() async {
    await _secureStorage.clearTokens();
  }
}