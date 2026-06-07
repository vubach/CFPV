import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/network/dio_client.dart';
import 'fcm_service.dart';

final fcmServiceProvider = Provider<FcmService>((ref) {
  final dio = DioClient.instance;
  return FcmService(dioClient: dio);
});

final fcmInitializedProvider = FutureProvider<void>((ref) async {
  final fcm = ref.watch(fcmServiceProvider);
  await fcm.initialize();
});
