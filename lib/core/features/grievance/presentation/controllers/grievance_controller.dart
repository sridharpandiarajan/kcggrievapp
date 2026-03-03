import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../grievance_provider.dart';
import 'package:kcggriev/models/grievance_model.dart';

class GrievanceController
    extends Notifier<AsyncValue<List<GrievanceModel>>> {

  @override
  AsyncValue<List<GrievanceModel>> build() {
    return const AsyncData([]);
  }

  /// CREATE GRIEVANCE
  Future<void> createGrievance({
    required String? title,
    required String description,
    required bool isAnonymous,
  }) async {
    state = const AsyncLoading();

    try {
      final repo = ref.read(grievanceRepositoryProvider);

      await repo.createGrievance(
        title: title,
        description: description,
        isAnonymous: isAnonymous,
      );

      await fetchMyGrievances();

    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  /// FETCH MY GRIEVANCES
  Future<void> fetchMyGrievances() async {
    state = const AsyncLoading();

    try {
      final repo = ref.read(grievanceRepositoryProvider);

      final response = await repo.getMyGrievances();

      final grievances = response
          .map((e) => GrievanceModel.fromJson(e))
          .toList();

      state = AsyncData(grievances);

    } catch (e, st) {
      print("FETCH ERROR: $e");
      state = AsyncError(e, st);
    }
  }
}