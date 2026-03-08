import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import '../../grievance_provider.dart';
import 'package:kcggriev/models/grievance_model.dart';

class GrievanceController
    extends Notifier<AsyncValue<List<GrievanceModel>>> {

  late Box cacheBox;

  @override
  AsyncValue<List<GrievanceModel>> build() {

    cacheBox = Hive.box('grievance_cache');

    final cached = cacheBox.get('my_grievances');

    if (cached != null) {
      final List list = cached as List;

      final grievances = list
          .map((e) => GrievanceModel.fromJson(Map<String, dynamic>.from(e)))
          .toList();

      // Refresh silently in background
      Future.microtask(fetchMyGrievances);

      return AsyncData(grievances);
    }

    // If no cache, fetch normally
    fetchMyGrievances();
    return const AsyncLoading();
  }

  /// CREATE GRIEVANCE
  Future<void> createGrievance({
    required String? title,
    required String description,
    required bool isAnonymous,
  }) async {

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

    try {
      final repo = ref.read(grievanceRepositoryProvider);

      final response = await repo.getMyGrievances();

      final grievances = response
          .map((e) => GrievanceModel.fromJson(e))
          .toList();

      // Update UI
      state = AsyncData(grievances);

      // Save to cache
      cacheBox.put(
        'my_grievances',
        grievances.map((g) => g.toJson()).toList(),
      );

    } catch (e, st) {
      print("FETCH ERROR: $e");
      state = AsyncError(e, st);
    }
  }

  /// FETCH SINGLE GRIEVANCE
  Future<GrievanceModel> fetchGrievanceById(String id) async {

    final repo = ref.read(grievanceRepositoryProvider);
    final response = await repo.getGrievanceById(id);

    return GrievanceModel.fromJson(response);
  }
}