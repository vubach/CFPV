import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_constants.dart';

/// Manages OTP resend cooldown countdown.
class OtpTimerNotifier extends StateNotifier<int> {
  Timer? _timer;

  OtpTimerNotifier() : super(0);

  bool get isActive => state > 0;

  void start() {
    state = AppConstants.otpResendCooldown.inSeconds;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (state > 1) {
        state--;
      } else {
        state = 0;
        _timer?.cancel();
      }
    });
  }

  void reset() {
    _timer?.cancel();
    state = 0;
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

final otpTimerProvider = StateNotifierProvider<OtpTimerNotifier, int>((ref) {
  return OtpTimerNotifier();
});
