// lib/features/auth/auth_providers.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';

import '../../network/network_provider.dart';
import '../../storage/secure_storage_services.dart';
import '../auth/data/auth_api_services.dart';
import 'data/auth_repository.dart';
import '../../features/auth/presentation/controllers/auth_contoller.dart';
import 'presentation/controllers/auth_state.dart';

/// Auth API Service Provider
final authApiServiceProvider = Provider<AuthApiService>((ref) {
  final dio = ref.read(dioProvider);
  return AuthApiService(dio);
});

/// Auth Repository Provider
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final apiService = ref.read(authApiServiceProvider);
  final secureStorage = ref.read(secureStorageProvider);

  return AuthRepository(apiService, secureStorage);
});

/// Auth Controller Provider
final authControllerProvider =
    NotifierProvider<AuthController, AuthState>(
  AuthController.new,
);