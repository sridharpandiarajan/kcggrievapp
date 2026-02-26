import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth_provider.dart';
import 'auth_state.dart';

class AuthController extends Notifier<AuthState> {

  @override
  AuthState build() {
    return AuthState.initial();
  }

  Future<void> login({
    required String email,
    required String password,
  }) async {
    state = AuthState.loading();

    try {
      final repository = ref.read(authRepositoryProvider);

      await repository.login(
        email: email,
        password: password,
      );

      state = AuthState.authenticated();
    } catch (e) {
      state = AuthState.error(e.toString());
    }
  }

  Future<void> logout() async {
    final repository = ref.read(authRepositoryProvider);
    await repository.logout();
    state = AuthState.unauthenticated();
  }

  Future<void> checkAuthStatus() async {
    state = AuthState.loading();

    final repository = ref.read(authRepositoryProvider);
    final isLoggedIn = await repository.isLoggedIn();

    state = isLoggedIn
        ? AuthState.authenticated()
        : AuthState.unauthenticated();
  }
}