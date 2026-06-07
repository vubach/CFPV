import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';

import 'app.dart';
import 'core/network/dio_client.dart';
import 'core/network/auth_interceptor.dart';
import 'core/services/secure_storage_service.dart';
import 'core/services/token_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ── 1. Initialize Firebase ───────────────────────────
  try {
    await Firebase.initializeApp();
  } catch (e) {
    debugPrint('Firebase init failed: $e');
  }

  // ── 2. Initialize storage (no dependencies) ───────────
  final secureStorage = SecureStorageService();

  // ── 3. Create DioClient (no interceptors yet) ─────────
  final dioClient = DioClient.create(interceptors: []);

  // ── 4. Build token service with the DioClient ─────────
  final tokenService = TokenService(
    storage: secureStorage,
    dioClient: dioClient,
  );

  // ── 5. Add auth interceptor to the existing DioClient ──
  dioClient.dio.interceptors.add(
    AuthInterceptor(tokenService: tokenService),
  );

  runApp(
    const ProviderScope(
      child: CFPVApp(),
    ),
  );
}
