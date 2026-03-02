import 'grievance_api_service.dart';

class GrievanceRepository {
  final GrievanceApiService _apiService;

  GrievanceRepository(this._apiService);

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
}