// lib/features/auth/presentation/controllers/auth_state.dart
enum AuthStatus { initial, loading, authenticated, unauthenticated, error }

class AuthState {
  final AuthStatus status;
  final String? errorMessage;
  final dynamic user;

  const AuthState({required this.status, this.user, this.errorMessage});

  factory AuthState.initial() => const AuthState(status: AuthStatus.initial);
  factory AuthState.loading() => const AuthState(status: AuthStatus.loading);

  // Positional argument: AuthState.authenticated(userData)
  factory AuthState.authenticated(dynamic user) =>
      AuthState(status: AuthStatus.authenticated, user: user);

  factory AuthState.unauthenticated() => const AuthState(status: AuthStatus.unauthenticated);
  factory AuthState.error(String message) => AuthState(status: AuthStatus.error, errorMessage: message);
}