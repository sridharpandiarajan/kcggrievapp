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
            connectTimeout: const Duration(seconds: 15),
            receiveTimeout: const Duration(seconds: 15),
            headers: {
              'Content-Type': 'application/json',
            },
          ),
        ) {
    dio.interceptors.add(AuthInterceptor(secureStorage));
  }
}