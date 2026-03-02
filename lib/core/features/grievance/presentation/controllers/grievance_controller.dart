import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../grievance_provider.dart';

class GrievanceController extends Notifier<AsyncValue<void>> {

  @override
  AsyncValue<void> build() {
    return const AsyncData(null);
  }

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

      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }
}