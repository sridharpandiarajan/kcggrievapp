// lib/core/network/dio_client.dart

import 'package:dio/dio.dart';
import 'auth_interceptor.dart';
import '../storage/secure_storage_services.dart';

class DioClient {
  final Dio dio;

  DioClient({
    required String baseUrl,
    required SecureStorageService secureStorage,
  }) : dio = Dio(
    BaseOptions(
      baseUrl: baseUrl,

      // Increased for Render cold start
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      sendTimeout: const Duration(seconds: 30),

      headers: {
        'Content-Type': 'application/json',
      },
    ),
  ) {

    /// 🔐 Attach Auth Token
    dio.interceptors.add(AuthInterceptor(secureStorage));

    /// 📊 Debug Logging (REMOVE IN PRODUCTION)
    dio.interceptors.add(
      LogInterceptor(
        requestBody: true,
        responseBody: true,
        requestHeader: true,
        responseHeader: false,
      ),
    );

    /// 🔁 Retry interceptor for Render cold start
    dio.interceptors.add(
      InterceptorsWrapper(
        onError: (error, handler) async {

          if (error.type == DioExceptionType.receiveTimeout ||
              error.type == DioExceptionType.connectionTimeout) {

            print("Retrying request after timeout...");

            await Future.delayed(const Duration(seconds: 3));

            try {
              final response = await dio.fetch(error.requestOptions);
              return handler.resolve(response);
            } catch (e) {
              return handler.next(error);
            }
          }

          return handler.next(error);
        },
      ),
    );
  }
}