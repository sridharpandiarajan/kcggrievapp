                                                                    // lib/core/features/auth/presentation/controllers/auth_controller.dart

                                                                    import 'package:flutter_riverpod/flutter_riverpod.dart';
                                                                    import 'package:flutter_secure_storage/flutter_secure_storage.dart';
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
                                                                          ///
                                                                          // This is likely what is happening in your AuthController:
                                                                          if (userData != null) {
                                                                            state = AuthState.authenticated(userData);
                                                                          } else {
                                                                            print("SESSION EXPIRED OR INVALID"); // 👈 This line is printing in your logs
                                                                            await logout(); // 👈 This is why your token is being deleted immediately
                                                                          }

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
                                                                      /// CHECK LOGIN STATUS (Splash Screen)
                                                                      // lib/core/features/auth/presentation/controllers/auth_controller.dart

                                                                      /// CHECK LOGIN STATUS (Used by Splash Screen)
                                                                      Future<void> checkAuthStatus() async {

                                                                        print("CHECKING SESSION...");

                                                                        final token = await SecureStorageService.instance.getAccessToken();

                                                                        if (token == null || token.isEmpty) {
                                                                          print("NO TOKEN FOUND");
                                                                          state = AuthState.unauthenticated();
                                                                          return;
                                                                        }

                                                                        try {
                                                                          final repository = ref.read(authRepositoryProvider);

                                                                          final user = await repository.getCurrentUser();

                                                                          if (user != null) {
                                                                            print("SESSION VALID");
                                                                            state = AuthState.authenticated(user);
                                                                          } else {
                                                                            print("TOKEN INVALID");
                                                                            await logout();
                                                                          }

                                                                        } catch (e) {
                                                                          print("AUTH CHECK FAILED: $e");
                                                                          state = AuthState.unauthenticated();
                                                                        }
                                                                      }
                                                                    }