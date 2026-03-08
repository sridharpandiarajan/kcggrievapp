// lib/core/features/auth/presentation/controllers/auth_controller.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth_provider.dart';
import 'auth_state.dart';
import '../../../../storage/secure_storage_services.dart';

class AuthController extends Notifier<AuthState> {

  @override
  AuthState build() {
    return AuthState.initial();
  }

  /// LOGIN
  Future<void> login({
    required String registerNumber,
    required String password,
  }) async {

    state = AuthState.loading();

    try {
      final repository = ref.read(authRepositoryProvider);

      final userData = await repository.login(
        registerNumber: registerNumber,
        password: password,
      );

      print("LOGIN USER DATA: $userData");

      /// Token is already saved in AuthRepository
      state = AuthState.authenticated(userData);

    } catch (e) {

      print("LOGIN ERROR: $e");

      state = AuthState.error(e.toString());
    }
  }

  /// LOGOUT
  Future<void> logout() async {

    final repository = ref.read(authRepositoryProvider);
    await repository.logout();

    await SecureStorageService.instance.clearTokens();

    print("SESSION CLEARED");

    state = AuthState.unauthenticated();
  }

  /// CHECK LOGIN STATUS (Splash Screen)
  Future<void> checkAuthStatus() async {

    final session = await SecureStorageService.instance.getAccessToken();

    print("SESSION FROM STORAGE: $session");

    if (session != null && session.isNotEmpty) {

      /// Only confirms login, user data will be fetched again if needed
      state = AuthState.authenticated(null);

    } else {

      state = AuthState.unauthenticated();

    }
  }
}