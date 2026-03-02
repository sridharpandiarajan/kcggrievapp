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
}