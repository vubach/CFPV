import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'core/network/dio_client.dart';
import 'core/network/auth_interceptor.dart';
import 'core/services/secure_storage_service.dart';
import 'core/services/token_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ── 1. Initialize storage (no dependencies) ───────────
  final secureStorage = SecureStorageService();

  // ── 2. Create DioClient (no interceptors yet) ─────────
  final dioClient = DioClient.create(interceptors: []);

  // ── 3. Build token service with the DioClient ─────────
  final tokenService = TokenService(
    storage: secureStorage,
    dioClient: dioClient,
  );

  // ── 4. Add auth interceptor to the existing DioClient ──
  dioClient.dio.interceptors.add(
    AuthInterceptor(tokenService: tokenService),
  );

  runApp(
    const ProviderScope(
      child: CFPVApp(),
    ),
  );
}
