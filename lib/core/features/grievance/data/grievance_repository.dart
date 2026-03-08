import 'grievance_api_service.dart';

class GrievanceRepository {
  final GrievanceApiService _apiService;

  GrievanceRepository(this._apiService);

  /// CREATE GRIEVANCE
  Future<void> createGrievance({
    required String? title,
    required String description,
    required bool isAnonymous,
  }) async {
    await _apiService.createGrievance(
      title: title,
      description: description,
      isAnonymous: isAnonymous,
    );
  }

  /// FETCH MY GRIEVANCES
  Future<List<dynamic>> getMyGrievances() async {
    final response = await _apiService.getMyGrievances();
    return response;
  }

  Future<Map<String, dynamic>> getGrievanceById(String id) async {
    return await _apiService.getGrievanceById(id);
  }
}