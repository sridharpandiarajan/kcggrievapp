import 'package:dio/dio.dart';

class AuthApiService {
  final Dio _dio;

  AuthApiService(this._dio);

  /// LOGIN
  /// Generates token
  Future<Map<String, dynamic>> login({
    required String registerNumber,
    required String password,
  }) async {

    final response = await _dio.post(
      '/api/auth/login',
      data: {
        "registerNumber": registerNumber,
        "password": password,
      },
    );

    print("LOGIN RESPONSE: ${response.data}");

    final data = response.data['data'];

    return {
      "token": data['token'],
      "user": data['user'],
    };
  }

  /// FETCH PROFILE
  /// Token automatically attached by AuthInterceptor
  Future<dynamic> getProfile() async {
    try {

      final response = await _dio.get('/api/auth/profile');

      print("PROFILE RESPONSE: ${response.data}");

      final data = response.data;

      // Support multiple backend response formats
      final user =
          data['data']?['user'] ??
              data['user'] ??
              data['data'];

      if (user != null) {
        return user;
      }

      return null;

    } on DioException catch (e) {

      print("PROFILE ERROR: ${e.message}");

      // Only treat 401 as invalid token
      if (e.response?.statusCode == 401) {
        return null;
      }

      // Network issues (Render cold start / timeout)
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {

        print("SERVER WAKE-UP DELAY");
        throw Exception("Server timeout");
      }

      throw Exception(e.message ?? "Failed to fetch profile");
    }
  }
}