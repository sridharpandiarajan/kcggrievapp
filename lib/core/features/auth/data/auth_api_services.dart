import 'package:dio/dio.dart';

class AuthApiService {
  final Dio _dio;

  AuthApiService(this._dio);

  // lib/features/auth/data/auth_api_services.dart

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

    // If your backend returns { "data": { "token": "...", "user": { "reg_no": "..." } } }
    final token = response.data['data']['token'];
    final user = response.data['data']['user'];

    return {
      "token": token,
      "user": user, // This user map contains the 'reg_no'
    };
  }

  /// 🔥 ADDED: Fetches user profile data using the stored token
  Future<dynamic> getProfile(String token) async {
    try {
      final response = await _dio.get(
        '/api/auth/profile', // Ensure this matches your backend endpoint
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );

      // Check if the response is successful based on your API structure
      if (response.data['success'] == true) {
        return response.data['data']['user'];
      }

      return null;
    } on DioException catch (e) {
      // If token is expired or invalid (401), returning null allows
      // the repository to trigger a clean logout/unauthenticated state.
      if (e.response?.statusCode == 401) {
        return null;
      }
      throw Exception(e.message ?? "Failed to fetch profile");
    }
  }
}