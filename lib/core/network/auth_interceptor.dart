import 'package:dio/dio.dart';
import '../storage/secure_storage_services.dart';

class AuthInterceptor extends Interceptor {
  final SecureStorageService secureStorage;

  AuthInterceptor(this.secureStorage);

  @override
  void onRequest(
      RequestOptions options,
      RequestInterceptorHandler handler,
      ) async {

    final token = await secureStorage.getAccessToken();

    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
      print("TOKEN ATTACHED: $token");
    }

    return handler.next(options);
  }

  @override
  void onError(
      DioException err,
      ErrorInterceptorHandler handler,
      ) async {

    if (err.response?.statusCode == 401) {
      print("401 detected");
    }

    return handler.next(err);
  }
}