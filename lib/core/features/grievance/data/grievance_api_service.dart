import 'package:dio/dio.dart';

class GrievanceApiService {
  final Dio _dio;

  GrievanceApiService(this._dio);

  Future<void> createGrievance({
    required String? title,
    required String description,
    required bool isAnonymous,
  }) async {
    final response = await _dio.post(
      '/api/grievances',
      data: {
        "title": title,
        "description": description,
        "isAnonymous": isAnonymous,
      },
    );

    if (response.statusCode != 201 && response.statusCode != 200) {
      throw Exception("Failed to create grievance");
    }
  }
  Future<List<dynamic>> getMyGrievances() async {
    final response = await _dio.get('/api/grievances/my');

    if (response.statusCode == 200) {

      final data = response.data;

      if (data is Map<String, dynamic>) {
        return data['data'] ?? [];
      }

      if (data is List) {
        return data;
      }

      return [];

    } else {
      throw Exception("Failed to fetch grievances");
    }
  }
}