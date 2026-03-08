// lib/core/network/network_providers.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../storage/secure_storage_services.dart';
import 'dio_client.dart';

/// Secure Storage Provider
final secureStorageProvider = Provider<SecureStorageService>((ref) {
  return SecureStorageService.instance;
});

/// Dio Provider
final dioProvider = Provider<Dio>((ref) {
  final secureStorage = ref.read(secureStorageProvider);

  final dioClient = DioClient(
    baseUrl: "https://kcg-grievance-1.onrender.com", // change later
    //baseUrl:"http://10.10.72.60:5000", // for local testing
    secureStorage: secureStorage,
  );

  return dioClient.dio;
});