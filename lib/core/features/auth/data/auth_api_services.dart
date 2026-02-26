import 'package:dio/dio.dart';

class AuthApiService {
  final Dio _dio;

  AuthApiService(this._dio);

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final response = await _dio.post(
      '/api/auth/login',
      data: {
        "email": email,
        "password": password,
      },
    );

    if (response.data['success'] != true) {
      throw Exception(response.data['message'] ?? "Login failed");
    }

    final token = response.data['data']['token'];
    final user = response.data['data']['user'];

    if (token == null) {
      throw Exception("Token missing in response");
    }

    return {
      "token": token,
      "user": user,
    };
  }
}