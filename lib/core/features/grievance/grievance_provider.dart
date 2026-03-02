import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../network/network_provider.dart';
import 'data/grievance_api_service.dart';
import 'data/grievance_repository.dart';
import 'presentation/controllers/grievance_controller.dart';

final grievanceApiServiceProvider =
    Provider<GrievanceApiService>((ref) {
  final dio = ref.read(dioProvider);
  return GrievanceApiService(dio);
});

final grievanceRepositoryProvider =
    Provider<GrievanceRepository>((ref) {
  final api = ref.read(grievanceApiServiceProvider);
  return GrievanceRepository(api);
});

final grievanceControllerProvider =
    NotifierProvider<GrievanceController, AsyncValue<void>>(
  GrievanceController.new,
);